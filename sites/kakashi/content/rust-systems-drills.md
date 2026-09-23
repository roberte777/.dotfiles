---
title: "Drills: Rust technical + systems questions"
desc: "Interview questions with worked, compile-verified answers. Practice mode: question first, answer below."
date: 2026-09-22
---

Companion to [the Helsing pre-flight](/helsing-rust-interview.md). Every code answer on this page **compiles and passes tests** — the crate lives at `~/.dotfiles/sites/kakashi/drills/` (rustc 1.91, tokio 1.53; run `cargo test`). Practice protocol: read the question, close the tab section, write it out or type it cold in a bare editor (no rust-analyzer — that's the interview condition), then diff against the reference.

## Part 1 — Language & async technicals

### T1. Why can't you hold a `std::sync::MutexGuard` across an `.await`? Show the failure and all three fixes.

**Answer:** The guard isn't `Send`. A future that holds it across an await point can resume on a different worker thread, so the future itself stops being `Send` — and `tokio::spawn` requires `Send` futures. `rustc` rejects it with *"future cannot be sent between threads safely"* at the spawn boundary, not at the lock line, which is what makes it bite people live.

The three fixes, in preference order:

1. **Shrink the critical section** — lock, read/write, drop, *then* await. Usually right; sync locks are faster.
2. **`tokio::sync::Mutex`** — the async lock whose guard is `Send`; use only when the lock genuinely must span await. Cost: every acquire is a possible yield point, so it serializes the executor lane it protects.
3. **Restructure with message passing** — move the data behind an actor task and talk over channels. Right answer when two awaits need to coordinate on the same state.

Reference implementations: `fixed_scoped` (pattern 1) and `fixed_tokio_mutex` (pattern 2) in the drills crate.

### T2. `select!` on a channel receive vs a shutdown signal — what's the cancellation-safety trap?

**Answer:** `select!` polls branches and **drops the losing futures**. That's fine for `mpsc::Receiver::recv()` (it's cancellation-safe: the message stays queued), but NOT for non-idempotent futures: a future that already consumed a message or half-sent a reply when it loses has side-effected the world without you knowing. Rules to say out loud:

- Know which operations are cancellation-safe (`recv` yes; a hand-rolled async fn that pulls then processes — no, unless you wrote it to requeue).
- After winning a race, re-check shared shutdown state — permit-acquired-then-shutdown is a real interleaving; the drills crate's `bounded_transform` needed exactly that re-check (a test caught it the first time without).
- Prefer `JoinHandle::abort()` + structured shutdown (watch channel for broadcast, dropping `Sender` for drain) over scattering cancel flags.

### T3. Semaphore-bounded fan-out with cancellation — write it.

**Answer:** the shape of the round-2 coding test, probably. Skeleton (full compile-verified version with 4 tests in `drills/src/lib.rs`):

```rust
let sem = Arc::new(Semaphore::new(k));
for item in items {
    let (sem, mut shutdown) = (sem.clone(), rx.clone());
    handles.push(tokio::spawn(async move {
        let permit = tokio::select! {
            p = sem.acquire() => p.expect("closed"),
            _ = shutdown.changed() => return None,
        };
        if *shutdown.borrow() { return None; }  // re-check after acquire
        let out = process(item).await;
        drop(permit);                            // explicit scope
        Some(out)
    }));
}
```

Talking points interviewers fish for here: why `Arc<Semaphore>` (permits must outlive the borrow), why the `select!` on `acquire()` needs the re-check (race above), why `drop(permit)` is explicit (documents the critical section; `forbid` the accidental `std::sync::MutexGuard`-style leak), and the **backpressure question they always follow with**: bounded semaphore = backpressure at the *dispatcher*; an mpsc channel of capacity K gives the same bound with a queue for free — trade is memory vs fast-fail.

### T4. Walk `Bytes` vs `Vec<u8>` vs `&[u8]` for a network receive path. Where do copies hide?

**Answer:** Receive into a reusable `BytesMut` (`bytes` crate); freeze to `Bytes` for handoff — `Bytes::clone` is a refcount bump, no memcpy, and it's the standard zero-copy pipeline currency (axum, tonic, tokio-util all speak it). `Vec<u8>` gets you one allocation per message and forces a real clone on every fan-out. `&[u8]` is zero-copy but *bounded by the borrow* — great for a parser that finishes inside one read (see T5), wrong when frames must outlive the socket buffer. The hidden copy to name: `to_vec()`/`Bytes::copy_from_slice` at the boundary is the memcpy you're trying to avoid; the trick is that a stream framing layer (`tokio_util::codec`) keeps one growing buffer and hands out `Bytes` slices that share its allocation — a `split()` doesn't copy, it re-points.

### T5. Write a zero-copy parser for length-prefixed frames `[0xA5][len u16 LE][payload][sum8]` that returns borrowed frames plus the unconsumed tail.

