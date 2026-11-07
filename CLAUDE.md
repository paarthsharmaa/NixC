# NixC — notes for Claude

Paarth's NixOS flake. **Dendritic + homeless**: flake-parts + import-tree + BirdeeHub/nix-wrapper-modules, plain NixOS modules, **no home-manager**. README.md has the user-facing overview; this file is the working knowledge.

## Rules
- Never add `Co-Authored-By: Claude` (or any Claude/AI attribution) to commits or PRs.
- Don't commit or push without asking first. The repo also has jj (`.jj/`) colocated with git.
- Paarth is learning Nix: when building something, explain the *why* (which module system, which `pkgs`, what gets evaluated where), briefly.

## How the flake assembles
- `flake.nix` output is one line: `flake-parts.lib.mkFlake {inherit inputs;} (import-tree ./modules)`.
- **import-tree** imports *every* `*.nix` under `modules/` as a **flake-parts module**, except paths containing `/_` (e.g. `modules/foo/_helpers.nix` is skipped). Non-.nix files (lua, qml, toml, css) are ignored and referenced by path.
  - So: never drop a non-flake-parts `.nix` file (e.g. a project `devenv.nix`, a raw NixOS module) under `modules/` unless it's under a `_`-prefixed path.
  - Flakes only see **git-tracked** files: new files need `git add` before `nix build`/`nixos-rebuild`, or they're invisible ("attribute missing" errors).
- Two module systems are in play:
  1. **flake-parts level** (top of every file): args `{self, inputs, lib, moduleWithSystem, withSystem, ...}`; sets `flake.*` and `perSystem`.
  2. **NixOS level**: the value of `flake.nixosModules.<name>` — a normal NixOS module (`{config, lib, pkgs, ...}: {...}`).
