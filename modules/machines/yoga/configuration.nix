{...}: {
  flake.nixosModules.yogaConfiguration = {...}: {
    networking.hostName = "yoga";
    system.stateVersion = "26.05";

    # Always charge to 100% (no Lenovo "conservation mode" 60% limit).
    #
    # Two things can turn the limit on at boot:
    # - upower: it remembers a "charge threshold" toggle in
    #   /var/lib/upower/charging-threshold-status and re-applies it when it
    #   starts. That file said 1, so upower (starting after the service
    #   below) switched the limit back on every boot. tmpfiles writes 0 into
    #   it on every boot, before upower starts.
    # - the firmware/kernel default, which the service below overrides.
    systemd.tmpfiles.rules = [
      "f+ /var/lib/upower/charging-threshold-status 0644 root root - 0"
    ];

    systemd.services.disable-conservation-mode = {
      description = "Disable Lenovo battery conservation mode";
      # Run after upower, so its saved setting can never win.
      after = ["upower.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      # charge_types replaces the deprecated ideapad conservation_mode file:
      # "Standard" charges to 100%, "Long_Life" stops at ~60%.
      script = ''
        for f in /sys/class/power_supply/BAT*/charge_types; do
          [ -e "$f" ] && echo Standard > "$f"
        done
      '';
    };
  };
}
