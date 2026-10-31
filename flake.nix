{
  inputs = {
    # Nixpkgs    
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Flake-Parts
    flake-parts.url = "github:hercules-ci/flake-parts";

    wrappers.url = "github:nix-community/nix-wrapper-modules";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake (inherit inputs) [inputs.import-tree ./modules]
}