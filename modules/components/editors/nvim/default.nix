{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.nvim = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [
        self'.packages.nvim
      ];

      environment.variables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
    }
  );

  perSystem = {pkgs, ...}: {
    packages.nvim = inputs.wrappers.wrappers.neovim.wrap {
      inherit pkgs;

      settings.config_directory = ./config;

      runtimePkgs = with pkgs; [
        # Required by lazy.nvim.
        git

        # Search and picker tools.
        fd
        fzf
        ripgrep

        # Wayland clipboard provider.
        wl-clipboard

        # Tools for editing Nix and Lua later.
        nixd
        lua-language-server
        stylua
      ];
    };
  };
}
