{self, ...}: {
  flake.nixosModules.tools = {...}: {
    imports = with self.nixosModules; [
      bat
      btop
      tmux
      herdr
      fd
      fzf
      rg
      zoxide
      lazygit
      lazydocker
    ];
  };
}
