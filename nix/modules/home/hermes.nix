{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.hermes-agent.homeManagerModules.default];

  # Hermes Agent -- Nous Research's personal agent, reachable from Discord and
  # Telegram.
  #
  # Runs as the `theater` user rather than a hardened system service, so the
  # agent inherits this user's reach: the dotfiles repo, ~/.ssh, every checkout
  # in ~. That is the deliberate tradeoff for an agent that can work on your
  # actual files -- it is also why the allowlists below matter. Anyone you add
  # to DISCORD_ALLOWED_USERS / TELEGRAM_ALLOWED_USERS gets that same reach.
  #
  # Nix support upstream is Tier 2 (best-effort); the flake input is pinned
  # rather than tracking main so a bad upstream commit cannot break a rebuild.
  programs.hermes-agent = {
    enable = true; # the `hermes` CLI and TUI
    desktop.enable = false; # headless box, no Electron app
  };

  # The upstream unit sets NoNewPrivileges=true, which kernel-blocks sudo/doas
  # in the entire agent process tree. Left in place on purpose: the gateway is
  # promptable by anyone on the allowlists above, so the kernel block -- not
  # the sudo password -- is what keeps a crafted message away from root.
  #
  # If you ever do need to lift it, the home-manager spelling is
  # `systemd.user.services.<name>.Service.<Key>`, NOT NixOS's `serviceConfig`;
  # a `serviceConfig` attr here is emitted as a literal [serviceConfig] section
  # that systemd ignores with only a warning, so the override silently no-ops.

  services.hermes-agent = {
    enable = true;
    gateway.enable = true; # the long-running Discord/Telegram listener

    # Discord and Telegram support are an optional pyproject extra, not part of
    # the default build. Without this the gateway starts, the bots show as
    # online, and every message is silently dropped.
    extraDependencyGroups = ["messaging"];

    # Secrets are merged into ~/.hermes/.env at activation. Only the path is
    # referenced, never the contents -- anything inlined into Nix here would be
    # world-readable in /nix/store. sops-nix decrypts to this path at boot;
    # see hosts/theater/docs/hermes.md for how to edit it.
    environmentFiles = ["/run/secrets/hermes-env"];

    settings = {
      # OpenCode Go: a flat $10/mo subscription over an OpenAI-compatible
      # endpoint, rather than per-token Anthropic billing. Registered as a
      # named custom provider so `/model opencode:<id>` can switch models
      # mid-session without touching this file.
      #
      # key_env, not an inline key -- the value arrives from sops via
      # environmentFiles above and must never be written into /nix/store.
      providers.opencode = {
        api = "https://opencode.ai/zen/go/v1";
        key_env = "OPENCODE_API_KEY";
        transport = "chat_completions";
      };

      model = {
        default = "qwen3.8-flash";
        provider = "custom:opencode";
      };

      # Think as hard as the model allows on every turn. Hermes defaults to
      # "medium"; "max" is the top of the ladder (none..medium..xhigh..max..ultra)
      # and gets clamped to the highest level the active route supports.
      agent.reasoning_effort = "max";

      # In servers Hermes answers only when @mentioned; DMs always get a reply.
      # Session history is kept per-user inside shared channels.
      group_sessions_per_user = true;
      discord.require_mention = true;

      # @everyone and @role pings stay blocked: the agent composes its own
      # messages, and a mistaken mass-ping is not a recoverable mistake.
      discord.allow_mentions = {
        everyone = false;
        roles = false;
        users = true;
        replied_user = true;
      };

      # MCP servers. Hermes spawns these at startup and registers their tools
      # as mcp_<server>_<tool>, available on every platform (Telegram included).
      #
      # The omnibus entry is the read-only stdio MCP server from the omnibus
      # repo (mcp/ crate), built once from ~/omnibus-src and installed to
      # ~/.local/bin. It logs into the local Omnibus instance over REST with a
      # real account -- the binary holds the credentials so it can re-login
      # unattended when the bearer token idles out, hence username+password
      # rather than a token.
      #
      # Absolute path, not a bare command name: the gateway unit's PATH does
      # not include ~/.local/bin. Credentials are ${VAR} placeholders resolved
      # from ~/.hermes/.env, which environmentFiles merges from the sops secret
      # -- nothing credential-shaped lands in the Nix store.
      #
      # Wrapped in mcp-schema-sanitizer (also ~/.local/bin): omnibus-mcp emits
      # array-typed outputSchema / structuredContent for its list-returning
      # tools, which the strict MCP python SDK rejects at discovery. The proxy
      # drops the non-conformant fields; the text result is untouched.
      mcp_servers.omnibus = {
        command = "/home/theater/.local/bin/mcp-schema-sanitizer";
        args = [ "/home/theater/.local/bin/omnibus-mcp" ];
        env = {
          OMNIBUS_MCP_URL = "http://localhost:3000";
          OMNIBUS_MCP_USERNAME = "\${OMNIBUS_MCP_USERNAME}";
          OMNIBUS_MCP_PASSWORD = "\${OMNIBUS_MCP_PASSWORD}";
        };
        timeout = 30;
      };
    };

    # Tools the agent shells out to. It inherits this user's PATH for little
    # else, so anything it should reach belongs here.
    extraPackages = with pkgs; [
      git
      ripgrep
      fd
      jq
      curl
    ];
  };
}
