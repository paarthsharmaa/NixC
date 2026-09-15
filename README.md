# NixC

My NixOS configuration — a **dendritic, homeless** flake built on **flake-parts**, where every part of the system is a plain NixOS module and every program is a wrapped package.

## The approach

### Dendritic + homeless

Most NixOS configs have a special top-level file (`flake.nix` imports a fixed `configuration.nix`, home-manager manages a fixed `home.nix`, and everything funnels through those). This flake deliberately doesn't have any of that:

- **Dendritic** — there is no "root" configuration file. `flake.nix` contains a single output expression:

  ```nix
  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);
  ```

  Every file under `modules/` is itself a flake-parts module, and `import-tree` discovers and imports all of them recursively. The configuration grows like a tree: to add a new program, preset, or machine, you just drop a new file into `modules/` — nothing needs to be registered, imported, or listed anywhere else. Each module contributes to whatever flake outputs it cares about (usually `flake.nixosModules.<name>`, plus `perSystem` packages).

- **Homeless** — no home-manager. Dotfiles, user programs, and per-program configuration are all expressed as ordinary **NixOS modules** that export `flake.nixosModules.<name>`. Machines are then just compositions of those modules:

  ```nix
  # modules/machines/yoga/default.nix
  {self, inputs, ...}: {
    flake.nixosConfigurations.yoga = inputs.nixpkgs.lib.nixosSystem {
      modules = with self.nixosModules; [
        workstation        # preset: desktop + development + qol + ai
        yogaConfiguration  # hostname + host-specific services
        yogaHardware       # hardware-configuration + nixos-hardware
      ];
    };
  }
  ```

  One evaluation, one closure, one module system — user and system land in the same `/run/current-system/sw`.

### How the pieces fit together

- **flake-parts** — gives every file in `modules/` access to `self`, `inputs`, `perSystem`, and `moduleWithSystem`. The `moduleWithSystem` helper bridges the flake-level and NixOS-level module systems, so a component can build its own package in `perSystem` (`self'.packages.kitty`) and install that exact wrapped build system-wide (`environment.systemPackages = [ self'.packages.kitty ]`).
- **import-tree** — makes the flake self-assembling. Directory structure is the only organizational tool; the tree is walked automatically, which is what makes the config truly dendritic instead of "flake-parts with a hand-written import list".
- **BirdeeHub's [nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules) (`wrappers`)** — this is what replaces home-manager. Instead of writing configs to `~/.config` via a separate home layer, each program is *wrapped*: its config, runtime dependencies, and environment are baked directly into the package derivation. For example, zsh is built with its aliases, completion, fzf/zoxide/oh-my-posh hooks, and its full runtime PATH inside the package itself — and that package is set as the login shell. The same pattern covers nvim, tmux, git, jj, kitty, btop, fuzzel, brave, dolphin, yazi, and the AI tools. Programs ship their own configuration; there is no dotfile state drifting outside the store.

### Module layout

```
modules/
├── parts.nix            # flake-parts systems (x86_64-linux)
├── machines/            # per-host entry points (yoga, legion, lazarus)
├── presets/             # composable role bundles
│   ├── workstation/     #   desktop + development + qol + ai + fonts
│   ├── server/          #   core + network + all modules under server/
│   ├── development/     #   git, nvim, zsh, jj, tmux, toolchains
│   ├── qol/             #   iris theming, browsers, dolphin, docs, media
│   └── ai/              #   opencode, codex
├── system/              # OS plumbing: core (boot/hardware/locale/nix/user),
│                        # desktop, audio, network, power, nix-ld, docker
├── server/              # self-hostable services, one module per service:
│                        # openssh (+fail2ban), tailscale, headscale,
│                        # forgejo, syncthing, adguard-home, uptime-kuma
│                        # (+ntfy), restic
└── components/          # one self-contained module per program/theme
    ├── ai/  browsers/  desktop/  documents/  editors/  media/  terminal/  theme/
```

`core` pulls in bootloader, hardware, locale, nix settings (flakes, auto-GC, optimisation), and the user account. `desktop` layers audio, network, power, nix-ld and the whole Wayland stack (SDDM, Hyprland, Quickshell shell, swaync, hyprsunset, clipboard, screenshots, wlogout) on top of `core`. `server` layers openssh, tailscale/headscale, forgejo, syncthing, adguard-home, uptime-kuma, and restic on top of `core`. Presets bundle components; machines pick presets.

## The shell

