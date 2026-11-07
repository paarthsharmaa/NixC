# NixC

My NixOS flake: **dendritic**, **homeless**, built on flake-parts.

<!-- screenshots -->

## Approach

- **Dendritic.** No root `configuration.nix`. `flake.nix` is one line:

  ```nix
  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);
  ```

  [import-tree](https://github.com/vic/import-tree) loads every `.nix` file under `modules/` as a flake-parts module. Adding a program, preset or machine means adding a file; nothing is registered by hand.

- **Homeless.** No home-manager. Every program is a **wrapped package** ([nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules)) with its config baked into the derivation. Every feature is a plain NixOS module (`flake.nixosModules.<name>`). Machines are lists of those modules.

- **Runtime state stays outside the store.** Things meant to change live (wallpaper colors from [matugen](https://github.com/InioX/matugen), shell settings) are written to `~/.cache` and `~/.local/state` and live-reloaded. Nix ships the code and the defaults.

```
modules/
├── machines/    # yoga, legion, lazarus: preset + configuration + hardware
├── presets/     # workstation, development, qol, ai, server
├── system/      # core, desktop, limine (Secure Boot), audio, network, ...
├── server/      # forgejo, headscale, adguard, syncthing, uptime-kuma, restic
└── components/  # one module per program (desktop, editors, terminal, theme, ...)
```

Desktop: Hyprland (Lua config) under UWSM, a Quickshell shell (top notch, launcher, control center, wallpaper picker, clipboard sheet), swaync, matugen theming, and a themed Limine boot menu with Secure Boot.

```bash
sudo nixos-rebuild switch --flake .#<host>   # yoga | legion | lazarus
```

## Keybinds

| Key | Action |
|---|---|
| `Super + Enter` | Terminal (kitty) |
| `Super + Space` | Launcher |
| `Super + E` | File manager |
| `Super + B` | Browser |
| `Super + C` | Control center |
| `Super + W` | Wallpaper picker |
| `Super + M` | Media panel |
| `Super + N` | Notification center |
| `Super + Shift + V` | Clipboard history |
| `Print` | Region screenshot |
| `Super + Q` | Close window |
| `Super + V` | Toggle floating |
| `Super + H/J/K/L` | Focus left/down/up/right |
| `Super + 1..0` | Workspace 1–10 |
| `Super + Shift + 1..0` | Move window to workspace |
| `Super + LMB / RMB` | Move / resize window |
| `Super + Shift + L` | Lock |
| `Super + Shift + E` | Power menu |

Click the top notch to expand it. Scroll over the workspace dots to switch workspaces. Volume, brightness and media keys work even when locked.
