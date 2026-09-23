//! kakashi interview drills — every answer here compiles and its tests pass
//! against rustc 1.91 / tokio 1.x.

use std::collections::{HashMap, HashSet};
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;

// ---------------------------------------------------------------------------
// Drill 1 — bounded-concurrency worker with cancellation
// "Process N files, cap concurrency at K, support shutdown."
// ---------------------------------------------------------------------------
pub async fn bounded_transform(
    paths: Vec<std::path::PathBuf>,
    k: usize,
    shutdown: tokio::sync::watch::Receiver<bool>,
) -> Vec<(std::path::PathBuf, u64)> {
    use tokio::sync::Semaphore;

    let sem = Arc::new(Semaphore::new(k));
    let mut handles = Vec::new();

    for path in paths {
        let sem = Arc::clone(&sem);
        let mut shutdown = shutdown.clone();
        handles.push(tokio::spawn(async move {
            // acquire a permit OR shut down, whichever comes first
            let permit = tokio::select! {
                p = sem.acquire() => p.expect("semaphore closed"),
                _changed = shutdown.changed() => {
                    if *shutdown.borrow() {
                        return None; // cancelled before starting
                    }
                    sem.acquire().await.expect("semaphore closed")
                }
            };
            // re-check after acquiring: permit obtained during shutdown -> bail
            if *shutdown.borrow() {
                return None;
            }
            let bytes = tokio::fs::read(&path).await.ok()?;
            let sum: u64 = bytes.iter().map(|b| *b as u64).sum();
            drop(permit); // release explicitly — makes the scope rule visible
            Some((path, sum))
        }));
    }

    let mut out = Vec::new();
    for h in handles {
        if let Ok(Some(pair)) = h.await {
            out.push(pair);
        }
    }
    out
}

// ---------------------------------------------------------------------------
// Drill 2 — the std::sync::Mutex across await gotcha
// (broken variant: commenting shown in the site article; here are the fixes)
// ---------------------------------------------------------------------------
pub async fn fixed_scoped(
    cache: &Arc<std::sync::Mutex<HashMap<String, u64>>>,
    key: &str,
) -> u64 {
    // critical section #1 — sync Mutex is fine when no await happens inside
    let cached = cache.lock().unwrap().get(key).copied();
    if let Some(v) = cached {
        return v;
    }
    let computed = slow_hash(key).await; // await OUTSIDE the lock
    cache.lock().unwrap().insert(key.to_string(), computed);
    computed
}

async fn slow_hash(key: &str) -> u64 {
    tokio::time::sleep(std::time::Duration::from_millis(5)).await;
    key.bytes().fold(0u64, |acc, b| acc.wrapping_mul(31).wrapping_add(b as u64))
}

// tokio::sync::Mutex variant, for when the lock MUST span an await
pub async fn fixed_tokio_mutex(state: Arc<tokio::sync::Mutex<u64>>) {
    let mut g = state.lock().await;
    *g += 1;
    tokio::time::sleep(std::time::Duration::from_millis(1)).await;
    *g += 1; // still held — legal, but serializes everything: know the cost
}

// ---------------------------------------------------------------------------
// Drill 3 — zero-copy frame parser (length-prefixed, borrow don't copy)
// frame = [0xA5][len u16 LE][payload..][checksum u8 = payload.sum()]
// ---------------------------------------------------------------------------
#[derive(Debug, PartialEq, Eq)]
pub enum FrameError {
    BadSync,
    BadChecksum,
}

/// Returns all complete frames found; `rest` is the unparsed tail (borrowed).
pub fn parse_frames(buf: &[u8]) -> Result<(Vec<&[u8]>, &[u8]), FrameError> {
    let mut frames = Vec::new();
    let mut pos = 0;

    loop {
        let remaining = &buf[pos..];
        if remaining.len() < 3 {
            return Ok((frames, remaining)); // empty, or partial header
        }
        if remaining[0] != 0xA5 {
            return Err(FrameError::BadSync);
        }
        let len = u16::from_le_bytes([remaining[1], remaining[2]]) as usize;
        if remaining.len() < 3 + len + 1 {
            return Ok((frames, remaining)); // payload/checksum not fully arrived
        }
        let payload = &remaining[3..3 + len];
        let checksum = remaining[3 + len];
        if payload.iter().fold(0u8, |a, b| a.wrapping_add(*b)) != checksum {
            return Err(FrameError::BadChecksum);
        }
        frames.push(payload); // &[u8] borrowing the caller's buffer — zero copies
        pos += 3 + len + 1;
    }
}