zsh is the login shell — but not stock zsh. It's a **wrapper package** (`self'.packages.zsh`) built by BirdeeHub's wrappers, so the entire interactive environment lives in the derivation:

- **Completion** — zsh completion is initialized after the wrapper's runtime paths are set up, plus [carapace](https://github.com/carapace-sh/carapace) bridging completions from zsh/fish/bash/inshellisense definitions, with case-insensitive and partial-word matching.
- **Prompt** — [oh-my-posh](https://ohmyposh.dev) owns the prompt (itself a wrapped package with its own `config.toml`); `any-nix-shell` patches it to show when you're inside a nix-shell.
- **Fuzzy finding** — fzf's zsh integration for `Ctrl-R` history and `Ctrl-T` file search.
- **Smart navigation** — zoxide (`cd` is aliased to `z`, so `cd projects/foo` jumps there after one visit), with `AUTO_CD` and case-insensitive globbing enabled.
- **History** — shared across sessions, with all duplicates stripped.
- **Aliases** — `ls`/`lsa`/`lt` → eza (icons, tree), `cat` → bat, `v` → nvim, `lg` → lazygit, `btop`, `man` piped through `bat --plain`, plus maintenance shortcuts: `nrs` (rebuild + switch), `nsh` (ephemeral `nix-shell -p`), `vinix` (edit this flake), `gcm`.
- **Word-style keybinds** — bash-style word motions: `Ctrl+←/→` word movement, `Ctrl+Backspace`/`Ctrl+H` word deletion, and Up/Down doing prefix history search.
- **devenv hook** — automatically activates devenv environments when entering project directories.

The same wrapped packages (nvim, bat, eza, fd, fzf, rg, zoxide, lazygit, lazydocker, btop) are injected as the shell's runtime deps, so the shell always finds the exact versions it was built against. tmux uses the wrapped zsh as its shell, with a `C-Space` prefix, vi-mode keys, mouse support, 50k scrollback, the yank plugin, and a per-user socket under `XDG_RUNTIME_DIR`.

## Desktop & keybinds

The desktop is **Hyprland under UWSM** (systemd-managed Wayland sessions) with a **Quickshell** desktop shell ("Shell Island" — launcher, control center, media panel, wallpaper picker, volume/brightness OSDs), swaync notifications, hyprsunset night light, awwww wallpapers, hyprlock, and wlogout. Hyprland config is written in **Lua** (`environment.etc."xdg/hypr/nixc"`), split into shared `common/` modules and per-host `hosts/` files selected by hostname at startup — the same dendritic idea applied to the compositor config. Appearance: dwindle layout, gaps, rounded corners, shadows, and blur (tuned down per-host on the Yoga for efficiency).

Everything is on **`SUPER`** (plus a few standalone keys):

| Key | Action |
|---|---|
| `SUPER + Enter` | Terminal (kitty, launched via uwsm) |
| `SUPER + Space` | Launcher — Quickshell launcher, falling back to fuzzel |
| `SUPER + E` | File manager (dolphin) |
| `SUPER + B` | Browser (librewolf) |
| `SUPER + C` | Control center (Quickshell) |
| `SUPER + W` | Wallpaper selector |
| `SUPER + M` | Media panel |
| `SUPER + N` | Notification center (swaync) |
| `SUPER + Shift + V` | Clipboard history picker |
| `Print` | Region screenshot |
| `SUPER + Q` | Close window |
| `SUPER + V` | Toggle floating |
| `SUPER + H/J/K/L` | Focus left/down/up/right |
| `SUPER + 1..9, 0` | Workspace 1–10 |
| `SUPER + Shift + 1..0` | Move window to workspace |
| `SUPER + LMB / RMB` | Drag / resize window |
| `SUPER + Shift + L` | Lock (hyprlock) |
| `SUPER + Shift + E` | Power menu (wlogout) |

Hardware keys work even on the lock screen and even if Quickshell is down: volume, brightness, and media keys call `wpctl`/`brightnessctl`/`playerctl` directly, with Quickshell's OSD triggered best-effort over IPC. Media keys also respond while locked.

## Theming

Theming is centralized in **[iris](https://github.com/Harman1307/iris)** (built as a wrapped package from flake input). `iris` generates a palette from the wallpaper and `iris-apply` re-skins the entire desktop at runtime: GTK 3/4, Qt/kdeglobals, kitty (live-reloaded over its IPC socket), swaync, wlogout (icons recolored on the fly), and hyprlock — all rendered from templates into `~/.cache/iris`. A `systemd` user service (`iris-restore`) re-applies the last palette on every login, so the theme survives reboots without any home-manager.

## Machines

| Host | Hardware | Role |
|---|---|---|
| **yoga** | Lenovo Yoga 6 13ALC6 — laptop, AMD, 1080p 60Hz panel | Daily driver. Full `workstation` preset: Hyprland desktop, development tooling, QoL apps, AI assistants. Uses `nixos-hardware`'s `lenovo-yoga-6-13ALC6` module. Carries a host-specific systemd service that disables Lenovo's battery conservation mode (the 60% charge limit) at boot, and a lighter blur profile to save battery. |
| **legion** | Lenovo Legion 16ACH6H — performance/gaming laptop, AMD | Gaming and heavier workloads. Same full `workstation` stack as yoga, using `nixos-hardware`'s `lenovo-legion-16ACH6H` module (which brings the correct firmware, GPU, and cooling-related tuning for the Legion line). |
| **lazarus** | Generic Intel desktop | Headless server + development box. The `server` preset — SSH (key-only, fail2ban), **headscale** control plane with a **tailscale** client, **forgejo** (git forge + postgres), **syncthing**, **adguard-home** (network-wide DNS/adblocking), **uptime-kuma** (+ntfy alerts), and **restic** backups — plus `nix-ld` and `development`. No desktop stack. |

Every machine's `hardware.nix` imports the matching **[nixos-hardware](https://github.com/NixOS/nixos-hardware)** module on top of the generated `hardware-configuration` (kernel modules, filesystems by UUID, CPU microcode, swap), so model-specific quirks are handled upstream instead of being hand-patched here. All hosts are `x86_64-linux` and set `hostPlatform` accordingly.

## nix-ld

All machines (graphical ones via `desktop`, lazarus directly) enable **nix-ld** with a common set of libraries (`stdenv.cc.cc`, zlib, libusb1, util-linux). This patches the dynamic loader so prebuilt binaries — the kind you download from GitHub releases, or that AI coding tools and language servers vendor themselves — can find their shared libraries on NixOS without a FHS chroot. It's what makes the "run any random binary" experience work out of the box.

## Usage

```bash
sudo nixos-rebuild switch --flake .#yoga
sudo nixos-rebuild switch --flake .#legion
sudo nixos-rebuild switch --flake .#lazarus
```
