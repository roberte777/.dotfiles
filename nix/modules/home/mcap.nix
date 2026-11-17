{pkgs, ...}: let
  # `log2mcap` — converts DJI flight logs to MCAP via the Java generator.
  #
  # The jars are built out-of-band (IntelliJ artifacts under the project's
  # `out/`), so nix only supplies a runtime JRE; nothing here compiles Java.
  # A wrapper rather than a shell alias so it works from scripts and
  # non-interactive shells, and so the JRE stays GC-rooted by this profile.
  #
  # Point LOG2MCAP_HOME at the checkout if it does not live at the default.
  log2mcap = pkgs.writeShellApplication {
    name = "log2mcap";
    runtimeInputs = [pkgs.temurin-jre-bin];
    text = ''
      root="''${LOG2MCAP_HOME:-$HOME/coding/dji-logmcap}"

      if [ ! -d "$root" ]; then
        echo "log2mcap: generator not found at $root (set LOG2MCAP_HOME)" >&2
        exit 1
      fi

      exec java \
        -cp "$root/lib/slf4j-nop-2.0.13.jar:$root/out/dji-flight-log-mcap-generator/dji-flight-log-mcap-generator.jar" \
        org.example.Convert "$@"
    '';
  };
in {
  home.packages = [
    log2mcap
    # `mcap` — Foxglove CLI for inspecting/converting the generated files.
    pkgs.mcap-cli
  ];
}
