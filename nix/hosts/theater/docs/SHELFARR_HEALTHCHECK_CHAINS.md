# Shelfarr: runaway HealthCheckJob chains

**Fixed:** 2026-08-24. **Status:** symptom cleared locally; upstream bug still present.

## Symptom

Shelfarr was the #2 log producer on the box — ~300k journal lines per 2 days —
almost all of it:

```
[ActiveJob] [HealthCheckJob] [...] [HardcoverClient] Rate limit exceeded
[ActiveJob] [HealthCheckJob] [...] [HardcoverClient] Connection test failed: Rate limit exceeded (60 requests/minute)
```

8,320 rate-limit errors in 24h, arriving in bursts of 8 every few seconds.

The trap: **nothing looks broken.** The container is up, the web UI works, and
`health_check_interval` in the settings table reads a perfectly sane `300`
(5 minutes). Uptime Kuma and `stack-healthcheck.sh` both stay green throughout.

## Root cause

`HealthCheckJob` schedules its own successor. From
`app/jobs/health_check_job.rb:234`:

```ruby
def schedule_next_run
  interval = SettingsService.get(:health_check_interval, default: 300)
  HealthCheckJob.set(wait: interval.seconds).perform_later
end
```

One chain is seeded at boot, from `config/initializers/health_check.rb:21`:

```ruby
Rails.logger.info "[Shelfarr] Starting HealthCheckJob chain"
HealthCheckJob.perform_later
```

The bug is the interaction of two facts:

1. The chain lives in SolidQueue, which is **SQLite on a persistent volume**
   (`${APPDATA_DIR}/shelfarr:/rails/storage`). Pending jobs survive restarts.
2. The initializer runs unconditionally on **every** boot and never checks
   whether a chain is already pending.

So every container start adds one more permanent, self-perpetuating chain.
Nothing ever removes one. With N chains each firing every 300s, the effective
rate is N checks per interval — at N=48 that is a burst every ~6 seconds, which
is what blew past Hardcover's 60 req/min limit.

Watchtower updates this container, so each update quietly added a chain.

## Diagnosis (how to confirm it recurred)

Count pending chains. Healthy is `1`:

```bash
docker exec shelfarr sh -c \
  'sqlite3 /rails/storage/production_queue.sqlite3 \
   "SELECT COUNT(*) FROM solid_queue_scheduled_executions se
      JOIN solid_queue_jobs j ON j.id = se.job_id
     WHERE j.class_name = \"HealthCheckJob\";"'
```

Cross-checks that were decisive during the original diagnosis:

- **Job-row ratio.** Compare `HealthCheckJob` against a known-good 5-minute
  recurring job. They should be roughly equal. At the time of the fix it was
  14,069 vs 297 for `RequestQueueJob` — a 47x tell.
  ```bash
  docker exec shelfarr sh -c \
    'sqlite3 /rails/storage/production_queue.sqlite3 \
     "SELECT class_name, COUNT(*) FROM solid_queue_jobs
       GROUP BY class_name ORDER BY 2 DESC LIMIT 8;"'
  ```
- **Execution rate.** Should be exactly 1 per 5 minutes.
  ```bash
  journalctl CONTAINER_NAME=shelfarr --since "6 minutes ago" -o short-iso \
    | grep "Performing HealthCheckJob" | cut -c1-16 | uniq -c
  ```
- **`HealthCheckJob` is not in `solid_queue_recurring_tasks`** and never will
  be. It is not a registered recurring task; it is a self-perpetuating chain.
  Do not "fix" this by adding it there.

### Dead ends, so nobody re-walks them

- **The API token is fine.** `hardcover_api_token` is set and valid. The 429s
  are pure call volume.
- **`health_check_interval` is fine at 300.** Lowering it changes nothing; the
  multiplier is the chain count, not the interval.
- **`admin/settings_controller.rb` is innocent.** It calls
  `HealthCheckJob.perform_later(service: ...)` *with* an argument, which routes
  to `run_check_for` and does **not** call `schedule_next_run`. Only the
  argument-less form self-schedules.
