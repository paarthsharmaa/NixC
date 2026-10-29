{
  pkgs,
  config,
  lib,
  ...
}: let
  flake = ''(builtins.getFlake "path:${config.devenv.root}")'';
in {
  # Tools for this repository only, including lazy.nvim parser compilation.
  packages = with pkgs; [alejandra lua-language-server stylua gcc tree-sitter curl gnutar qt6.qtdeclarative];

  # Resolve the Qt and Quickshell imports used by this repository's shell QML.
  env.QML_IMPORT_PATH = lib.makeSearchPath "lib/qt-6/qml" [pkgs.quickshell pkgs.qt6.qtdeclarative];
  languages = {
    nix = {
      enable = true;
      lsp = {
        enable = true;
        package = pkgs.nixd;
      };
    };
  };

  # nixd accepts project settings through LSP; no machine paths in the Lua config.
  # A store file preserves JSON without shell escaping changing the expressions.
  env.NVIM_NIXD_NIXOS_FLAKE = config.devenv.root;
  env.NVIM_NIXD_SETTINGS_FILE = pkgs.writeText "nixd-settings.json" (builtins.toJSON {
    nixpkgs.expr = "import ${flake}.inputs.nixpkgs {}";
    options = {
      flake_parts.expr = ''
        let
          flake = ${flake};
          inputs = flake.inputs // {self = flake;};
        in (inputs.flake-parts.lib.evalFlakeModule {inherit inputs;}
          (inputs.import-tree (flake.outPath + "/modules"))).options
      '';
    };
  });
}
