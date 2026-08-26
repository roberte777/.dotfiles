{
  pkgs,
  pkgs-unstable,
  ...
}: let
  # `wt sync` — not a worktrunk built-in. Worktrunk dispatches any `wt-<name>`
  # on PATH as `wt <name>` (git-style external subcommands), so putting this
  # binary in home.packages is the whole integration; there is nothing to
  # configure. Not packaged in nixpkgs, hence the local derivation.
  #
  # Must build with pkgs-unstable: the crate declares rust-version = "1.93"
  # and nixpkgs 25.11 ships rustc 1.91.1.
  worktrunk-sync = pkgs-unstable.rustPlatform.buildRustPackage rec {
    pname = "worktrunk-sync";
    version = "0.1.2";

    src = pkgs.fetchFromGitHub {
      owner = "pablospe";
      repo = "worktrunk-sync";
      rev = "v${version}";
      hash = "sha256-LGxTzXF/AWNWajH8gygbSQVpIidbArUZRaokefeD7es=";
    };

    cargoLock.lockFile = "${src}/Cargo.lock";

    # The test suite shells out to git and builds real worktrees.
    doCheck = false;

    meta = {
      description = "wt sync — rebase stacked worktree branches in dependency order";
      homepage = "https://github.com/pablospe/worktrunk-sync";
      license = pkgs.lib.licenses.mit;
      mainProgram = "wt-sync";
    };
  };
in {
  home.packages = [worktrunk-sync];
}