- `perSystem = {pkgs, self', inputs', system, ...}:` builds `packages.<name>` (exposed as `.#<name>`). `self'`/`inputs'` = per-system shorthands (`self'.packages.x` = `self.packages.${system}.x`).
- **`moduleWithSystem (perSystemArgs: nixosModule)`** bridges them: lets a NixOS module use `self'.packages.foo`. Note the `pkgs` in the *outer* (perSystem) function is the perSystem nixpkgs, not the NixOS one.
- `modules/parts.nix`: `systems = ["x86_64-linux"]`; perSystem gets its **own** nixpkgs instance with `allowUnfree = true` (NixOS's `nixpkgs.config.allowUnfree` does NOT apply to perSystem — needed for spotify etc).
- Naming: `flake.nixosModules.<camelCase>` (e.g. `claudeCode`, `uptimeKuma`, `yogaHardware`), referenced via `with self.nixosModules; [ ... ]`.

## Standard component pattern
```nix
{inputs, moduleWithSystem, ...}: {
  flake.nixosModules.foo = moduleWithSystem ({self', ...}: {...}: {
    environment.systemPackages = [self'.packages.foo];
  });
  perSystem = {pkgs, inputs', self', ...}: {
    packages.foo = /* one of the 4 ways below */;
  };
}
```
Ways `packages.foo` gets built:
1. **Dedicated wrapper module**: `inputs.wrappers.wrappers.<prog>.wrap { inherit pkgs; settings = {...}; ... }` — program-specific options (opencode `settings`, git `settings`, kitty `settings/font/themeFile`, tmux `prefix/plugins`, zsh `zshAliases/zshrc.content`, neovim `settings.config_directory`, oh-my-posh `configFile`). Available modules: see `wrapperModules/<letter>/<name>/module.nix` in the wrappers input (includes claude-code, opencode, zsh, tmux, kitty, git, jujutsu, neovim, yazi, btop, fuzzel, mpv, zathura, hyprland, quickshell, ...).
2. **Generic wrap**: `inputs.wrappers.lib.wrapPackage ({...}: { inherit pkgs; package = ...; flags = {...}; flagSeparator = "="; runtimePkgs = [...]; environment = {...}; })` — any package, only core options (flags, env, runtimePkgs added to PATH). Used for bat, brave, devenv, codex, claude-code, omo, pi.
3. **Passthrough**: `pkgs.hyprland`, `pkgs.quickshell`, `inputs'.wlctl.packages.default`, `inputs'.pixie-sddm.packages.pixie-sddm`.
4. **Custom derivation**: tensaku (`buildRustPackage` from `tensaku-src` non-flake input), `writeShellScriptBin`/`writeShellApplication` helpers (e.g. `theme-apply`).
- `runtimePkgs` should prefer `self'.packages.<x>` (the wrapped versions) so tools share config (e.g. zsh gets wrapped bat/eza/fzf/nvim/zoxide).
- AI tools come from `inputs'.llm-agents.packages.*` (numtide/llm-agents.nix; opencode uses `opencode2`). claude-code currently uses generic `wrapPackage` though a dedicated `wrappers.claude-code` module exists (options: settings, agents, mcpConfig, pluginDirs, strictMcpConfig).
- Config that can't be wrapped goes to `/etc/xdg/...` (`environment.etc`) — hyprland (Lua config, per-host files picked by hostname), quickshell (QML, run as systemd user service). Runtime theming: `theme/matugen` — `theme-apply <wallpaper> [dark|light]` runs matugen (templates in `theme/matugen/templates`, Material roles like `{{colors.on_surface.default.hex}}`) into `~/.cache/matugen`, then links into `~/.config` and live-reloads kitty/swaync/tmux/nvim/hyprland. matugen must get `--source-color-index N` (or `--prefer ...`), else it prompts interactively; theme-apply keeps matugen's top `--show-source-colors` pick unless its HSL saturation < 12% (truly grey), then takes the most saturated candidate (raw RGB spread misjudged dark tinted colors like navy as grey, letting small red details tint everything brown); and uses `scheme-tonal-spot` (`MATUGEN_SCHEME` overrides); light mode adds `--lightness-light -0.07` since stock light surfaces are near-white. Templates can branch with `<* if {{ is_dark_mode }} *>…<* else *>…<* endif *>`. Qt = qt6ct palette + Darkly style (rounded Breeze fork, like end-4 dots; Kvantum removed); GTK = adw-gtk3 + gtk.css; icons Papirus; cursor BreezeX-RosePine. Hyprland loads `~/.cache/matugen/hyprland-colors.lua` at startup (`common/theme.lua`). Terminal tools follow kitty's ANSI palette (bat `ansi`, btop `TTY`, prompt `darkGray`); nvim uses mini.base16 from `nvim-colors.lua` (`config/matugen.lua`, catppuccin fallback; init.lua must `require` it *before* lazy setup because lazy.nvim resets the runtimepath). tmux sources `~/.cache/matugen/tmux-colors.conf` (tmux 3.8 underlines the current window by default → `window-status-current-style default`; 3.8 also paints the choose-tree preview frame/label solid grey via `tree-mode-border-style`, set to bg=default). Hyprland `rounding = 16`.
- Clipboard: cliphist services + `clipboard-helper` (services/clipboard, script in `clipboard-helper.sh`: list/preview/copy/delete; previews images, PDFs via pdftoppm, office via system `soffice` headless with its own profile, videos via ffmpegthumbnailer; cache in `$XDG_RUNTIME_DIR/nixc-clipboard`). UI = quickshell `ClipboardPanel.qml`, a bottom sheet (separate LazyLoader PanelWindow, not the pill; Hyprland layer rule `slide bottom`), opened by `qs ipc call island clipboard` (Super+Shift+V, falls back to fuzzel `clipboard-picker`).
- Quickshell top island = `Pill.qml`: one surface, one animated body (`bodyW/H/R`, M3 emphasized-decelerate) morphing between collapsed / `expanded` (click) / osd / panels; panel content is laid out at final size and revealed by the clipped body (no squeeze). `Settings.barStyle` "notch" draws it with `NotchShape.qml` (QtQuick.Shapes, flat edge + concave fillets into the screen edge; `edge: "bottom"` mirrors it, used by ClipboardPanel), "pill" = old floating rect. `Workspaces.qml` = sliding highlight capsule. Settings: `services/Settings.qml` merges Nix-generated `defaults.json` (attrset in quickshell/default.nix, `runCommand` copies it into the config dir) with runtime `~/.local/state/nixc/shell.json`; `qs ipc call settings set bar.style pill`.
- Quickshell runs as a systemd user service with an explicit `path`; anything QML or `uwsm app` must find (incl. launched apps' Exec) needs to be on it — it includes /run/current-system/sw.
- wlogout ignores /etc/xdg; its layout is passed via wrapper flags (one JSON object per button, NOT an array).
- swaync is patched (`overrideAttrs` postPatch in services/swaync): plain c/d clear/DND inside the panel (upstream only Shift+C/D; panel grabs the keyboard exclusively) and exclusive zone -1 so it ignores the quickshell pill's 60px reserved top and sits in the corner. `hl.layer_rule` gives it `slide top`. `hyprctl eval` prints errors, so it's a quick way to probe the Lua API.
- SDDM (pixie): package adds `theme.conf.user -> /var/lib/nixc-theme/theme.conf.user`; theme-apply copies the wallpaper + matugen `sddm-theme.conf` there (dir via tmpfiles, owned by paarth). Greeter compositor is weston with a custom ini/env for the cursor theme.
- awww user service needs `path = [awww]`: the daemon restores the last wallpaper by exec'ing the client.
- GUI scale: single source = per-host `scale` in `hyprland/config/hosts/<host>.lua` (1.0 on yoga; legion = native 2560x1600 @ 4/3, since in DDG mode the NVIDIA panel only offers 2560x1600; it also scales kitty/quickshell). Per-machine dconf default `text-scaling-factor` (machines/yoga/configuration.nix, 1.0) scales GTK + whole UI of Electron apps and browsers, not kitty/Qt; browsers (Firefox scales chrome by font DPI; `layout.css.dpi=0` does not stop it) blow up far more than Electron, so it stays 1.0 and Obsidian/VSCodium use in-app zoom. LibreWolf `clearPref("layout.css.devPixelsPerPx")` keeps it following the system. No per-app scale flags (they don't travel across machines). `system/desktop` sets `NIXOS_OZONE_WL=1` (Electron native Wayland, follows fractional scale) and adds gsettings-desktop-schemas to `XDG_DATA_DIRS` (session had none, so GTK/Electron couldn't read gsettings font/color-scheme).
- nvim: `M.clear_surfaces()` strips base00/base01 backgrounds from *every* highlight group (re-run on `User LazyLoad`), keeping selections/search; floats get `winborder = rounded`. StatusLine/CursorLine bgs are cleared (statusline text without bg inherits StatusLine's); lualine theme is built from the palette (`M.lualine_theme`), not `auto`.

## Layout / composition
- `modules/system/` OS plumbing; `core` = bootloader (systemd-boot, `mkDefault`)+hardware+locale+nix+user. `limine` (opt-in per host, yoga + legion, both with Secure Boot on) = themed Limine (static CachyOS splash + Catppuccin; Secure Boot hash-locks the config so no runtime theming), 10 s timeout (any key stops it), `nixc.boot.windowsEsp` adds a Windows chainload entry, Secure Boot via `boot.loader.limine.secureBoot.enable` after sbctl key enrollment. Its `extraInstallCommands` (run with an empty PATH → full store paths) renames the menu group "NixOS default profile" → "NixOS" with sed and (awk) moves all but the newest 5 generations into a collapsed "Older generations" folder (maxGenerations 10), so it must re-enroll the config hash (`limine enroll-config` + `b2sum`) into a fresh Limine and `sbctl sign` it, then copies it to `EFI/BOOT/BOOTX64.EFI`. `desktop` = core + audio/network/power/nix-ld + sddm/hyprland(UWSM)/quickshell/awww/swaync/hyprsunset/clipboard/screenshots/wlogout.
- `modules/components/<category>/<prog>/default.nix` one program each; group modules like `tools` (terminal/tools/default.nix) just `imports` others.
- `modules/presets/`: `workstation` = desktop+development+qol+ai+kitty+vscodium+tools+fonts; `development`; `qol`; `ai`; `server` = core+network+server/*.
- `modules/machines/<host>/{default,configuration,hardware}.nix`: `default.nix` defines `flake.nixosConfigurations.<host> = inputs.nixpkgs.lib.nixosSystem { modules = [preset hostConfiguration hostHardware]; }`.

## Machines
| host | hw | composition |
|---|---|---|
| yoga | Lenovo Yoga 6 13ALC6, AMD laptop (daily driver) | workstation; charge-to-100% (`charge_types=Standard` after upower + tmpfiles zeroing upower's saved threshold); lighter blur |
| legion | Lenovo Legion 16ACH6H, AMD + NVIDIA | workstation + limine (Secure Boot, MS keys); Windows on its own Samsung NVMe (ESP nvme1n1p1, RealTimeIsUniversal set in Windows); boot entries Default = hybrid PRIME (amdgpuBusId PCI:6:0:0, overrides nixos-hardware's 5:0:0) / ddg = firmware Dual-Direct GFX, NVIDIA only; temp nvidia patchelf + zenpower overlays (remove when nixpkgs #576412/#575192 fixed) |
| lazarus | generic Intel desktop, headless server | server + nix-ld + development; adguard owns :53/:3000, forgejo :3003, uptime-kuma :3001, ntfy :3002, headscale :8080, syncthing :8384 |
| mcbair | (MacBook Air?) not in the flake yet | — would need nix-darwin (aarch64-darwin), `flake.darwinModules`, and wrappers are cross-platform |

All `stateVersion = "26.05"`, nixos-unstable, kernel `linuxPackages_latest`, user `paarth`, TZ Asia/Kolkata.

## Commands
- Rebuild: `sudo nixos-rebuild switch --flake .#<host>` (zsh alias `nrs` = `sudo nixos-rebuild switch --flake`).
- Check without building: `nix flake check --no-build`. Build one package: `nix build .#<pkg>` (e.g. `.#zsh`, `.#nvim`). Try one: `nix run .#<pkg>`.
- Evaluate an option: `nix eval .#nixosConfigurations.yoga.config.<option.path>`.
- Format: alejandra. Repo dev shell: `devenv shell` (devenv.nix gives nixd configured for flake-parts options, lua-ls, stylua, qml).
- `docs/` has neovim.md (LSPs come from per-project devenv, no Mason), devenv.md, module-audit.md (server provisioning steps).

## Open tasks
- `docs/roadmap-hardening.md`: Limine + Secure Boot done on yoga and legion (Windows entry on legion); impermanence, sops-nix/secretspec, disko+LUKS+TPM unlock still planned.
- `nix flake check` currently fails on the neovim `builderFunction` toFile import (host builds are fine).

## Upstream docs
- flake-parts: https://flake.parts (module-arguments.html for moduleWithSystem/withSystem)
- import-tree: https://github.com/vic/import-tree (now denful/import-tree)
- Dendritic pattern: https://github.com/mightyiam/dendritic
- nix-wrapper-modules: https://nix-community.github.io/nix-wrapper-modules/ (repo moved BirdeeHub → nix-community; flake input still uses BirdeeHub URL)
- NixOS options: https://search.nixos.org/options ; nixos-hardware: https://github.com/NixOS/nixos-hardware
