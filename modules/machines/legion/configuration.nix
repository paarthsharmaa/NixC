{...}: {
  flake.nixosModules.legionConfiguration = {config, ...}: {
    # Windows lives on its own drive (Samsung 1 TB, nvme1n1) with its own
    # 200 MB ESP (nvme1n1p1); Limine chainloads its bootmgfw.efi from there.
    nixc.boot.windowsEsp = "9cd65e0b-9c26-43b8-83c6-350454ef44b1";

    # Limine is signed with the sbctl keys enrolled in this machine's firmware
    # (2026-11-05, with Microsoft's keys for Windows and the NVIDIA option ROM)
    # and its config is hash-locked (docs/roadmap-hardening.md, Phase 4).
    # Keys live in /var/lib/sbctl: back them up.
    boot.loader.limine.secureBoot.enable = true;

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
