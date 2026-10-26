{...}: {
  flake.nixosModules.legionConfiguration = {config, ...}: {
    # Work around patchelf corrupting NVIDIA executables when both operations
    # run together: https://github.com/NixOS/nixpkgs/issues/576412.
    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable.overrideAttrs (old: {
      builder = builtins.toFile "nvidia-builder.sh" (builtins.replaceStrings
        [''patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
                    --set-rpath $out/lib:$libPath $bin/bin/$i'']
        [''patchelf --set-rpath $out/lib:$libPath $bin/bin/$i
                patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $bin/bin/$i'']
        (builtins.readFile old.builder));
    });

    # Install through Kbuild so Zenpower gets its module signature/certificate.
    # Remove once the pinned nixpkgs fixes https://github.com/NixOS/nixpkgs/issues/575192.
    nixpkgs.overlays = [
      (_final: prev: {
        linuxPackages_latest = prev.linuxPackages_latest.extend (kernelFinal: kernelPrev: {
          zenpower = kernelPrev.zenpower.overrideAttrs (old: {
            makeFlags = kernelFinal.kernelModuleMakeFlags ++ old.makeFlags ++ [
              "INSTALL_MOD_PATH=${builtins.placeholder "out"}"
              "DEPMOD=true"
            ];
            installPhase = null;
            installTargets = ["modules_install"];
            installFlags = [
              "-C"
              "${kernelFinal.kernel.dev}/lib/modules/${kernelFinal.kernel.modDirVersion}/build"
              "M=$(PWD)"
            ];
          });
        });
      })
    ];

    networking.hostName = "legion";
    system.stateVersion = "26.05";
  };
}
