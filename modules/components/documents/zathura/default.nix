{...}: {
  flake.nixosModules.zathura = {
    # zathura reads user config first, then falls back to XDG_CONFIG_DIRS
    # (/etc/xdg), so this acts as a system-wide default.
    environment.etc."xdg/zathura/zathurarc".text = ''
      # Match the catppuccin mocha palette used across the setup.
      set default-bg "#1e1e2e"
      set default-fg "#cdd6f4"
      set statusbar-fg "#cdd6f4"
      set statusbar-bg "#313244"
      set inputbar-bg "#313244"
      set inputbar-fg "#cdd6f4"
      set notification-bg "#313244"
      set notification-fg "#cdd6f4"
      set recolor-lightcolor "#1e1e2e"
      set recolor-darkcolor "#cdd6f4"
      set recolor "false"
    '';
  };
}
