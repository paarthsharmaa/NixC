{...}: {
  flake.nixosModules.libreoffice = {pkgs, ...}: {
    environment.systemPackages = [
      # Qt variant — matches the theming stack on the desktop machines.
      pkgs.libreoffice-qt
    ];
  };
}
