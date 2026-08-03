{self, ...}: {
  flake.nixosModules.core = {pkgs, ...}: {
    imports = with self.nixosModules; [
      bootloader
      hardware
      locale
      nix
      user
    ];

    environment.systemPackages = with pkgs; [
      curl
      lsof
      p7zip
      unzip
      usbutils
      vim
      wget
    ];
  };
}
