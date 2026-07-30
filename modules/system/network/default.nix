{ self, inputs, ... }: {
  flake.nixosModules.network = {
    pkgs,
    lib,
    ...
    } :{
      networking = {
	networkmanager = {
	  enable = true;
	  dns = "none";
	};
	nameservers = [
	  "1.1.1.1"
	  "0.0.0.0"
	];
	firewall.enable = true;
      };
      services.unbound = {
        enable = true;
      };
      systemd.services.NetworkManager-wait-online.enable = false;
    };
}
