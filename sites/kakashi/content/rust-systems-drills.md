---
title: "Drills: Rust technical + systems questions"
desc: "Interview questions with complete, compile-verified reference answers (13 tests green). Collapsed — try each one first."
date: 2026-09-22
---

Companion to [the Helsing pre-flight](/helsing-rust-interview.md). Every answer contains the **complete reference code**, and every line of it compiles and passes tests in the drills crate (`~/.dotfiles/sites/kakashi/drills/`, rustc 1.91, tokio 1.53 — `cargo test`: 13/13 green). Practice protocol: read the question, **leave the answer collapsed**, write it cold in a bare editor (no rust-analyzer — that's the interview condition), then open and diff.

## Part 1 — Language & async technicals

### T1. Why can't you hold a `std::sync::MutexGuard` across an `.await`? Show the failure and all three fixes.

:::answer
**The guard isn't `Send`.** A future that holds it across an await point can resume on a different worker thread, so the future itself stops being `Send` — and `tokio::spawn` requires `Send` futures. `rustc` rejects it with *"future cannot be sent between threads safely"* **at the spawn boundary, not at the lock line** — that's what makes it bite people live.

The failure, exactly (uncomment to see rustc reject it):

```rust
// #[tokio::test]
// async fn sync_mutex_guard_across_await_does_not_compile() {
//     let m = Arc::new(std::sync::Mutex::new(0u32));
//     let mut g = m.lock().unwrap();
//     *g += 1;
//     tokio::time::sleep(std::time::Duration::from_millis(1)).await; // ERROR here
//     *g += 1;
// }
```

The three fixes, in preference order:

1. **Shrink the critical section** — lock, read/write, drop, *then* await. Usually right; sync locks are faster.

```rust
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
```

2. **`tokio::sync::Mutex`** — the async lock whose guard is `Send`; use only when the lock genuinely must span await. Cost: every acquire is a possible yield point, so it serializes the executor lane it protects.

```rust
pub async fn fixed_tokio_mutex(state: Arc<tokio::sync::Mutex<u64>>) {
    let mut g = state.lock().await;
    *g += 1;
    tokio::time::sleep(std::time::Duration::from_millis(1)).await;
    *g += 1; // still held — legal, but serializes everything: know the cost
}
```

3. **Restructure with message passing** — move the data behind an actor task and talk over channels. Right answer when two awaits need to coordinate on the same state (see T3's watch-channel pattern for the shape).

Verifying tests (both fixes under real concurrency):

```rust
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
```
:::

### T2. `select!` on a channel receive vs a shutdown signal — what's the cancellation-safety trap?

:::answer
`select!` polls branches and **drops the losing futures**. That's fine for `mpsc::Receiver::recv()` (cancellation-safe: the message stays queued), but NOT for non-idempotent futures — a future that already consumed a message or half-sent a reply when it loses has side-effected the world without you knowing.

Rules to say out loud:

- Know which operations are cancellation-safe (`recv` yes; a hand-rolled async fn that pulls-then-processes — no, unless you wrote it to requeue).
- After winning a race, **re-check shared shutdown state** — "permit acquired, then shutdown" is a real interleaving. This isn't theoretical: `bounded_transform` below failed its cancellation test the first time it ran without the re-check; a queue of pending tasks had already won `acquire()` before the signal landed.
- Prefer `JoinHandle::abort()` + structured shutdown (watch channel for broadcast, dropping `Sender` for drain) over scattering cancel flags.

Full worked implementation in T3.
:::

### T3. Semaphore-bounded fan-out with cancellation — write it.

:::answer
The shape of the round-2 coding test, probably. Complete, compile-verified version:

```rust
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
```

Talking points interviewers fish for: why `Arc<Semaphore>` (permits must outlive any one borrow; clones are refcount bumps), why the `select!` on `acquire()` needs the post-acquire re-check (T2's race), why `drop(permit)` is explicit (documents the critical section; prevents accidental long holds), and the **backpressure follow-up they always ask**: bounded semaphore = backpressure at the dispatcher; an mpsc channel of capacity K gives the same bound with a queue for free — trade is memory vs fast-fail.

The tests that prove it (happy path + cancellation + actual-concurrency bound):

```rust
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
    tx.send(true).unwrap(); // signal before the reads happen
    let out = bounded_transform(paths, 2, rx).await;
    assert!(out.is_empty(), "cancelled run did work: {}", out.len());
}

#[tokio::test]
async fn semaphore_bounds_true_concurrency() {
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
```
:::

### T4. Walk `Bytes` vs `Vec<u8>` vs `&[u8]` for a network receive path. Where do copies hide?

:::answer
Receive into a reusable `BytesMut` (`bytes` crate); freeze to `Bytes` for handoff — `Bytes::clone` is a refcount bump, no memcpy, and it's the standard zero-copy pipeline currency (axum, tonic, tokio-util all speak it).

- `Vec<u8>`: one allocation per message, and every fan-out forces a real clone.
- `&[u8]`: zero-copy but *borrow-bounded* — great for a parser that finishes inside one read (T5), wrong when frames must outlive the socket buffer.
- The hidden copies to name: `to_vec()` / `Bytes::copy_from_slice` at boundaries is the memcpy you're trying to avoid. The trick: a framing layer keeps one growing buffer and hands out `Bytes` slices that **share** its allocation — `split_to()` re-points, it doesn't copy.

Complete receive-path implementation:

```rust
pub fn drain_frames(buf: &mut bytes::BytesMut) -> Vec<bytes::Bytes> {
    let mut out = Vec::new();
    loop {
        if buf.len() < 3 {
            return out;
        }
        let len = u16::from_le_bytes([buf[1], buf[2]]) as usize;
        if buf.len() < 3 + len + 1 {
            return out; // incomplete — wait for more bytes
        }
        // split_to() re-points the buffer; freeze() turns the head into Bytes
        // sharing the SAME allocation. No memcpy anywhere on this path.
        let frame = buf.split_to(3 + len + 1).freeze();
        let payload = frame.slice(3..3 + len);
        out.push(payload);
    }
}
```

And the test that *proves* zero-copy by pointer identity:

```rust
#[test]
fn bytesmut_drain_splits_without_copying() {
    let mut buf = bytes::BytesMut::new();
    buf.extend_from_slice(&frame(b"alpha"));
    buf.extend_from_slice(&frame(&[1, 2, 3]));
    buf.extend_from_slice(&[0xA5, 0x09, 0x00]); // partial third frame
    let original_ptr = buf.as_ptr();
    let frames = drain_frames(&mut buf);
    assert_eq!(frames.len(), 2);
    assert_eq!(&frames[0][..], b"alpha");
    assert_eq!(&frames[1][..], &[1, 2, 3]);
    // the frozen head still points into the original allocation: zero copies
    assert_eq!(frames[0].as_ptr(), unsafe { original_ptr.add(3) });
    assert_eq!(buf.len(), 3); // the partial header remains
}
```
:::

### T5. Write a zero-copy parser for length-prefixed frames `[0xA5][len u16 LE][payload][sum8]` that returns borrowed frames plus the unconsumed tail.

:::answer
Complete implementation — 25 lines, borrows the caller's buffer, distinguishes *incomplete* from *corrupt*:

```rust
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
```

Narrate while writing:

- Return `Vec<&[u8]>` borrowed from the input — the borrow checker gives "can't return garbage" for free; the tail is just `&buf[pos..]`.
- **Incomplete ≠ corrupt**: partial header returns `Ok` with a remainder; bad sync/checksum is a hard `Err`. That framing is exactly what they want from anyone touching a datalink.
- `u16::from_le_bytes` — say "endian is part of the protocol; never transmute."
- **Follow-up they love**: attacker-controlled `len`? → reject `len > max_frame` *before* slicing; DoS via `len: 65535` on a 40-byte datagram is the classic embedded bug.

Tests (including the pointer-identity proof):

```rust
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

// test helper
fn frame(payload: &[u8]) -> Vec<u8> {
    let mut v = vec![0xA5];
    v.extend((payload.len() as u16).to_le_bytes());
    v.extend_from_slice(payload);
    v.push(payload.iter().fold(0u8, |a, b| a.wrapping_add(*b)));
    v
}
```
:::

### T6. Deduplicating a lossy, out-of-order telemetry stream: sequence numbers arrive at ~1 Hz with reordering and repeats, link can drop for minutes.

:::answer
Complete implementation — sliding-window dedup:

```rust
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
```

```rust
#[test]
fn dedup_accept_dup_late() {
    let mut d = SeqDedup::new(8);
    assert_eq!(d.accept(10), Verdict::Accepted);
    assert_eq!(d.accept(10), Verdict::Duplicate);
    assert_eq!(d.accept(9), Verdict::Accepted);  // in-window reorder
    assert_eq!(d.accept(20), Verdict::Accepted); // window slides
    assert_eq!(d.accept(9), Verdict::LateBeyondWindow); // pruned, too late
    assert_eq!(d.accept(19), Verdict::Accepted); // inside new window
}
```

Then the parts that make it real (say them unprompted):

- **Wraparound**: u64 buys ~585 years at 1 Hz — say the math. With u32 use serial-number arithmetic mod 2³².
- **Restart**: a stream resetting to 0 looks like the past — detect with a bootstrap rule (seq far below window ⇒ epoch bump, not a late packet).
- **The design-interview upgrade**: dedup is rarely one shared set at scale — key it per `(producer, stream-id)`, and the storage question (in-RAM set vs RocksDB vs bloom-filter fast path with exact verification) is the actual systems discussion.
:::

### T7. `Arc<Vec<T>>` clone in a hot loop — what actually happens? Make it O(1).

:::answer
`Arc::clone` bumps a refcount (one atomic store; cache-line traffic across cores is the only cost) and copies a pointer — O(1) *for the Arc*. The O(n) accident people mean is `(*arc).clone()` — note the deref — which clones the **Vec**.

Fixes to name:

- `Arc::make_mut` — copy-on-write mutation; clones the payload only when refcount > 1.
- `ArcSwap` (arc-swap crate) — read-mostly shared state: lock-free snapshot reads, writers publish a whole new Arc. Fits exactly the "push a new model/config to the edge node" story.

Complete ArcSwap config channel:

```rust
pub struct FleetConfig {
    pub heartbeat_hz: u32,
    pub geofence_km: f64,
}

pub struct ConfigChannel {
    current: arc_swap::ArcSwap<FleetConfig>,
}

impl ConfigChannel {
    pub fn new(cfg: FleetConfig) -> Self {
        Self { current: arc_swap::ArcSwap::from_pointee(cfg) }
    }
    /// Readers: lock-free, O(1), returns an immutable Arc snapshot.
    pub fn load(&self) -> arc_swap::Guard<std::sync::Arc<FleetConfig>> {
        self.current.load()
    }
    /// Writers: build a WHOLE new config, then publish — readers never see
    /// a half-updated struct (that's the point vs RwLock field mutations).
    pub fn publish(&self, cfg: FleetConfig) {
        self.current.store(Arc::new(cfg));
    }
}
```

The test that proves the property that matters — **no torn reads** across a concurrent publish:

```rust
#[test]
fn arcswap_publish_is_atomic_snapshot() {
    let ch = Arc::new(ConfigChannel::new(FleetConfig { heartbeat_hz: 1, geofence_km: 5.0 }));
    let before = ch.load().heartbeat_hz;
    let mut hs = Vec::new();
    for _ in 0..8 {
        let ch = Arc::clone(&ch);
        hs.push(std::thread::spawn(move || {
            let g = ch.load();
            (g.heartbeat_hz, g.geofence_km)
        }));
    }
    ch.publish(FleetConfig { heartbeat_hz: 50, geofence_km: 9.0 });
    for h in hs {
        let (hz, km) = h.join().unwrap();
        assert!(
            (hz == before && km == 5.0) || (hz == 50 && km == 9.0),
            "torn read: {hz}/{km}"
        );
    }
    assert_eq!(ch.load().heartbeat_hz, 50);
}
```
:::

### T8. You need to share a config struct with 40 tasks. Why might the compiler force a clone you can't remove?

:::answer
Because `&T` across `spawn` needs a lifetime outliving the future, and `JoinHandle` requires `'static` — borrows die at the spawn boundary. That's the real reason channels everywhere carry `Arc<Config>` instead of `&Config`.

The failure, exactly:

```rust
// pub fn broken_spawn_with_borrow(cfg: &FleetConfig) {
//     tokio::spawn(async move {
//         println!("{}", cfg.heartbeat_hz); // ERROR[E0597]: `cfg` does not live long enough
//     });
// }
```

The correct shape — share by Arc (cheap refcount), never by reference:

```rust
pub fn spawn_config_readers(cfg: Arc<FleetConfig>, n: usize) -> Vec<tokio::task::JoinHandle<u32>> {
    (0..n)
        .map(|_| {
            let cfg = Arc::clone(&cfg); // refcount bump, no deep copy
            tokio::spawn(async move { cfg.heartbeat_hz })
        })
        .collect()
}

#[tokio::test]
async fn arc_shared_config_across_spawns() {
    let cfg = Arc::new(FleetConfig { heartbeat_hz: 7, geofence_km: 1.0 });
    let readers = spawn_config_readers(Arc::clone(&cfg), 40);
    for r in readers {
        assert_eq!(r.await.unwrap(), 7);
    }
    assert!(Arc::strong_count(&cfg) >= 1);
}
```

Worked-example honesty bonus: this crate's own test hit a *related* error live — `E0382` (Arc moved into the first spawn, borrowed after; fix: `state.clone()` per task, not `state`). The fix conversation is precisely what T1/T7 rehearse.
:::

### T9. Quick-fire set — have one-liners loaded

:::answer
- **`Box<dyn Error>` vs `enum thiserror` at a crate boundary?** enum for APIs whose callers must branch; `thiserror` generates it mechanically; boxed/`anyhow` for app-level error soup and `main`.
- **Why does `#[derive(Clone)]` bite on a struct holding `Rc<RefCell<_>>`?** shallow clone shares the `RefCell` — mutations leak between "copies." That's why the threaded version is `Arc<Mutex<_>>` / `Arc<RwLock<_>>`.
- **Variance**: `&'a T` is covariant in `'a`, `&'a mut T` invariant — know one example each (e.g. why `Vec<&'static str>` coerces down but `RefCell<&'a str>` invariance bites in struct fields). Don't bluff past one example.
- **Panics**: `catch_unwind` ≠ error handling. A panic in a tokio task poisons the join — the `t.await??` double-`?` (join error, then task error) is the systems answer. See T6's `fan_in`: `t.await.unwrap()` in a loop is exactly this shape.
- **Faster than `Mutex<HashMap>` for sharded state?** split the map (per-key shards / DashMap) or make writes single-threaded with snapshot reads (`ArcSwap`, T7) — and say "measure first."
:::

### Bonus drill: no lost updates (`Arc<AtomicUsize>` fan-in)

:::answer
The concurrency version of "prove it, don't assert it" — and the 5-line answer to *"how do you know your aggregation is correct under 8-way concurrency?"*:

```rust
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

#[tokio::test]
async fn no_lost_updates() {
    assert_eq!(fan_in(8).await, 8_000);
}
```

Talking point: `Relaxed` is sufficient for a counter with no dependent state (each `fetch_add` is its own atomic RMW); the `SeqCst` load is where you *would* need ordering if other data guarded it — the `join()`s already establish happens-before for the final read. Say all of that in one breath and the follow-up dies.
:::

## Part 2 — Systems design scenarios

Their documented prompts are drone/robotics-domain (reported example: crop-tracking + mold detection). All three below share the skeleton to internalize: **source → constrained link → ingest → processing → consumer, with degradation modes on every arrow.**

### S1. "Design drone telemetry: 10k drones, 1 Hz GPS/attitude/battery, unreliable link, operators need a live map with <2s latency."

:::answer
**Requirements first.** 10k × 1 msg/s ≈ 110 msg/s total — *tiny* for the backend, so the hard part is NOT throughput; it's the radio path, correctness under loss, and freshness semantics. Saying "let me size the load before I pick Kafka" wins points.

**Uplink.** Drones batch frames (T5 parser) into short burst transmissions; sequence numbers + epoch per flight (T6). Store-and-forward with on-device replay buffer to survive minutes of silence — say the size: 1 Hz × 200 B × 15 min ≈ 180 KB/drone, trivial. No TLS on the mesh (their own JD: "low-trust, no-TLS networks") → per-message signing at the application layer; replay windows double as anti-replay.

**Ingest.** Regional ground gateway: stateless decoder → validates → pushes `{drone_id, seq, fix, quality}` over a lossy WAN hop with its own sequence space. Gateway keeps a dedup ring (T6) and forwards **with gap markers** — the server must distinguish silence from never-happened. Gateway→core: persistent protobuf/TCP session with heartbeat + resume token (or MQTT-ish pub/sub). Decision to narrate: *ordering is per-drone, not global — partition by `drone_id`, let the routers parallelize.*

**Core.** Fleet-state service holding latest-fix-per-drone in memory (10k × 64 B = 640 KB — say the number) + append-only journal for replay ("what did the picture look like at 14:03?"). The live map is a **convergence display, not a DB read**: server pushes 1 Hz per-viewer diffs (viewport-filtered, delta-encoded); client dead-reckons between fixes. Freshness rule: `age > 3× interval ⇒ grey out, flag position stale` — the UI must degrade visibly, never silently. This *is* the human-oversight story they screen for.

**Failure drills they'll run:** gateway dies mid-burst (drones retry, dedup absorbs); clock skew across drones (never compare cross-drone timestamps without sync — use per-drone monotone age; bring up PTP/GPS time when they ask); 10× fleet growth (partition by region; nothing in the hot path sees the fleet).

**Question to ask them:** "What's the actual radio duty cycle, and is there a return path for ACKs?" — moves the design from idealized to honest.
:::

### S2. "The crop-mold one: 500 rovers in a field, cameras, patchy LoRa, detect mold, alert a human. Edge vs cloud?"

:::answer
The reported prompt — rehearse this one *out loud* at least once.

**Size the data first.** Imagery at even 1 MP/frame dwarfs telemetry by ~1000× — so the answer is **"don't ship pixels you don't have to."** On-vehicle inference (quantized detector on an edge NPU) screens every frame at capture and emits only *candidate events* (bbox, confidence, 64× thumbnail) over LoRa in fragmented bursts. Full-resolution originals upload opportunistically on depot WiFi — the correctness backstop and the retraining corpus.

**Cloud side** aggregates event streams, runs second-pass model + rules (mold needs humidity context → fuse the weather feed), and a **human confirmation queue**. Precision-vs-recall becomes an operational trade with a review-cost budget — that's the interesting conversation.

**Degradations:** radio dead zones (depot batch upload catches everything missed; eventing is at-least-once, dedup at ingest — T6); model drift across seasons (shadow-mode new models beside old, A/B on the confirm queue); rover clock drift (GPS time, per-vehicle monotone sequences).

**Transfer sentence to close:** *"Same skeleton as drone telemetry — a constrained uplink forces edge pre-processing, at-least-once semantics force idempotent ingest, and operator trust forces visible staleness."*
:::

### S3. "Redesign the on-vehicle software stack so a bad model push can't brick a flying drone."

:::answer
The closest to their autonomy work; the safety story matters more than perf.

**Two-box separation** (the real industry pattern): flight-critical autopilot (C/Rust, certified-ish discipline) talks to a payload/compute module (where models live) over a schema'd datalink where the autopilot trusts only *proposals in, authority out*. Model updates ship as **whole-artifact signed images** — no partial writes: A/B partitions + bootloader verdict (the classic embedded answer), verified before activation, automatic rollback on failed health checks.

**Runtime guardrails:** autonomy outputs are *commands within a bounded envelope* (rate/attitude/waypoint limits the autopilot enforces regardless of source); watchdog on the inference heartbeat ⇒ degrade to GPS-hold/return-to-base.

**The sentence that is most of the grade:** *"the model is untrusted input to the flight system."*

If they push on testing: SITL replay of recorded telemetry through the new build, HITL on the bench rig, property tests on the envelope math — mirroring how their own CI has to look (their JD name-drops SITL/HITL, so they will).
:::

## How to use this against the crate

```bash
cd ~/.dotfiles/sites/kakashi/drills
export CARGO_HOME=$PWD/.cargo RUSTUP_HOME=$PWD/.rustup
nix shell nixpkgs#cargo nixpkgs#rustc nixpkgs#gcc --command cargo test
# test result: ok. 13 passed; 0 failed
```

Drill protocol for the two coding rounds: **T5 + T6 are your timed set-pieces** (target: cold, bare editor, ≤20 min each including tests). T1–T3 are verbal-reasoning drills — answer them out loud in the shower; they're the questions that follow every code round. For S1–S3, whiteboard the boxes before touching any detail, and finish each by walking **one arrow in the diagram and naming its three failure modes** — that habit is what "systems fit" means at this company.
