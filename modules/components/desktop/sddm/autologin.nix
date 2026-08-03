{
	self,
	inputs,
	...
}: {
	flake.nixosModules.sddm-autologin = {
	  pkgs,
		lib,
		...
	}: {
		service.displayManager = {
		  autologin.enable = true;
			autologin.user = "paarth";
		};
	};
}
