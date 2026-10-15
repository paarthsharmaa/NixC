{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.zathura = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [self'.packages.zathura];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.zathura = inputs.wrappers.wrappers.zathura.wrap {
      inherit pkgs;

      # The wrapper includes the document plugins and its own zathurarc.
      settings = {
        default-bg = "#1e1e2e";
        default-fg = "#cdd6f4";
        statusbar-fg = "#cdd6f4";
        statusbar-bg = "#313244";
        inputbar-bg = "#313244";
        inputbar-fg = "#cdd6f4";
        notification-bg = "#313244";
        notification-fg = "#cdd6f4";
        recolor-lightcolor = "#1e1e2e";
        recolor-darkcolor = "#cdd6f4";
        recolor = false;
      };
    };
  };
}
