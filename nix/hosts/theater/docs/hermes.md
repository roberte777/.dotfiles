# Hermes Agent

Nous Research's personal agent, reachable from Discord and Telegram.

Runs as a **home-manager user service** under `theater`, not as a hardened
system service. The agent therefore inherits this user's reach: the dotfiles
repo, `~/.ssh`, every checkout in `~`. That is the point -- it can work on real
files -- but it means the allowlists below are the only thing standing between a
Discord message and this user's shell. Add people deliberately.

Upstream marks Nix a **Tier 2 / best-effort** platform and warns that commits to
`main` may break the packages. This input **tracks `main`**, so a rebuild can
break through no change of yours -- roll back by pinning a rev in the `url`.
It also follows `nixpkgs-unstable` (it needs `nodejs_26`, absent from our 25.11
pin), which means updating `nixpkgs-unstable` can break Hermes on its own.

## Layout

| Thing | Where |
|---|---|
| Module | `nix/modules/home/hermes.nix` |
| Flake input | `nix/flake.nix` (tracks main) |
| `HERMES_HOME` | `~/.hermes` |
| Secrets (encrypted) | `nix/secrets/theater.yaml` |
| Secrets (decrypted) | `/run/secrets/hermes-env` |
| Key policy | `nix/.sops.yaml` |
| Age key (private) | `~/.config/sops/age/keys.txt` -- **not in git**, back it up |
| Logs | `journalctl --user -u hermes-agent -f` |

## Secrets

Managed with **sops-nix**. `nix/secrets/theater.yaml` is encrypted and *is*
committed; sops-nix decrypts it to `/run/secrets/hermes-env` at boot, owned by
`theater`. Never put plaintext keys in the `.nix` files -- `/nix/store` is
world-readable.

### The age key

The identity is a standalone age key:

```
~/.config/sops/age/keys.txt        mode 0600, NOT in this repo
```

**Back it up** (password manager, offline media). Lose it and every secret here
is unrecoverable; leak it and every secret here is compromised. It is
deliberately outside the repo -- a key committed beside the file it decrypts
offers no protection, and pushing it would publish these secrets permanently.

Its public half is recorded in `nix/.sops.yaml`. To manage secrets from another
machine, copy `keys.txt` there by hand, or generate a second key and add it:

```bash
age-keygen -o ~/.config/sops/age/keys.txt    # on the other machine
# add its public key to nix/.sops.yaml, then re-encrypt:
sops updatekeys secrets/theater.yaml
```

Adding a recipient to `.sops.yaml` does **not** re-encrypt existing files;
`updatekeys` is what applies it.

Activation runs as root and reads the key at the path above, so **the key must
exist before `nixos-rebuild switch`** or activation fails.

### Editing

Opens `$EDITOR` on the decrypted contents, re-encrypts on save. No `sudo`:

```bash
cd ~/.dotfiles/nix
sops secrets/theater.yaml
```

The file currently holds placeholders. Replace each `REPLACE_ME`:

```yaml
hermes-env: |
    OPENCODE_API_KEY=...
    DISCORD_BOT_TOKEN=...
    DISCORD_ALLOWED_USERS=your-discord-user-id
    TELEGRAM_BOT_TOKEN=123456789:ABCdef...
    TELEGRAM_ALLOWED_USERS=your-telegram-user-id
```

Keep the `|` block and its indentation -- the value is one multi-line string,
and `environmentFiles` merges it into `~/.hermes/.env` verbatim.

Verify it decrypts before rebuilding:

```bash
sops -d secrets/theater.yaml
```

**Both gateways fail closed.** With no `*_ALLOWED_USERS` set, the bot connects,
shows as online, and denies every single message. If it is online but mute,
check the allowlist before anything else.

## Model provider

OpenCode Go -- a flat $10/mo subscription, rather than per-token billing. Sign
in at <https://opencode.ai/auth>, subscribe to Go, copy the key into
`OPENCODE_API_KEY`.

