{ self, inputs, ... }:

{
  flake.nixosModules.homeManager =
    { ... }:

    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
      ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;

        # Makes flake inputs available inside Home Manager modules.
        extraSpecialArgs = {
          inherit inputs;
        };

        users.paarth = {
          imports = [
            self.homeModules.noctalia
          ];

          home = {
            username = "paarth";
            homeDirectory = "/home/paarth";

            # Keep this aligned with your first Home Manager setup.
            stateVersion = "26.05";
          };

          programs.home-manager.enable = true;
        };
      };
    };
}
