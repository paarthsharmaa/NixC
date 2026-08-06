{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.tmux = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [
        self'.packages.tmux
      ];
    }
  );

  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: {
    packages.tmux = inputs.wrappers.wrappers.tmux.wrap {
      inherit pkgs;

      # C-b is also commonly used by Herdr.
      prefix = "C-a";

      shell = lib.getExe self'.packages.zsh;

      # Put the socket under XDG_RUNTIME_DIR instead of /tmp.
      secureSocket = true;

      sourceSensible = true;

      terminal = "tmux-256color";
      modeKeys = "vi";
      statusKeys = "vi";
      vimVisualKeys = true;

      mouse = true;
      historyLimit = 50000;

      plugins = with pkgs.tmuxPlugins; [
        yank
      ];

      updateEnvironment = [
        "DISPLAY"
        "WAYLAND_DISPLAY"
        "SSH_AUTH_SOCK"
        "XDG_RUNTIME_DIR"
        "DBUS_SESSION_BUS_ADDRESS"
      ];

      configAfter = ''
        set -g focus-events on
        set -g renumber-windows on
        set -g set-clipboard on

        bind c new-window -c "#{pane_current_path}"
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"
      '';
    };
  };
}
