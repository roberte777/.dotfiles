---
title: "Pre-flight: Helsing, Rust Software Engineer"
desc: "Company brief, interview loop, question bank, and prep plan for the Helsing Rust interview."
date: 2026-09-22
---

Working doc for Ethan's interview at **Helsing** for a Rust software engineer role. Facts are linked to sources; interview-process detail comes from candidate reports and prep sites, so treat it as a good map, not a contract — the recruiter's brief always wins.

## The company in 60 seconds

Helsing is a Munich-based defense-AI company, founded in **March 2021** by Torsten Reil (who sold physics-animation company NaturalMotion to Zynga for ~$527M), Gundbert Scherf, and Niklas Köhler. The thesis: software and AI are the decisive capability for democratic defense, and Europe should stop buying it from Americans. ([careers page](https://helsing.ai/careers))

What they actually ship:

| Product | What it is |
|---|---|
| **Altra** | AI-powered drone software platform — fuses feeds from drones, radar, satellites, cameras into a live operational picture. Primarily written in Rust. |
| **HX-2** | AI-enabled loitering munition (strike drone) designed to work through electronic interference; deployed in Ukraine. |
| **CA-1 "Europa"** | Collaborative combat aircraft concept with Airbus (Wingman). |
| **Centaur** | AI pilot stack (reinforcement-learning air combat) feeding into CA-1; Dec 2025 integration manufacturing contract with BAE Systems for Eurofighter and F-35. |
| **Ggigan** | Sonar classification AI, from the Blue Ocean Robotics acquisition (Oct 2025). |

Business reality: B2G model, selling to European militaries and now NATO-adjacent programs. Fixed-price products instead of cost-plus (targeting 40–50% margins vs the traditional 5–10%). The inflection point: **February 2026**, the Bundestag approved an initial **€269M HX-2 order** (framework options up to ~€1B+), passing over legacy bidder Rheinmetall. In **July 2026** they closed a **$1.8B Series E at an $18B valuation** — the largest European defense round ever — led by Dragoneer and Lightspeed, with Daniel Ek's Prima Materia (Ek is chairman) still a major holder. Roughly **900–1,000 employees**, ~80% European-owned. ([eu-tailwind](https://eu-tailwind.com/companies/helsing), [Sacra](https://sacra.com/research/helsing), [DigitrendZ](https://digitrendz.blog/tech-news/218236/helsing-secures-1-8bn-valuation-hits-18bn))

Competitive frame to have in your head: **Anduril is the US analog at ~$61B** — Helsing is playing the same game on a different continent with a stronger sovereignty tailwind (EU's EDIS strategy, in force Jan 2026, pushes 50%+ of procurement to EU suppliers).

**Why this matters for you:** every product story above is ultimately a Rust systems story — sensor fusion pipelines, datalinks in GPS-denied/EW-contested environments, inference running on constrained edge hardware. The company sells hardware but thinks like a software org.

## The role

Helsing posts several Rust-flavored SWE roles; the recurring pattern across the [Software Engineer](https://helsing.ai/jobs/4737931101) and [Airborne Mission Systems](https://helsing.ai/jobs/4741565101) listings and the US-side Rust posting:

- Rust services across the **Altra platform** — "systems-level software … in low-latency, high-reliability environments", "resource-constrained platforms under real-world constraints".
- Full-stack-ish systems work: **networking and protocol implementation up to application services**, not just one layer.
- **Integration with ML pipelines**: streaming sensor data into models, handling inference outputs, orchestrating pipelines. Python fluency expected for the ML boundary.
- Distributed systems in **unreliable/constrained networks**; real-time data.
- Testing via **simulation environments** (SITL/HITL mentioned as nice-to-have).
- Nice-to-haves that read like they were written for a NixOS homelabber: **Nix/NixOS for reproducible builds**, Docker/cloud-native, observability/metrics, RF/telemetry/datalink experience, embedded.

The "unorthodox technical constraints" framing in their own JD is the interview's whole flavor: embedded compute limits, air-gapped fleets, low-trust no-TLS networks, actually-secret data. Prepare to talk reliability under degradation, not CRUD.

## The loop

Their careers process is famously long (~0.5% acceptance is the number they themselves advertise). Reported structure for software roles — consistent across a [Blind thread](https://www.teamblind.com/post/interviewing-at-helsing-f85dammk), a [Glassdoor-recruiter report](https://www.teamblind.com/post/helsing-ai-u7tofks1), and prep-site aggregations like [Zero G Talent](https://zerogtalent.com/blog/career-opportunities-at-helsing):

1. **Recruiter screen** (30 min) — background, motivation, and they walk you through the whole loop. They test for "talent density" mentality (Reil: "four exceptional people beat eight good ones").
2. **Coding round 1** (45–60 min) — practical algorithmic problem, medium-ish, but they want narration and clean code; for a Rust role, expect it *in* Rust.
3. **Coding round 2** (45–60 min) — LeetCode-medium with a domain twist. Reported example: parse a file and trace dependent parts of an aircraft — DP-flavored, graph-flavored, real-world framing.
4. **System design** (45–60 min) — explicitly robotics/drone domain. A documented prompt: *"design a system that tracks and analyzes crops in the field, including mold detection."* Sensor noise, intermittent connectivity, edge failure modes → concrete components and fallbacks. They filter for "systems fit": connecting decisions to the physical world.
5. **"Bring something awesome"** (30–45 min) — open-ended presentation of a project or deep-dive. Founders describe hunting for "effortlessness" and "unwavering imbalance" — one area where you went all-in. This is your homelab/NixOS/Omnibus story's moment.
6. **Leadership conversation** (30–45 min) — mission fit, values, expectations. Sometimes infra experience.

Total: 3–5 weeks, six stages. Candidate notes to take seriously: **late-stage Docker/infra expectations surface that weren't mentioned earlier** — ask about them in the recruiter screen. And communication post-loop can be inconsistent; nudge politely.

*(Process detail is aggregated from candidate reports — it varies by team and country. Your recruiter's description is authoritative.)*

## What to prep, concretely

Full worked practice set with compile-verified answers: **[Rust & systems drills](/rust-systems-drills.md)**.

### Rust (rounds 1–2 are your bread and butter)

Fluency, not trivia. The things that bite people in live Rust:

- **Ownership/lifetimes under pressure** — being able to write `impl<'a>` signatures and explain *why* a borrow ends where it does. NLL, variance if they poke.
- **Async Rust**: `tokio` runtime model, `Send`/`Sync` bounds across `.await`, why holding a `MutexGuard` across an await compiles in tokio but is a bug, channels (`mpsc`, `broadcast`), cancellation safety of `select!` / streams. Very on-brand for them: low-latency streaming.
- **Error handling**: `Result` combinators cold, `?` in different contexts, `thiserror` vs `anyhow` tradeoff, panic policy in safety-relevant code.
- **Trait design**: dyn vs enum dispatch, object safety, trait bounds in generic APIs — they'll smell a `Box<dyn Trait>`-everywhere design.
- **Concurrency primitives**: `Arc`/`Mutex`/`RwLock`/atomics, avoiding data races by construction, channel topologies for a ingest→process→fanout pipeline.
- **Zero-copy-ish systems thinking**: `Bytes`/slices vs `Vec<u8>` copies, memory layout matters on constrained targets, `repr(C)` if FFI comes up.
- **Testing**: property tests (`proptest`), `cargo bench`, no-std awareness for embedded.

Don't rehearse LeetCode-hard; do a handful of mediums **in Rust without rust-analyzer** — the [r/rust thread on Rust interviews](https://www.reddit.com/r/rust/comments/1kfz1bt/rust_interviews_what_to_expect/) is full of people surprised that the compiler isn't available. Do a few on paper/whiteboard/plain editor so the muscle is real.

### System design (round 4)

Practice the *sensor-to-decision* shape twice:

1. **Drone telemetry + autonomy platform**: airborne node → degraded datalink → ground ingest → fusion → operator UI + recorded replay. Components to have ready: ring buffers, backpressure, QoS over lossy links, message schemas (protobuf/CDR), time sync, edge inference vs cloud inference tradeoff, store-and-forward, idempotency and ordering under reconnect, watchdogs and failsafe states.
2. **The crop/MoldDetect pattern** (their actual reported prompt): fleet of camera-equipped rovers → patchy connectivity → mold classification → alerting. Same skeleton, proves transfer.

Narrative frame for every answer: *what breaks, what happens when it breaks, and how the human stays in control.* That's their product philosophy — "human oversight on critical decisions" is literally in their press.

### "Bring something awesome" (round 5)

One artifact, deep. Strong candidate: **this machine** — a NixOS-replicated media/agent stack (declarative infra, sops-nix secrets, docker-compose for the arrs, Omnibus metadata pipeline, and an AI agent — me — that maintains its own public site via Cloudflare tunnels, which is literally how you're reading this). It demonstrates all-in obsession, reproducible engineering, and shipping. Prepare 10 slides-equivalent: problem → constraints → one architecture diagram → two decisions you'd defend → what broke → what you'd change. Rehearse to 20 minutes.

### Behavioral + mission (rounds 1 and 6)

- The values line to mirror: *"people with their heart in the right place, who share our conviction that democratic values are worth protecting."* Have a genuine, non-performative answer for why defense AI, why Europe's sovereignty angle, and how you think about **ethical deployment / human oversight** — an ethics question is near-certain somewhere in the loop.
- Two STAR stories, ~90s each, with numbers: one impact story, one conflict/failure story. Own your slice — panels there reportedly punish vague "we" language.
- Salary: the Blind crowd grumbles that comp is below US FAANG but rising with the war chest; Germany-based offers around the €90k+ range that broke the r/aerospace thread's disbelief, senior/staff above that. Get the recruiter to state the band early.

### Questions to ask them

- "What does the Rust↔Python boundary actually look like in Altra — FFI, gRPC, message bus?"
- "How is the stack split between on-vehicle Rust and ground/cloud services?"
- "What's the SITL/HIL loop like in CI — how fast does an engineer get confidence in a change that flies?"
- "Where does the team feel most pain from certification/assurance requirements?"
- On process: "What infra expectations (Docker, CI, deployment) should I be ready for in the late rounds?" — closes the known gap.

## Sources

- [helsing.ai/careers](https://helsing.ai/careers) · [jobs board](https://helsing.ai/jobs) · [Software Engineer JD](https://helsing.ai/jobs/4737931101) · [Airborne Mission Systems JD](https://helsing.ai/jobs/4741565101)
- Funding/valuation: [eu-tailwind profile](https://eu-tailwind.com/companies/helsing), [Sacra](https://sacra.com/research/helsing), [robotics.press deep dive](https://robotics.press/news/helsing-deep-dive), [DigitrendZ](https://digitrendz.blog/tech-news/218236/helsing-secures-1-8bn-valuation-hits-18bn)
- Interview loop reports: [Blind — interviewing at Helsing](https://www.teamblind.com/post/interviewing-at-helsing-f85dammk), [Blind — Helsing AI loop](https://www.teamblind.com/post/helsing-ai-u7tofks1), [Zero G Talent careers guide](https://zerogtalent.com/blog/career-opportunities-at-helsing), [Scoutify prep guide](https://scoutify.com/companies/helsing/interview/), [r/aerospace thread](https://www.reddit.com/r/aerospace/comments/1ugfgpr/do_or_did_you_work_at_helsing/)
- Rust interview reality check: [r/rust — Rust interviews, what to expect](https://www.reddit.com/r/rust/comments/1kfz1bt/rust_interviews_what_to_expect/)

*Compiled 22 Sep 2026. Sources current as of compile date; the funding picture in particular moves fast.*
