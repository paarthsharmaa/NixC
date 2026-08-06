{lib, ...}: {
  flake.nixosModules.dockerRootless = {
    pkgs,
    lib,
    ...
  }: {
    virtualisation.docker.rootless = {
      enable = true;
      setSocketVariable = true;

      daemon.settings = {
        "log-driver" = "local";
      };
    };

    environment.systemPackages = with pkgs; [
      docker-compose
      lazydocker
    ];

    # Start only when explicitly needed.
    systemd.user.services.docker.wantedBy =
      lib.mkForce [];
  };
}
