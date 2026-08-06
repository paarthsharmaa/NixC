{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.btop = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [
        self'.packages.btop
      ];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.btop = inputs.wrappers.wrappers.btop.wrap {
      inherit pkgs;

      settings = {
        vim_keys = true;
        update_ms = 1000;

        rounded_corners = true;
        theme_background = false;

        proc_sorting = "cpu lazy";
        proc_tree = false;

        show_battery = true;
        show_disks = true;
      };
    };
  };
}
