{self, ...}: {
  flake.nixosModules.server = {
    imports = with self.nixosModules; [
      core
      network
      openssh
      tailscale
      headscale
      forgejo
      syncthing
      adguardhome
      uptimeKuma
      restic
    ];
  };
}
