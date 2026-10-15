{inputs, ...}: {
  systems = [
    "x86_64-linux"
  ];

  # perSystem has its own nixpkgs instance; NixOS's allowUnfree setting
  # does not apply to the exported wrapper packages (e.g. Spotify).
  perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  };
}
