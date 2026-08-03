{moduleWithSystem, ...}: {
  flake.nixosModules.quickshell = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [
        self'.packages.quickshell
      ];
    }
  );
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
		packages.quickshell = pkgs.writeShellAppication {
			name = "nixc-qs";
			
			text = ''
				exec ${lib.getExe pkgs.quickshell} \
					--path ${./config/} \
					"$@"
				'';

			derivationArgs.meta = {
				mainProgram = "nixc-qs";
				description = "my dev quickshell";
			};
		};
  };
}
