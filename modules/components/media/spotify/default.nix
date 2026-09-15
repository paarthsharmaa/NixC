{...}: {
  flake.nixosModules.spotify = {pkgs, ...}: {
    # Unfree; allowed globally via nixpkgs.config.allowUnfree.
    environment.systemPackages = [
      pkgs.spotify
    ];
  };
}
