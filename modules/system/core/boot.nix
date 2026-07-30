{ 
  self,
  inputs,
  ...
}: {
  flake.nixosModules.bootloader = {
    pkgs,
    lib,
    ...
  }; {
    boot = {
      loader = {
	timeout = 5;
	efi = {
	cantouchEfiVariables = true;
	};
	grub = {
	  efiSupport = true;
	  device = "nodev";
	  theme = pkgs.catppuccin-grub;
	};
      };
      plymouth = {
        enable = true;
        theme = "catppuccin-mocha"
	themePackages = with pkgs; {
	  (catppuccin-plymouth.override {
	    variant = "mocha";
	  })
	};
      };
      kernelPackages = pkgs.linuxPackages_latest;
    };
  };
}
