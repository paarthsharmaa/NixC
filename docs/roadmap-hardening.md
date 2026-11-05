# Roadmap: hardening NixC (impermanence, secrets, LUKS, Secure Boot, dual boot)

Status: Phase 4 (Limine) started 2026-11-05; rest planned (written 2026-11-04). Start this in a fresh session:
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
- Add inputs: `disko`, `impermanence`, `sops-nix` (all
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
  ESP vfat `/boot` (≥1 GiB: Limine copies every kept generation's kernel+initrd there) → LUKS2 `crypted`
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

## Phase 4 — Secure Boot (Limine) + Legion dual boot
Status: Limine module done (`modules/system/limine`, 2026-11-05), yoga opted in;
Secure Boot keys not enrolled yet. Replaces the earlier lanzaboote plan:
nixpkgs' `boot.loader.limine.secureBoot` signs Limine with sbctl and enrolls a
hash of limine.conf into the binary; every kernel/initrd path carries a blake2b
hash, so only our generations boot. Editor is forced off under Secure Boot.
- Theme is static (CachyOS look: `limine-splash.png`, Catppuccin Mocha):
  under Secure Boot the config is hash-locked, so no runtime/matugen theming.
- Host opt-in: add `limine` to the host's module list (core's systemd-boot is
  `mkDefault`, Limine turns it off).
- One-time per machine, after Limine boots fine:
  1. Firmware: Secure Boot → reset to **Setup Mode** (clears PK).
  2. `sudo sbctl create-keys` → `sudo sbctl enroll-keys --microsoft`
     (Microsoft keys keep Windows, GPU option ROMs and firmware tools booting).
  3. Host config: `boot.loader.limine.secureBoot.enable = true;` → `nrs`.
  4. `sudo sbctl verify` (Limine EFI signed) → firmware: enable Secure Boot →
     `sbctl status` / `bootctl status` show it on.
  - Back up `/var/lib/sbctl` (keys). With impermanence it must be persisted.
  - The old systemd-boot NVRAM entry stays as a fallback only while Secure Boot
    is off (it's unsigned). Recovery = turn Secure Boot off in firmware.
- **Legion dual boot**: install Windows (own disk preferred), then set
  `nixc.boot.windowsEsp = "<PARTUUID of Windows ESP>";` (`lsblk -o
  NAME,PARTUUID,PARTTYPENAME`). Entry uses `protocol: efi` → firmware verifies
  Microsoft's signature, no Limine hash, survives Windows updates.
  - **BitLocker**: save the recovery key before enrolling keys / chainloading.
  - `time.hardwareClockInLocalTime = true` or Windows `RealTimeIsUniversal`.
  - Disable Windows Fast Startup.
  - Windows is listed after the generations; consider `remember_last_entry`
    (via `boot.loader.limine.extraConfig`) on Legion.
- **TPM2 auto-unlock with Limine** (ties into Phase 2): Limine does not
  measure kernel/initrd into TPM PCRs, so bind to PCR 7 (Secure Boot state +
  our enrolled keys) — safe only because Secure Boot + enrolled config hash
  stop anything but our signed generations from booting. Add PCR 15
  (`tpm2-measure-pcr=yes` in crypttab, systemd initrd) so a swapped root
  volume can't receive the key. Re-enroll after changing Secure Boot keys.
  Keep a passphrase + recovery key slot.

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
