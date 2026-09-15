{lib, ...}: {
  flake.nixosModules.lazarusConfiguration = {...}: {
    networking.hostName = "lazarus";
    system.stateVersion = "26.05";

    # Headless box: keep the server up through suspend.
    systemd.targets.sleep.enable = false;

    # Headless: drop the desktop-only bits that core pulls in transitively.
    services.blueman.enable = lib.mkForce false;
    hardware.bluetooth.enable = lib.mkForce false;
    services.pipewire.wireplumber.enable = lib.mkForce false;

    # systemd-resolved is enabled by default on 26.05 and squats the
    # DNS stub; adguard-home owns port 53 here.
    services.resolved.enable = false;

    # Local resolution goes through adguard-home.
    networking.nameservers = ["127.0.0.1"];

    # SSH access: add your public keys here, e.g.
    # users.users.paarth.openssh.authorizedKeys.keys = [
    #   "ssh-ed25519 AAAA... paarth@yoga"
    # ];

    # The box is a backup target for yoga/legion too — make sure the
    # mountpoint exists even if the disk isn't plugged in yet.
    fileSystems."/mnt/backups" = {
      device = "/dev/disk/by-label/backups";
      fsType = "ext4";
      options = ["nofail" "x-systemd.device-timeout=5s"];
    };
  };
}
