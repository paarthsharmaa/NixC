{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.sddm = moduleWithSystem (
    {self', ...}: {pkgs, ...}: {
      services.displayManager.sddm = {
        enable = true;
        package = pkgs.kdePackages.sddm;

        wayland.enable = true;

        theme = "pixie";
        extraPackages = with pkgs.kdePackages; [
          qtsvg
          qtdeclarative
          qt5compat
        ];

        settings.Theme.CursorTheme = "breeze_cursors";
      };

      environment.systemPackages = [
        self'.packages.pixie-sddm
      ];
    }
  );

  perSystem = {inputs', ...}: {
    packages.pixie-sddm = inputs'.pixie-sddm.packages.pixie-sddm;
  };
}
