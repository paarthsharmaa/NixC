{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.zsh = moduleWithSystem (
    {self', ...}: {pkgs, ...}: {
      programs.zsh = {
        enable = true;

        # The wrapper initializes completion after adding its runtime paths.
        enableCompletion = false;
        enableGlobalCompInit = false;

        # Oh My Posh owns the prompt.
        promptInit = "";

        enableBashCompletion = true;
      };

      environment.systemPackages = [
        self'.packages.zsh
      ];

      environment.shells = [
        self'.packages.zsh
      ];

      users.defaultUserShell =
        self'.packages.zsh;

      # Make the intended shell explicit for the actual user too.
      users.users.paarth.shell =
        self'.packages.zsh;
    }
  );

  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: {
    packages = {
      zsh = inputs.wrappers.wrappers.zsh.wrap {
        inherit pkgs;

        # This setup does not use Home Manager.
        hmSessionVariables = null;

        runtimePkgs = [
          pkgs.any-nix-shell
          pkgs.carapace
          pkgs.devenv

          self'.packages.bat
          self'.packages.eza
          self'.packages.fd
          self'.packages.fzf
          self'.packages.lazydocker
          self'.packages.lazygit
          self'.packages.nvim
          self'.packages.ohMyPosh
          self'.packages.rg
          self'.packages.zoxide
        ];

        zshAliases = {
          ls =
            "eza --long --icons=auto --group-directories-first";

          lsa =
            "eza --long --all --icons=auto --group-directories-first";

          lt =
            "eza --tree --level=2 --icons=auto --group-directories-first";

          lta = "lt -la";

          v = "nvim";
          cat = "bat";
          cd = "z";
          btop = "btop --force-utf";
          lg = "lazygit";

          man =
            "man -P \"bat --plain\"";

          nsh =
            "nix-shell -p";

          nrs =
            "sudo nixos-rebuild switch --flake";

          vinix =
            "nvim ~/NixC";

          gcm = "git commit -m";
        };

        zshrc.content = ''
          # Completion must run after wrapper runtime paths are available.
          autoload -Uz compinit
          compinit -d "$HOME/.cache/zsh/zcompdump"

          export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'

          zstyle ':completion:*' \
            format $'\e[2;37mCompleting %d\e[m'

          zstyle ':completion:*' \
            matcher-list \
            'm:{[:lower:]}={[:upper:]}' \
            'r:|[._-]=* r:|=*' \
            'l:|=* r:|=*'

          source <(${lib.getExe pkgs.carapace} _carapace)
          
          autoload -Uz select-word-style
          select-word-style bash

          autoload -Uz \
            up-line-or-beginning-search \
            down-line-or-beginning-search

          zle -N up-line-or-beginning-search
          zle -N down-line-or-beginning-search

          bindkey "^[[A" up-line-or-beginning-search
          bindkey "^[[B" down-line-or-beginning-search
          bindkey "^[OA" up-line-or-beginning-search
          bindkey "^[OB" down-line-or-beginning-search

          bindkey "^[[1;5C" forward-word
          bindkey "^[[1;5D" backward-word
          bindkey "^[[3;5~" kill-word
          bindkey "^H" backward-kill-word

          source <(${lib.getExe self'.packages.fzf} --zsh)

          eval "$(${lib.getExe self'.packages.zoxide} init zsh)"
          eval "$(${lib.getExe pkgs.devenv} hook zsh)"

          eval "$(
            ${lib.getExe self'.packages.ohMyPosh} init zsh
          )"

          ${lib.getExe pkgs.any-nix-shell} \
            zsh --info-right |
            source /dev/stdin

          setopt NO_CASE_GLOB
          setopt AUTO_CD
          setopt INTERACTIVE_COMMENTS
          setopt HIST_IGNORE_ALL_DUPS
          setopt HIST_SAVE_NO_DUPS
          setopt SHARE_HISTORY

          export EDITOR=nvim
          export VISUAL=nvim
        '';
      };

      ohMyPosh =
        inputs.wrappers.wrappers.oh-my-posh.wrap {
          inherit pkgs;

          configFile =
            ./config.toml;
        };
    };
  };
}
