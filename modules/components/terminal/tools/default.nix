{self, ...}: {
  flake.nixosModules.tools = {...}: {
    imports = with self.nixosModules; [
      bat
      btop
      eza
      fd
      fzf
      herdr
      lazydocker
      lazygit
      rg
      tmux
      zoxide
    ];
  };
}