It is an OpenAI-compatible endpoint, registered in
`nix/modules/home/hermes.nix` as a named custom provider:

```
api       https://opencode.ai/zen/go/v1
transport chat_completions
default   qwen3.8-flash
```

Switch models mid-session without editing Nix:

```
/model custom:opencode:kimi-k2.7-code
```

Current catalogue (34+ models): `https://opencode.ai/zen/go/v1/models`. Note
upstream frames Go as being "for OpenCode and other coding agents that produce
similar types of requests" -- Hermes is an agent of that shape, but this is
their service and their terms, not a contract.

To go back to Anthropic instead, set `model.default = "anthropic/claude-*"`,
drop the `providers.opencode` block, and swap the key for `ANTHROPIC_API_KEY`.

## Discord bot

1. <https://discord.com/developers/applications> -> **New Application**.
2. **Bot** tab. Under **Privileged Gateway Intents** enable:
   - **Message Content Intent** -- without it the bot *cannot read your
     messages*. This is the #1 cause of a silent bot.
   - **Server Members Intent** -- username resolution.
3. **Reset Token**, copy it immediately (shown once) -> `DISCORD_BOT_TOKEN`.
4. Invite it. Scopes `bot` + `applications.commands`; permissions: View
   Channels, Send Messages, Read Message History, Attach Files, Embed Links
   (plus Send Messages in Threads, Add Reactions).

   ```
   https://discord.com/oauth2/authorize?client_id=YOUR_APP_ID&scope=bot+applications.commands&permissions=274878286912
   ```
5. Your user ID: Discord Settings -> Advanced -> Developer Mode, then
   right-click yourself -> Copy User ID -> `DISCORD_ALLOWED_USERS`.

In servers it replies only when @mentioned; in DMs it replies to everything.

## Telegram bot

1. Message [@BotFather](https://t.me/BotFather), send `/newbot`, pick a name and
   a username ending in `bot`. The token it returns -> `TELEGRAM_BOT_TOKEN`.
2. Message [@userinfobot](https://t.me/userinfobot) for your numeric user ID
   (the number, not the @username) -> `TELEGRAM_ALLOWED_USERS`.
3. For group chats only: BotFather -> `/mybots` -> Bot Settings -> Group Privacy
   -> **Turn off**, then remove and re-add the bot to existing groups. With
   privacy mode on it only sees messages starting with `/`.

If the token ever leaks, revoke it with `/revoke` in BotFather.

## Apply

```bash
sudo nixos-rebuild switch --flake ~/.dotfiles/nix#theater
systemctl --user status hermes-agent
journalctl --user -u hermes-agent -f
```

## Managed mode

Because config is generated from Nix, these CLI commands are **blocked** by
design (the module sets `HERMES_MANAGED` and drops a `.managed` marker):

- `hermes setup`
- `hermes config edit` / `hermes config set`
- `hermes gateway install` / `uninstall`

Change `nix/modules/home/hermes.nix` and rebuild instead. Keys not managed by
Nix still persist across rebuilds.

## Troubleshooting

| Symptom | Cause |
|---|---|
| Bot online, never replies (Discord) | Message Content Intent disabled |
| Bot online, never replies (either) | `*_ALLOWED_USERS` unset -- fails closed |
| "Discord/Telegram unavailable" | `extraDependencyGroups = ["messaging"]` missing |
| Ignores group messages (Telegram) | Privacy mode on; re-add after disabling |
| 403 in logs (Discord) | Bot role lacks channel permissions |
| Dies after logout | `users.users.theater.linger` not applied |
| "managed by" error | Edit the Nix module, rebuild |
| Auth errors despite keys set | `/run/secrets/hermes-env` still holds `REPLACE_ME` |
| sops "failed to load age identities" | No key at `~/.config/sops/age/keys.txt` |
| sops "no key could decrypt" | Wrong/missing `~/.config/sops/age/keys.txt` |
| Activation fails on secrets | Age key absent -- it must exist before rebuild |
| Breakage after `flake update` | Tracking main; pin a known-good rev |
