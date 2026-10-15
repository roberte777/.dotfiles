{
  config,
  lib,
  ...
}: let
  # Importing this module is the opt-in: it links the Claude Code user config
  # (CLAUDE.md, settings, skills) from this repo into ~/.claude.
  cfg = config.programs.claude-config;

  # The flake's own copy of the repo decides *what* gets linked, so only
  # git-tracked entries count. The links themselves point at the live checkout
  # rather than the store, because Claude Code writes back to its own config
  # (/model, plugin toggles, auto mode setup) and those writes must land in the
  # repo as ordinary diffs instead of failing against a read-only store path.
  src = ../../../claude/.claude;
  link = rel: config.lib.file.mkOutOfStoreSymlink "${cfg.checkout}/claude/.claude/${rel}";

  topLevel = lib.filter (name: name != ".gitignore" && name != "skills") (
    lib.attrNames (builtins.readDir src)
  );

  # skills/ also receives skills synced from the claude.ai account, so each of
  # ours is linked on its own instead of taking over the whole directory.
  skills = lib.optionals (builtins.pathExists (src + "/skills")) (
    lib.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir (src + "/skills")))
  );
in {
  options.programs.claude-config.checkout = lib.mkOption {
    type = lib.types.str;
    default = "${config.home.homeDirectory}/.dotfiles";
    description = "Path of the dotfiles checkout the links point at";
  };

  config.home.file = lib.listToAttrs (
    map (rel: lib.nameValuePair ".claude/${rel}" {source = link rel;})
    (topLevel ++ map (name: "skills/${name}") skills)
  );
}
