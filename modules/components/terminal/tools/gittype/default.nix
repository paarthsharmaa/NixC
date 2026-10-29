{moduleWithSystem, ...}: {
  flake.nixosModules.gittype = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [self'.packages.gittype];
    }
  );

  perSystem = {pkgs, ...}: {
    # Use the official release to avoid the lengthy Rust source build.
    packages.gittype = pkgs.stdenv.mkDerivation rec {
      pname = "gittype";
      version = "0.10.3";

      src = pkgs.fetchurl {
        url = "https://github.com/unhappychoice/gittype/releases/download/v${version}/gittype-v${version}-x86_64-unknown-linux-gnu.tar.gz";
        hash = "sha256-r7KBU+qoprSBQtXsyHmu2nhKDkhh0hspr6W4gXCktxA=";
      };

      sourceRoot = ".";
      nativeBuildInputs = [pkgs.autoPatchelfHook];
      buildInputs = [pkgs.stdenv.cc.cc.lib pkgs.zlib];
      dontConfigure = true;
      dontBuild = true;

      installPhase = ''
        runHook preInstall
        install -Dm755 gittype "$out/bin/gittype"
        runHook postInstall
      '';

      meta = {
        description = "Typing practice with source code from Git repositories";
        homepage = "https://github.com/unhappychoice/gittype";
        license = pkgs.lib.licenses.mit;
        mainProgram = "gittype";
        platforms = ["x86_64-linux"];
        sourceProvenance = [pkgs.lib.sourceTypes.binaryNativeCode];
      };
    };
  };
}