// ---------------------------------------------------------------------------
// Drill 4 — sequence-number dedup over a lossy, out-of-order datalink
// ---------------------------------------------------------------------------
#[derive(Debug, PartialEq, Eq)]
pub enum Verdict {
    Accepted,
    Duplicate,
    LateBeyondWindow,
}

pub struct SeqDedup {
    window: u64,
    highest: u64,
    seen: HashSet<u64>,
}

impl SeqDedup {
    pub fn new(window: u64) -> Self {
        Self { window, highest: 0, seen: HashSet::new() }
    }

    pub fn accept(&mut self, seq: u64) -> Verdict {
        // older than the sliding window of what we track -> too late to dedupe
        if seq < self.highest.saturating_sub(self.window) {
            return Verdict::LateBeyondWindow;
        }
        if !self.seen.insert(seq) {
            return Verdict::Duplicate;
        }
        if seq > self.highest {
            self.highest = seq;
            // prune entries that fell out of the window
            let cutoff = self.highest.saturating_sub(self.window);
            self.seen.retain(|s| *s >= cutoff);
        }
        Verdict::Accepted
    }
}

// ---------------------------------------------------------------------------
// Drill 5 — shared-state aggregator: prove no lost updates
// ---------------------------------------------------------------------------
pub async fn fan_in(n: usize) -> u64 {
    let total = Arc::new(AtomicUsize::new(0));
    let mut tasks = Vec::new();
    for _ in 0..n {
        let total = Arc::clone(&total);
        tasks.push(tokio::spawn(async move {
            for _ in 0..1000 {
                total.fetch_add(1, Ordering::Relaxed);
            }
        }));
    }
    for t in tasks {
        t.await.unwrap();
    }
    total.load(Ordering::SeqCst) as u64
}

// ---------------------------------------------------------------------------
// tests
// ---------------------------------------------------------------------------
#[cfg(test)]
mod tests {
    use super::*;

    fn frame(payload: &[u8]) -> Vec<u8> {
        let mut v = vec![0xA5];
        v.extend((payload.len() as u16).to_le_bytes());
        v.extend_from_slice(payload);
        v.push(payload.iter().fold(0u8, |a, b| a.wrapping_add(*b)));
        v
    }

    #[test]
    fn parses_two_frames_and_returns_tail() {
        let mut buf = frame(b"alpha");
        buf.extend(frame(&[1, 2, 3]));
        buf.extend([0xA5, 0x02, 0x00]); // partial header of a third
        let (frames, rest) = parse_frames(&buf).unwrap();
        assert_eq!(frames, vec![&b"alpha"[..], &[1, 2, 3][..]]);
        assert_eq!(rest, &[0xA5, 0x02, 0x00]);
        assert!(std::ptr::eq(frames[0].as_ptr(), &buf[3])); // borrowed, zero copy
    }

    #[test]
    fn rejects_bad_checksum() {
        let mut f = frame(b"x");
        let n = f.len() - 1;
        f[n] ^= 0xFF;
        assert_eq!(parse_frames(&f), Err(FrameError::BadChecksum));
    }

    #[test]
    fn empty_buffer_is_fine() {
        let (frames, rest) = parse_frames(&[]).unwrap();
        assert!(frames.is_empty());
        assert!(rest.is_empty());
    }

    #[test]
    fn dedup_accept_dup_late() {
        let mut d = SeqDedup::new(8);
        assert_eq!(d.accept(10), Verdict::Accepted);
        assert_eq!(d.accept(10), Verdict::Duplicate);
        assert_eq!(d.accept(9), Verdict::Accepted); // in-window reorder
        assert_eq!(d.accept(20), Verdict::Accepted); // window slides
        assert_eq!(d.accept(9), Verdict::LateBeyondWindow); // pruned, too late
        assert_eq!(d.accept(19), Verdict::Accepted); // inside new window
    }

