{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.lokus = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [self'.packages.lokus];

      xdg.mime.defaultApplications."x-scheme-handler/lokus" = "lokus.desktop";
    }
  );

  perSystem = {pkgs, ...}: {
    packages.lokus = let
      pname = "lokus";
      version = "1.3.0";

      # The upstream release is x86_64 Linux; no external flake is needed.
      src = pkgs.fetchurl {
        url = "https://github.com/lokus-ai/lokus/releases/download/v${version}/Lokus_${version}_amd64.AppImage";
        hash = "sha256-EnT7qS4MGi9VkqRgfJIOQAljDOg3/5Y04RHhWNf7lnY=";
      };

      contents = pkgs.appimageTools.extract {
        inherit pname version src;
      };

      desktopItem = pkgs.makeDesktopItem {
        name = "lokus";
        desktopName = "Lokus";
        comment = "Knowledge management and writing";
        exec = "lokus %U";
        icon = "lokus";
        startupWMClass = "lokus";
        categories = ["Office"];
        mimeTypes = ["x-scheme-handler/lokus"];
      };

      lokus = pkgs.appimageTools.wrapType2 {
        inherit pname version src;

        extraInstallCommands = ''
          install -Dm444 ${desktopItem}/share/applications/lokus.desktop \
            $out/share/applications/lokus.desktop
          cp -r ${contents}/usr/share/icons $out/share/
        '';

        meta = {
          description = "Markdown note taking and knowledge management application";
          homepage = "https://github.com/lokus-ai/lokus";
          mainProgram = "lokus";
          platforms = ["x86_64-linux"];
        };
      };
    in
      inputs.wrappers.lib.wrapPackage (
        {...}: {
          inherit pkgs;
          package = lokus;
        }
      );
  };
}
