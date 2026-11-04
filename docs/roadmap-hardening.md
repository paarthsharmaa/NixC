# Roadmap: hardening NixC (impermanence, secrets, LUKS, Secure Boot, dual boot)

Status: **planned, not started** (written 2026-11-04). Start this in a fresh session:
"read docs/roadmap-hardening.md and let's start phase N".

Goal: give the dendritic/homeless flake hand-written versions of the features
[anotherhadi/nixy](https://github.com/anotherhadi/nixy) has, so every machine is
encrypted, reproducible from the repo, and Legion can dual boot Windows (gaming)
and NixOS (development) with Secure Boot on.

## Constraints that shape the design

- Stay homeless: no home-manager. nixy uses **hjem** for home files and
  per-user persistence; for us, home persistence goes through
  `environment.persistence."/persist".users.paarth` (impermanence's NixOS module),
  and per-program state is declared next to the program's module.
- Stay dendritic: each feature is one `flake.nixosModules.<name>` file that
  hosts opt into. Non-module Nix files (disko layouts, secret declarations) go in
  `_`-prefixed paths so import-tree skips them (nixy: `hosts/laptop/_disko.nix`).
- A module may declare persistence even on hosts without impermanence: import the
  impermanence NixOS module everywhere with `/persist` disabled (nixy's
  `hosts/common.nix` trick), so `environment.persistence...` is a harmless no-op.
- LUKS + tmpfs root means **reinstalling** each machine (repartition with disko).
  Back up first; do one machine at a time.

## Phase 0 — prep (no reinstall)
- Add inputs: `disko`, `impermanence`, `lanzaboote`, `sops-nix` (all
  `inputs.nixpkgs.follows = "nixpkgs"`).
- Add a small `options.nixc.*` host-values module (username, persist path),
  like nixy's `nixy.username`, so modules stop hard-coding `paarth`.
- Fix the existing `nix flake check` failure (neovim `builderFunction`
  `import (builtins.toFile ...)`) so checks can gate changes.

## Phase 1 — secrets (no reinstall)
- **sops-nix** for system/service secrets. Module `modules/system/secrets/`:
  imports `inputs.sops-nix.nixosModules.sops`, installs `sops` + `age`.
  - Keys: derive each host's age key from its SSH host key
    (`ssh-to-age`, `sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"]`),
    plus one personal age key for editing. Avoid nixy's TODO (a user-readable
    key that decrypts every host).
  - `.sops.yaml` at repo root with creation rules per host.
  - Per-host `modules/machines/<host>/_secrets/{default.nix,secrets.yaml}`.
  - First consumers: lazarus — restic password (replaces
    `/etc/nixos/restic-password`), AdGuard/Forgejo/ntfy admin creds, headscale
    preauth key; all hosts — `users.users.paarth.hashedPasswordFile`, wifi PSKs.
- **secretspec** (cachix) for *project* secrets in devenv shells, not system
  secrets: `secretspec.toml` per project, `devenv` integration, keyring backend.

## Phase 2 — disko + LUKS (reinstall per host)
- `modules/machines/<host>/_disko.nix` (nixy layout):
  ESP vfat `/boot` (≥1 GiB so lanzaboote UKIs fit) → LUKS2 `crypted`
  (`allowDiscards`) → btrfs subvolumes `/nix`, `/persist`, (`/swap` with swapfile
  for hibernate), `/` = tmpfs (`size=…, mode=755`).
- `fileSystems."/persist".neededForBoot = true`.
- Replace current `hardware.nix` fileSystems/swap with `inputs.disko.nixosModules.disko`.
- TPM2 unlock (optional, after Secure Boot): `boot.initrd.systemd.enable = true`,
  `systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7` (PCR 7 = Secure Boot
  state), keep the passphrase as fallback.
- lazarus: also the `backups` disk; consider LUKS + keyfile on `/persist`.

## Phase 3 — impermanence
- Module `modules/system/impermanence/`: `environment.persistence."/persist"`
  with: `/var/lib/nixos`, `/var/lib/systemd/{coredump,timers}`, `/var/log`,
  `/etc/machine-id`, SSH host keys, `/var/lib/systemd/random-seed`,
  `/var/lib/bluetooth`, `/etc/NetworkManager/system-connections`, `/var/lib/sbctl`.
- Service modules declare their own state next to themselves (dendritic):
  forgejo `/var/lib/forgejo`, postgres, syncthing, adguardhome, headscale,
  tailscale `/var/lib/tailscale`, uptime-kuma, docker, fprint, etc.
- Home (`users.paarth`): `NixC`, `code`, `Documents`, `Downloads`, `Pictures`,
  `Videos`, `.ssh`, `.local/share`, `.local/state`, `.cache/matugen`,
  browser profiles (`.librewolf`, `.config/BraveSoftware`), `.config/obsidian`,
  `.claude`, zsh history, `.config/sops/age`.
- Workflow help: a `persist-diff` script (find files on `/` not in the store or
  `/persist`) to discover missing state before it's lost.

## Phase 4 — Secure Boot (lanzaboote) + Legion dual boot
- Module `modules/system/secureboot/`: `inputs.lanzaboote.nixosModules.lanzaboote`,
  `boot.loader.systemd-boot.enable = lib.mkForce false`,
  `boot.lanzaboote = { enable = true; pkiBundle = "/var/lib/sbctl"; }`, `sbctl`.
- One-time per machine: `sbctl create-keys` → firmware Setup Mode → rebuild →
  `sbctl enroll-keys --microsoft` (Microsoft keys keep Windows + GPU option ROMs
  booting) → enable Secure Boot. Verify with `bootctl status` / `sbctl verify`.
- **Legion dual boot**:
  - Install Windows first (own partitions), then NixOS. Prefer a separate disk
    or at least separate partitions; shared ESP must be big enough.
  - Windows appears in systemd-boot automatically if on the same ESP; if it's on
    another ESP/disk, check what lanzaboote supports for extra entries
    (`boot.loader.systemd-boot.windows` only applies to plain systemd-boot) —
    verify before relying on it.
  - **BitLocker**: save the recovery key before enrolling Secure Boot keys —
    changing the Secure Boot DB triggers BitLocker recovery.
  - Set `time.hardwareClockInLocalTime = true` or set Windows to UTC
    (`RealTimeIsUniversal`) to stop clock drift between OSes.
  - Disable Windows Fast Startup (keeps NTFS dirty/locked).
  - Optional: `boot.loader.timeout`, `systemctl reboot --boot-loader-entry=…`
    keybind/script for "reboot into Windows".
  - NVIDIA: keep the patchelf/zenpower workarounds in `legionConfiguration`
    until the upstream issues close.

## Phase 5 — extras from nixy worth considering
- `kernel-hardening` sysctls module (dmesg/kptr restrict, ptrace scope, bpf…);
  check nothing in the workflow (perf, docker, debugging) breaks.
- `usbguard` with per-host rules (`usbguard generate-policy`).
- nixpak/bubblewrap sandboxing for untrusted GUI apps.
- `nix-index-database` (`comma`, command-not-found).
- disko-based `nixos-anywhere` installs for lazarus.

## Order suggestion
Phase 0 → 1 on all hosts (no reinstall) → Legion fresh install with
2+3+4 (it needs repartitioning for Windows anyway) → yoga → lazarus last
(most stateful; migrate service data into `/persist`).

## References
- nixy: https://github.com/anotherhadi/nixy (`modules/system/{impermanence,secrets}.nix`,
  `modules/system/boot/lanzaboote.nix`, `modules/hosts/laptop/_disko.nix`)
- impermanence: https://github.com/nix-community/impermanence
- disko: https://github.com/nix-community/disko
- lanzaboote: https://github.com/nix-community/lanzaboote (docs/QUICK_START.md)
- sops-nix: https://github.com/Mic92/sops-nix
- secretspec: https://secretspec.dev
- NixOS wiki: Impermanence, Secure Boot, Full Disk Encryption, Dual Booting