**Answer:** in the crate as `parse_frames` — 30 lines, and its test asserts pointer identity (`std::ptr::eq(frames[0].as_ptr(), &buf[3])`) to *prove* zero-copy. The things to narrate while writing it:

- Return `Vec<&[u8]>` borrowed from the input `&[u8]` — the borrow checker gives you the "don't return garbage" guarantee for free; the tail is just `&buf[pos..]`.
- Distinguish *incomplete* (not an error — waiting for more bytes) from *corrupt* (hard error: sync byte wrong, checksum mismatch). This framing is exactly what they want to hear from anyone touching a datalink.
- `u16::from_le_bytes([b[1], b[2]])` — say "endian is part of the protocol; never `transmute`."
- Follow-up they love: *what if payload length is attacker-controlled?* → reject `len > max_frame` **before** allocating/slicing; DoS via `len: 65535` on a 40-byte datagram is the classic embedded bug.

### T6. Deduplicating a lossy, out-of-order telemetry stream: sequence numbers arrive at ~1 Hz with reordering and repeats, link can drop for minutes.

**Answer:** sliding-window set (`SeqDedup` in the crate, 3 tests): keep `highest` seen; accept seq if `>= highest - window`; `HashSet::insert` returning false ⇒ duplicate; on new high, `retain`-prune entries below the cutoff. Then say the parts that make it real: **wraparound** (u64 buys you ~585 years at 1 Hz — say the math; with u32 use serial-number arithmetic mod 2³²), **restart** (stream resets at 0: detect with a bootstrap rule, e.g. "seq far below window ⇒ epoch bump, not drop"), and the **design-interview upgrade** — dedup is usually not set-based at scale; it's (producer, stream-id) keyed, and the storage question (in-RAM set vs RocksDB vs bloom-filter-fast-path-with-exact-verification) is the actual systems discussion.

### T7. `Arc<Vec<T>>` clone in a hot loop — what actually happens? Make it O(1).

**Answer:** `Arc::clone` bumps a refcount (one atomic store, cache-line ping-pong across cores is the only cost) and copies a pointer — it's O(1) *for the Arc itself*, but `&inner` requires no deref-copy at all. The O(n) accident people mean is `(*arc).clone()` — note the deref — cloning the `Vec`. Fixes to name: `Arc::make_mut` for copy-on-write mutation (clones only when refcount > 1), `ArcSwap` (arc-swap crate) for read-mostly shared config/roadmaps — readers take a lock-free snapshot, writers publish a whole new Arc; the pattern fits exactly Helsing's "push new model to edge node" story.

### T8. You need to add a field to a struct passed to 40 tasks. Why might the compiler *still* force a clone you can't remove?

**Answer:** because `&T` across `spawn` needs a lifetime that outlives the future, and `'static` kills borrows — every `tokio::spawn` body must own everything it touches (that's the real reason channels everywhere carry `Arc<Config>` not `&Config`). Worked-example bonus: the drills crate's own test hit `E0382` (`Arc` moved into first task, borrowed after) — the fix conversation (`clone` cheaply? restructure? `scope`?) is precisely what T1/T7 rehearse.

### T9. Quick-fire set — have one-liners loaded

- **`Box<dyn Error>` vs `enum thiserror` at a crate boundary?** enum for APIs callers must branch on; boxed for error soup across many modules; `anyhow` in binaries/`main`.
- **Why does `#[derive(Clone)]` bite on a struct holding an `Rc<RefCell<_>>`?** shallow clone shares the `RefCell` — mutations leak between "copies"; that's why the std version is `Arc<Mutex<_>>` or `Arc<RwLock<_>>`.
- **Variance:** `Box<&'a T>` is covariant in `'a`, `&mut T` invariant — so `Vec<&'static str>` upgrades where `RefCell<&'a str>` won't. (Know one example each; don't bluff more.)
- **Panics:** `catch_unwind` ≠ error handling; a panic in a tokio task poisons the join handle — `t.await??` double-? pattern (join error, then task error) is the systems answer.
- **Faster path than `Mutex<HashMap>` for sharded state?** split the map (per-core shards, DashMap), or make writes single-threaded and reads snapshot (`ArcSwap`) — say "measure first."

## Part 2 — Systems design scenarios

Their documented prompts are drone/robotics-domain (reported example: crop-tracking + mold detection). All three below share the skeleton to internalize: **source → constrained link → ingest → processing → consumer, with degradation modes on every arrow.**

### S1. "Design drone telemetry: 10k drones, 1 Hz GPS/attitude/battery, unreliable link, operators need a live map with <2s latency."

Reference walkthrough (≈35 min answer):

**Requirements to state first:** 10k × 1 msg/s ≈ 110 msg/s total — *tiny* for the backend, so the hard part is NOT throughput; it's the radio path, correctness under loss, and the freshness semantics. Saying "let me check what the load actually is before I pick Kafka" wins points.

