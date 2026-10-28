{
  # Description
  description = "Dendritic NixOS configuration for my systems.";

  inputs = {
    # System
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flake-parts
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    wrappers = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    iris = {
      url = "github:Harman1307/iris";
      flake = false;
    };

    wlctl = {
      url = "github:aashish-thapa/wlctl";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pixie-sddm = {
      url = "github:xCaptaiN09/pixie-sddm";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tensaku-src = {
      url = "github:jondkinney/tensaku";
      flake = false;
    };

    llm-agents.url = "github:numtide/llm-agents.nix";

    gittype = {
      url = "github:unhappychoice/gittype";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    gitlogue = {
      url = "github:unhappychoice/gitlogue";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);
}
