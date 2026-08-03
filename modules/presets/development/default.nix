{self, ...}: {
  flake.nixosModules.development = {pkgs, ...}: {
    imports = with self.nixosModules; [
      git
      nvim
      zsh
    ];

    environment.systemPackages = with pkgs; [
      # General development utilities
      cmake
      gcc
      gnumake
      jq
      pkg-config

      # Language/toolchain starters
      nodejs
      python3
      uv
    ];
  };
}
