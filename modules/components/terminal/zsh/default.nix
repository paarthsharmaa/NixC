{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.zsh = moduleWithSystem (
    {self', ...}: {...}: {
      programs.zsh = {
        enable = true;
        enableCompletion = true;
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

        runtimePkgs = with pkgs; [
          carapace
          fzf
        ];

        zshAliases = {
          ls = "${lib.getExe pkgs.lsd} -l";
          v = lib.getExe self'.packages.nvim;
          cat = lib.getExe pkgs.bat;
          lg = lib.getExe pkgs.lazygit;

          devenv = lib.getExe pkgs.devenv;
          carapace = lib.getExe pkgs.carapace;

          man = "man -P \"${lib.getExe pkgs.bat} -p\"";

          nsh = "nix-shell -p";

          nrs = "sudo nixos-rebuild switch --flake";

          vinix = "nvim .";
        };

        zshrc.content = ''
          if (( ''${+terminfo[smkx]} )) &&
             (( ''${+terminfo[rmkx]} )); then
            function zle-line-init() {
              echoti smkx
            }

            function zle-line-finish() {
              echoti rmkx
            }

            zle -N zle-line-init
            zle -N zle-line-finish
          fi

          autoload -U compinit
          compinit

          export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'

          zstyle ':completion:*' \
            format $'\e[2;37mCompleting %d\e[m'

          zstyle ':completion:*' \
            matcher-list \
            'm:{[:lower:]}={[:upper:]}' \
            'r:|[._-]=* r:|=*' \
            'l:|=* r:|=*'

          source <(${lib.getExe pkgs.carapace} _carapace)

          autoload -U select-word-style
          select-word-style bash

          autoload -U \
            up-line-or-beginning-search \
            down-line-or-beginning-search

          zle -N up-line-or-beginning-search
          zle -N down-line-or-beginning-search

          bindkey "^[OA" up-line-or-beginning-search
          bindkey "^[OB" down-line-or-beginning-search

          bindkey "^[[1;5C" forward-word
          bindkey "^[[1;5D" backward-word
          bindkey "^[[3;5~" kill-word
          bindkey "^H" backward-kill-word

          source <(${lib.getExe pkgs.fzf} --zsh)

          setopt NO_CASE_GLOB

          export EDITOR=nvim
          export VISUAL=nvim

          eval "$(${lib.getExe pkgs.devenv} hook zsh)"

          eval "$(
            ${lib.getExe self'.packages.ohMyPosh} \
              init zsh
          )"

          ${lib.getExe pkgs.any-nix-shell} \
            zsh --info-right |
            source /dev/stdin
        '';
      };

      ohMyPosh = inputs.wrappers.wrappers.oh-my-posh.wrap {
        inherit pkgs;

        configFile = ./config.toml;
      };
    };
  };
}
