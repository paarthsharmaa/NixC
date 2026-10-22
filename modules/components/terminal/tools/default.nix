{self, ...}: {
  flake.nixosModules.tools = {...}: {
    imports = with self.nixosModules; [
      bat
      bluetui
      btop
      eza
      fastfetch
      fd
      fzf
      lazydocker
      lazygit
      rg
      wlctl
      yazi
      zoxide
    ];
  };
}
