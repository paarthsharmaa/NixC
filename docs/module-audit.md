# Module audit: `7916b28`

Reviewed the Nix modules added or changed by “added server modules qol programs - audio/doc/img viewer” against the existing Bluetui, Wiremix, and staged Persepolis modules, the pinned dependencies, and upstream documentation.

## Findings and repairs

| Module | Finding | Repair |
| --- | --- | --- |
| Zathura | Wrote `/etc/xdg/zathura/zathurarc` but never installed the application. | Export and install the upstream Zathura wrapper, including its configuration and PDF/MuPDF, DjVu, PostScript, and comic-book plugins. |
| Default applications | LibreOffice MIME defaults named desktop files absent from the pinned package. The generic Zathura entry did not advertise document MIME types. | Use `writer.desktop`, `calc.desktop`, `impress.desktop`, and `org.pwmt.zathura-pdf-mupdf.desktop`. |
| LibreOffice, Loupe, mpv, Spotify | Installed plain nixpkgs packages, unlike the repository's reusable application packages. This alone was not an application failure. | Export wrappers through `perSystem.packages` and install them through `moduleWithSystem`, matching Bluetui and Persepolis. |
| Flake package set | NixOS's `nixpkgs.config.allowUnfree` does not configure the separate `perSystem` package set. Exporting Spotify exposed an unfree evaluation failure. | Configure `perSystem`'s nixpkgs instance with the same unfree policy. |
| Syncthing | `settings.gui.address` was superseded by NixOS's `--gui-address=127.0.0.1:8384`. Empty declarative device/folder lists also removed UI-created entries at restart. | Set `guiAddress`, preserve UI-managed peers/shares, and use `openDefaultPorts` for sync and discovery ports. |
| Tailscale | `extraUpFlags` had no effect because `authKeyFile` was unset. | Use `extraSetFlags`, which NixOS applies independently of automatic authentication. |
| Headscale | Embedded DERP requires HTTPS, but `server_url` used HTTP. All external relay maps were disabled. | Disable embedded DERP, restore the public relay map and refreshes, and remove the unused STUN firewall port. |
| AdGuard Home | Pinned schema 29 although the installed package uses schema 34; filtering was configured under the wrong object/key. | Let the NixOS module select the package schema and set `filtering.filtering_enabled`. |
| Forgejo | Advertised `git.lazarus` for SSH but `lazarus` for HTTP, with no DNS record for the extra name. | Advertise `lazarus` consistently. |
| Uptime Kuma / ntfy | ntfy advertised `http://ntfy.lazarus`, which implied port 80 and an unconfigured DNS name, while listening on 3002. | Advertise `http://lazarus:3002`. |
| Restic | Copied live PostgreSQL files, omitted Syncthing configuration/identity, and could initialize a repository on the root filesystem when the optional backup disk was absent. | Create a PostgreSQL dump before backing up, include Syncthing's config directory, require the backup mount, and check the mount before repository initialization. Derive the repository name from the host name. |

Wiremix, the audio import, OpenSSH/fail2ban, both presets, and the Lazarus module composition evaluated correctly. The existing `nix-ld` expression is also valid: `moduleWithSystem` accepts the returned attribute set directly. No restructuring was needed for those modules.

The Neovim bufferline change was also reviewed: it removes references to an absent LazyVim global and retains the existing Snacks integration. Interactive editor behavior was not exercised.

## Validation

- `nix flake check --no-build --no-write-lock-file` passed for the three host configurations and all exported packages/modules.
- Built `.#zathura`, `.#libreoffice`, `.#loupe`, `.#mpv`, `.#spotify`, and `.#wiremix` successfully.
- Zathura's executable reported all four document plugins; its generated `zathurarc` contains the configured palette. mpv's executable reported its version successfully.
- Checked application executables and the document/media MIME handlers against the built packages.
- AdGuard Home's generated configuration passed its native `--check-config` validator, including nixpkgs's configuration derivation check.
- Headscale's generated configuration passed `configtest` with state/socket paths relocated to a temporary directory. Its endpoints, relay settings, DNS settings, and other configuration were retained.
- Fifteen effective-configuration assertions passed, covering desktop package installation on Yoga/Legion, exclusion from Lazarus, document associations, enabled server services, Syncthing persistence/listening, Tailscale flag application, Headscale relays, AdGuard schema/DNS ownership, advertised service URLs, backup paths/mount guards, and nix-ld on all hosts.

These checks evaluate configurations and build packages. Live service connectivity, GUI interaction, and a complete backup/restore cycle still require the corresponding machines and their provisioned state.

## Server provisioning

The service modules cannot supply machine-specific credentials or discover the server's LAN address. Before relying on Lazarus:

- Make `lazarus` resolve to its LAN address for clients, or change the service URLs to a resolvable name/address.
- Add your SSH public keys to `users.users.paarth.openssh.authorizedKeys.keys`; password authentication is disabled.
- Register the Tailscale client with Headscale manually using `sudo tailscale up --login-server=http://lazarus:8080 --ssh --accept-dns=false`, then approve/register the node through Headscale. No automatic enrollment key is configured.
- Provision Forgejo's initial administrator, ntfy's users/access rules, and AdGuard Home's administrator credentials. The declarative AdGuard configuration contains no users, so its generated configuration initially has authentication disabled; do not expect the first-run wizard to create credentials automatically.
- Mount the disk labelled `backups` and provide `/etc/nixos/restic-password` with the password for the repository. Confirm that `/etc/nixos` is the configuration source you intend to back up. Add any Syncthing shares stored outside its configured data directory to the backup paths.

| Service | Address |
| --- | --- |
| AdGuard Home UI | `http://lazarus:3000` |
| Uptime Kuma | `http://lazarus:3001` |
| ntfy | `http://lazarus:3002` |
| Forgejo | `http://lazarus:3003` |
| Headscale | `http://lazarus:8080` |
| Syncthing UI | `http://lazarus:8384` |

## References

- [flake-parts module arguments and `moduleWithSystem`](https://flake.parts/module-arguments.html)
- [The dendritic pattern](https://github.com/mightyiam/dendritic)
- [nix-wrapper-modules](https://nix-community.github.io/nix-wrapper-modules/)
- [Pinned Zathura wrapper implementation](https://github.com/BirdeeHub/nix-wrapper-modules/blob/6e7f66fa2cdf4d63162580b438f7fcf87c28a46f/wrapperModules/z/zathura/module.nix)
- [Pinned NixOS Syncthing module](https://github.com/NixOS/nixpkgs/blob/6510408d147d8c5e6d76043e899e9251756f6a75/nixos/modules/services/networking/syncthing.nix)
- [Pinned NixOS Tailscale module](https://github.com/NixOS/nixpkgs/blob/6510408d147d8c5e6d76043e899e9251756f6a75/nixos/modules/services/networking/tailscale.nix)
- [Headscale example configuration and DERP requirements](https://github.com/juanfont/headscale/blob/main/config-example.yaml)
- [AdGuard Home configuration](https://adguard-dns.io/kb/adguard-home/configuration/)