**Uplink.** Each drone batches frames (T5 parser) into short burst transmissions; sequence numbers + epoch per flight (T6). Link layer gets store-and-forward with on-device replay buffer (survive minutes of silence — say the size: 1 Hz × 200 B × 15 min ≈ 180 KB/drone, trivially on-device). No TLS on the mesh (their own JD: "low-trust, no-TLS networks") → per-message signing at the application layer, replay windows double as anti-replay.

**Ingest.** Ground gateway per region: stateless decoder → validates → pushes `{drone_id, seq, fix, quality}` on a lossy WAN hop with its own sequence space. Gateway keeps a dedup ring (T6) and forwards **with gap markers**, not silently — end-to-end the server must learn about silence explicitly vs never-happened. Gateway→core: MQTT-ish pub/sub or protobuf over a persistent TCP session with heartbeat + resume-token; the decision to narrate: *ordering is per-drone, not global — partition by drone_id and let the routers parallelize.*

**Core.** A fleet-state service holding latest-fix-per-drone in memory (10k × 64 B — say the number, it's 640 KB) + append-only journal for replay ("what did the picture look like at 14:03?"). The live map is a **convergence display, not a database read**: server pushes 1 Hz per-viewer diffs (only drones in viewport, delta-encoded), client dead-reckons between fixes. Freshness rule per drone: `age > 3× interval ⇒ grey out + flag last position as stale` — the operator UI must degrade visibly, never silently. This *is* the human-oversight story they screen for.

**Failure drills they'll run:** gateway dies mid-burst (drones retry, dedup absorbs), clock skew between drones (never compare cross-drone timestamps without sync; use monotone age per-drone — bring up PTP/GPS time when they ask), 10× burst of drones (per-partition by region; nothing in the hot path sees the fleet).

**The question to ask them:** "What's the actual radio duty cycle and is there a return path for ACKs?" — forces the design from idealized to honest.

### S2. "The crop-mold one: 500 rovers in a field, cameras, patchy LoRa, detect mold, alert a human. Edge vs cloud?"

Reference walkthrough — this is the reported prompt, so rehearse it *out loud* once:

Start by sizing the data: imagery at even 1 MP/frame dwarfs telemetry by 1000× — **the answer is "don't ship pixels you don't have to."** On-vehicle inference (quantized detector, T4/edge-NPU class) runs every frame at capture, emits only *candidate events* (bbox, confidence, 64× thumbnail crop) over LoRa as fragmented bursts; full-resolution originals are uploaded opportunistically on WiFi at the depot for the record and for model retraining. Cloud side aggregates event streams, runs a second-pass model + rules (mold needs humidity context → fuse weather feed), and a human queue for confirmations — precision-vs-recall becomes an *operational* trade with a review-cost budget, which is the interesting conversation. Degradations: radio dead zones (depot batch upload is the correctness backstop — eventing is at-least-once, dedup at ingest, T6), model drift across seasons (shadow-mode new models against old, A/B on the confirm queue), rover clock drift (GPS time; per-vehicle monotone sequences).

Transfer sentence to close: *"same skeleton as drone telemetry — constrained uplink forces edge pre-processing, at-least-once semantics force idempotent ingest, and operator trust forces visible staleness."*

### S3. "Redesign the on-vehicle software stack so a bad model push can't brick a flying drone."

Reference walkthrough — closest to their autonomy work; the safety story matters more than perf:

**Two-box separation** (real pattern in this industry): flight-critical autopilot (often C/Rust, certified-ish discipline) talks to a payload/compute module (where models live) over a **one-way-ish, schema'd datalink** — the autopilot only trusts: *proposals in, authority out.* Model updates land as **whole-artifact signed images** (no partial writes: A/B partitions + bootloader verdict — the classic embedded answer), verified before activation, with automatic rollback on health-check failure. Runtime guardrails: autonomy outputs are *commands within a bounded envelope* (rate/attitude/waypoint limits the autopilot enforces regardless of source), watchdog on inference heartbeat ⇒ degrade to GPS-hold/RTB. Say the framing they want: **"the model is untrusted input to the flight system"** — that single sentence is most of the grade. If they push on testing: SITL replay of recorded telemetry through the new build, HITL on the bench rig, property tests on the envelope math — mirroring exactly how their own CI must look.

## How to use this against the crate

```bash
cd ~/.dotfiles/sites/kakashi/drills
nix shell nixpkgs#cargo nixpkgs#rustc nixpkgs#gcc
cargo test              # 10 tests, all green
```

Drill protocol for the two coding rounds: T5 + T6 are your timed set-pieces (target: cold, bare editor, ≤20 min each including tests). T1–T3 are verbal-reasoning drills — answer them out loud in the shower, they're the questions that follow every code round. For S1–S3, whiteboard the boxes before touching any detail, and finish each by walking **one arrow in the diagram and listing its three failure modes** — that habit is what "systems fit" means at this company.