    #[tokio::test]
    async fn bounded_transform_sums_files() {
        let dir = std::env::temp_dir();
        let mut paths = Vec::new();
        for i in 0..12 {
            let p = dir.join(format!("kakashi-drill-{i}"));
            std::fs::write(&p, b"abcd").unwrap();
            paths.push(p);
        }
        let (_tx, rx) = tokio::sync::watch::channel(false);
        let out = bounded_transform(paths, 3, rx).await;
        assert_eq!(out.len(), 12);
        assert!(out.iter().all(|(_, sum)| *sum == 97 + 98 + 99 + 100)); // a+b+c+d
        for i in 0..12 {
            let _ = std::fs::remove_file(std::env::temp_dir().join(format!("kakashi-drill-{i}")));
        }
    }

    #[tokio::test]
    async fn semaphore_bounds_true_concurrency() {
        use std::sync::atomic::AtomicUsize;
        let sem = Arc::new(tokio::sync::Semaphore::new(3));
        let cur = Arc::new(AtomicUsize::new(0));
        let max = Arc::new(AtomicUsize::new(0));
        let mut hs = Vec::new();
        for _ in 0..20 {
            let (sem, cur, max) = (Arc::clone(&sem), Arc::clone(&cur), Arc::clone(&max));
            hs.push(tokio::spawn(async move {
                let _p = sem.acquire().await.unwrap();
                let now = cur.fetch_add(1, Ordering::SeqCst) + 1;
                max.fetch_max(now, Ordering::SeqCst);
                tokio::time::sleep(std::time::Duration::from_millis(2)).await;
                cur.fetch_sub(1, Ordering::SeqCst);
            }));
        }
        for h in hs {
            h.await.unwrap();
        }
        assert!(max.load(Ordering::SeqCst) <= 3);
    }

    #[tokio::test]
    async fn cancellation_short_circuits_new_work() {
        let dir = std::env::temp_dir();
        let mut paths = Vec::new();
        for i in 0..50 {
            let p = dir.join(format!("kakashi-cancel-{i}"));
            std::fs::write(&p, b"a").unwrap();
            paths.push(p);
        }
        let (tx, rx) = tokio::sync::watch::channel(false);
        tx.send(true).unwrap(); // signal before spawning does the reads
        let out = bounded_transform(paths, 2, rx).await;
        assert!(out.is_empty(), "cancelled run did work: {}", out.len());
        for i in 0..50 {
            let _ = std::fs::remove_file(std::env::temp_dir().join(format!("kakashi-cancel-{i}")));
        }
    }

    #[tokio::test]
    async fn scoped_cache_lock_awaits_outside_critical_section() {
        let cache = Arc::new(std::sync::Mutex::new(HashMap::new()));
        let a = fixed_scoped(&cache, "telemetry").await;
        let b = fixed_scoped(&cache, "telemetry").await;
        assert_eq!(a, b);
        assert_eq!(a, slow_hash("telemetry").await);
    }

    #[tokio::test]
    async fn tokio_mutex_variant_compiles_and_works() {
        let state = Arc::new(tokio::sync::Mutex::new(0u64));
        let (a, b) = (
            tokio::spawn(fixed_tokio_mutex(Arc::clone(&state))),
            tokio::spawn(fixed_tokio_mutex(state.clone())),
        );
        a.await.unwrap();
        b.await.unwrap();
        assert_eq!(*state.lock().await, 4);
    }

    #[tokio::test]
    async fn no_lost_updates() {
        assert_eq!(fan_in(8).await, 8_000);
    }

    // The compile-fail demo: keep commented; uncomment to see rustc reject it.
    // #[tokio::test]
    // async fn sync_mutex_guard_across_await_does_not_compile() {
    //     let m = Arc::new(std::sync::Mutex::new(0u32));
    //     let mut g = m.lock().unwrap();
    //     *g += 1;
    //     tokio::time::sleep(std::time::Duration::from_millis(1)).await; // ERROR here
    //     *g += 1;
    // }
}
