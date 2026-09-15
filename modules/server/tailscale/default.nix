{...}: {
  flake.nixosModules.tailscale = {pkgs, ...}: {
    services.tailscale = {
      enable = true;

      openFirewall = true;
      useRoutingFeatures = "server";

      extraUpFlags = [
        "--ssh"
        "--accept-dns=false"
      ];
    };

    environment.systemPackages = [
      pkgs.tailscale
    ];
  };
}