- **`dashboard_controller.rb:18` is a red herring.** It is argument-less, but
  behind `POST /admin/run_health_check` — not reachable from page loads or
  monitoring GETs. Chains grew from 2 to dozens within two minutes of boot with
  nobody clicking anything.
- **A plain `docker restart` makes it worse, not better.** The old chains
  persist and boot adds one. Observed live: 48 -> 49.

## The fix

Delete every pending `HealthCheckJob` while the container is **stopped**, then
start it and let the initializer seed exactly one clean chain.

Stopping first matters: SQLite is in WAL mode and SolidQueue writes constantly.
Editing it live risks corruption, and the workers would immediately re-enqueue.

```bash
docker compose stop shelfarr

cp /docker/appdata/shelfarr/production_queue.sqlite3 \
   /tmp/shelfarr-queue-backup-$(date +%Y%m%d).sqlite3

sqlite3 /docker/appdata/shelfarr/production_queue.sqlite3 "
  DELETE FROM solid_queue_scheduled_executions
   WHERE job_id IN (SELECT id FROM solid_queue_jobs
                     WHERE class_name = 'HealthCheckJob');
  DELETE FROM solid_queue_ready_executions
   WHERE job_id IN (SELECT id FROM solid_queue_jobs
                     WHERE class_name = 'HealthCheckJob');
  DELETE FROM solid_queue_jobs
   WHERE class_name = 'HealthCheckJob' AND finished_at IS NULL;
"

docker compose start shelfarr
```

Only unfinished jobs are deleted; finished rows are history and shelfarr's own
hourly `clear_solid_queue_finished_jobs` task prunes them.

### Verification

After ~6 minutes, all three should hold:

| Check | Expected |
|---|---|
| Pending `HealthCheckJob` chains | `1` |
| `Performing HealthCheckJob` in 5 min | `1` |
| `Starting HealthCheckJob chain` since restart | `1` |

Measured after the fix: 1 chain, 1 execution per 5 min, rate-limit errors down
from 8,320/day to ~576/day.

## Known remaining issue

A **single** health check still trips the Hardcover rate limit — one execution
produces ~2 `Rate limit exceeded` lines, because `check_hardcover` makes several
calls in quick succession against a 60 req/min budget. This is upstream
behaviour and is now a minor annoyance rather than a log flood. Left alone
deliberately.

## This will come back

Nothing prevents regrowth. Every `docker compose up`, host reboot, or watchtower
update adds a chain. Expect roughly +1 per restart, so it degrades slowly and
silently.

A durable fix belongs upstream in
[`pedro-revez-silva/shelfarr`](https://github.com/pedro-revez-silva/shelfarr) —
the initializer should not seed a chain when one is already pending, e.g.

```ruby
pending = SolidQueue::Job.where(class_name: "HealthCheckJob", finished_at: nil)
HealthCheckJob.perform_later if pending.none?
```

As of the fix date no issue had been filed. **A local systemd prune timer was
considered and deliberately declined** — re-propose it only if asked.

## Why the existing monitoring missed this

Worth internalising, because it generalises to the rest of the stack.

`stack-healthcheck.sh` catches specific *known* silent failures (VPN leak,
unmounted bay, MAM session). Uptime Kuma catches *reachability*. This failure was
neither: the service was up, correct, and answering — just doing the same correct
thing 48 times too often. The only signal was log volume, which nothing was
watching.

That gap is the reason for the Loki/Alloy/Grafana work: a rate-based alert
("errors from any container exceed N/min") catches this whole class generically,
without having to predict the specific failure in advance.

## Related

- Log-volume investigation that surfaced this: journald was at 4.1G/28d
  unbounded; `SystemMaxUse=2G` added in `default.nix`.
- Backups from the fix (delete when comfortable):
  `/tmp/shelfarr-queue-backup-clean-20260824.sqlite3`
