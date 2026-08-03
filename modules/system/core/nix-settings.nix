{inputs, ...}: {
  flake.nixosModules.nix = {...}: {
    nix = {
      settings = {
        cores = 0;

        trusted-users = [
          "root"
          "paarth"
        ];

        download-buffer-size = 500 * 1024 * 1024;

        experimental-features = [
          "nix-command"
          "flakes"
        ];
      };

      registry.nixpkgs.flake = inputs.nixpkgs;

      nixPath = [
        "nixpkgs=${inputs.nixpkgs}"
      ];

      optimise.automatic = true;

      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 30d";
      };
    };

    nixpkgs.config.allowUnfree = true;
  };
}
