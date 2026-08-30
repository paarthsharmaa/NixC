{self, ...}: {
  flake.nixosModules.tools = {...}: {
    imports = with self.nixosModules; [
      bat
      btop
      eza
      fd
      fzf
      lazydocker
      lazygit
      rg
      zoxide
    ];
  };
}
