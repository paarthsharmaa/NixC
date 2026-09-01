{...}: {
  flake.nixosModules.yogaConfiguration = {...}: {
    networking.hostName = "yoga";
    system.stateVersion = "26.05";

    # Disable Lenovo battery conservation mode (60% limit)
    systemd.services.disable-conservation-mode = {
      description = "Disable Lenovo battery conservation mode";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "/bin/sh -c 'echo 0 > /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode'";
      };
      wantedBy = ["multi-user.target"];
      after = ["sys-subsystem-platform-drivers-ideapad_acpi-VPC2004:00.device"];
    };
  };
}
