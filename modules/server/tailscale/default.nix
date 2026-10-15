{...}: {
  flake.nixosModules.tailscale = {pkgs, ...}: {
    services.tailscale = {
      enable = true;

      openFirewall = true;
      useRoutingFeatures = "server";

      # Applied independently of authKeyFile, including after manual login.
      extraSetFlags = [
        "--ssh"
        "--accept-dns=false"
      ];
    };

    environment.systemPackages = [
      pkgs.tailscale
    ];
  };
}
