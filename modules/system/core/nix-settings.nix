{ inputs, ... }: {
  perSystem = {system, ...}: {
    _module.args.unfreePkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  };
  flake.nixosModules.nix = {...}: {
    nix = {
      settings = {
        cores = 0;
	trusted-users = [ "root" "paarth" ];
	download-buffer-size = 500 * 1024 * 1024;
	experimental-features = [
	  "nix-command"
	  "flakes"
	];
      };
      nixPath = ["nixkgs=${inputs.nixpkgs}"];
      optimise.automatic = true;
      gc = {
        automatic = true;
	dates = "daily";
	options = "--delete-older-than 30d";
      };
    };
    nixpkgs = {
      config = {
      	allowUnfree = true;
	packageOverrides = pkgs: {
	  unstable = import inputs.nixpkgs-unstable {
            config = {
	      allowUnfre = true;
	    };
	  };
	};
      };
    };
  };
}
