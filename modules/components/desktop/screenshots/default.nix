{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.screenshots = moduleWithSystem (
    {self', ...}: {pkgs, ...}: {
      environment.systemPackages = [
        self'.packages.tensaku
        self'.packages.screenshot-region
      ];
    }
  );

  perSystem = {pkgs, self', ...}: {
    packages.tensaku = pkgs.rustPlatform.buildRustPackage {
      pname = "tensaku";

      version = 
        (builtins.fromTOML (
          builtins.readFile "${inputs.tensaku-src}/Cargo.toml"
        )).workspace.package.version;

      src = inputs.tensaku-src;

      cargoLock.lockFile = "${inputs.tensaku-src}/Cargo.lock";
      
      buildFeatures = ["ci-release"];

      nativeBuildInputs = with pkgs; [
        pkg-config
        wrapGAppsHook4
      ];

      buildInputs = with pkgs; [
        glib
        gdk-pixbuf
        gtk4
        libadwaita
        libepoxy
        libGL
        fontconfig
        libxkbcommon
        gtk4-layer-shell
        wayland
      ];

      doCheck = false;

      postInstall = ''
        install -Dm644 dev.tensaku.Tensaku.desktop \
          "$out/share/applications/dev.tensaku.Tensaku.desktop"

        install -Dm644 assets/tensaku.svg \
          "$out/share/icons/hicolor/scalable/apps/dev.tensaku.Tensaku.svg"
      '';

      meta = {
        description = "Screenshot capture and annotation.";
        homepage = "https://github.com/jondkinney/tensaku";
        license = pkgs.lib.licenses.mpl20;
        mainProgram = "tensaku";
        platforms = pkgs.lib.platforms.linux;
      };
    };

    packages.screenshot-region = pkgs.writeShellApplication {
      name = "screenshot-region";

      runtimeInputs = [
        self'.packages.tensaku
        pkgs.coreutils
        pkgs.wl-clipboard
      ];

      text = ''
        output_dir="$HOME/Pictures/Screenshots"
        mkdir -p "$output_dir"

        exec tensaku \
          --capture \
          --copy-command wl-copy \
          --output-filename \
            "$output_dir/screenshot-%Y%m%d-%H%M%S.png"
      '';
    };
  };
}
