{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.user = {
    pkgs,
    lib,
    ...
  }: let
    modules = with self.nixosModules; [
      zsh
    ];
    in {
      imports = modules;
      users.users.paarth = {
        isNormalUser = true;
	initialPasssword = "qwer";
	shell = pkgs.zsh;
	description = "Paarth";
	extraGroups = [
	  "root"
	  "wheel"
	];
      };
    };
}
