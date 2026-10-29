# Neovim with project environments

Nix builds the Neovim wrapper and its Lua configuration. lazy.nvim manages plugins,
including LSP configuration, completion, snippets, Treesitter and Conform. Language
servers, formatters, compilers, libraries and environment variables belong in each
project's `devenv.nix`. No Mason or direnv integration is used.

## Launch from the project environment

```sh
cd ~/projects/my-project
devenv shell
nvim .
```

Or run a single command:

```sh
devenv shell -- nvim .
```

The existing Zsh `devenv hook zsh` also works: run `devenv allow` once in a trusted
project, enter its directory, then launch Neovim. The hook activates the environment
before Neovim starts; no editor environment plugin is required.

Neovim and its subprocesses inherit PATH and variables from that shell. Opening a
different project's files or running `:cd` inside an existing Neovim process does
not activate that project's environment. Start a separate Neovim process from its
devenv shell. Restart Neovim after changing project tools or environment variables;
`:LspRestart` alone cannot import a new parent-shell environment. The same applies
to editors launched by an existing tmux pane or a desktop launcher.

## Tools Neovim understands

Only include the tools needed by a particular project. Configuring a server in Lua
does not install it. Missing servers are skipped; missing formatters leave files
untouched. Diagnostics come from the language servers (including Ruff and ESLint).

| Language | Server executable | Formatter | Project packages |
| --- | --- | --- | --- |
| Python | `pyright-langserver`, `ruff server` | `ruff`, or `black` | `pyright`, `ruff`, `uv` |
| Rust | `rust-analyzer` | `rustfmt` | `languages.rust.enable = true` supplies the default components |
| TypeScript / JavaScript | `typescript-language-server` | `prettierd`, or `prettier` | `typescript-language-server`, `typescript`, `prettier`; Node via `languages.javascript` |
| HTML / CSS | `vscode-html-language-server`, `vscode-css-language-server` | `prettierd`, or `prettier` | `vscode-langservers-extracted`, `prettier` |
| JS / TS linting | `vscode-eslint-language-server` | Use code actions for fixes | `vscode-langservers-extracted`, plus project-local ESLint and its configuration |
| Nix | `nixd`; `devenv lsp` for `devenv.nix` and `devenv.local.nix` | `alejandra`, or `nixfmt` | `nixd`, `alejandra` |
| QML | `qmlls -E` | `qmlformat` | `qt6.qtdeclarative`, plus the project's QML import paths |
| Lua | `lua-language-server` | `stylua` | `lua-language-server`, `stylua` |

The Neovim wrapper only adds editor utilities: Git for lazy.nvim, search tools and
the Wayland clipboard provider. It appends these to PATH, preserving project tool
precedence. Remote Python, Node and Ruby plugin hosts are disabled; these Lua plugins
do not need them. A project can still provide Node or Python for its language tools.

### Python with uv

Keep Python and its virtual environment in the project, managed by uv:

```nix
{pkgs, ...}: {
  packages = with pkgs; [uv pyright ruff];
}
```

```sh
devenv shell
uv sync
uv run nvim .
```

This assumes an existing `pyproject.toml`; use `uv init` for a new project. uv
selects/provisions Python and `.venv` according to the project. Neovim passes the
activated `python` executable to Pyright.

### Rust

```nix
{...}: {
  languages.rust.enable = true;
}
```

devenv's default Rust components include Cargo, rustc, rust-analyzer, rustfmt and
Clippy. Project `Cargo.toml`, `rust-toolchain.toml` and `.cargo/config.toml` still
control the corresponding Rust tooling. Keep additional native libraries and build
variables in this environment too.

### Web projects

```nix
{pkgs, ...}: {
  languages.javascript.enable = true;
  packages = with pkgs; [
    typescript
    typescript-language-server
    vscode-langservers-extracted
    prettier
  ];
}
```

Neovim uses executables from PATH. devenv's JavaScript module also exposes the
project's `node_modules/.bin`. Keep ESLint and project plugins in `package.json` and
commit the package manager lockfile. The ESLint client only attaches where its
upstream configuration detects an ESLint project. Prettier uses project settings.

### QML

```nix
{pkgs, lib, ...}: {
  packages = [pkgs.qt6.qtdeclarative];
  env.QML_IMPORT_PATH = lib.makeSearchPath "lib/qt-6/qml" [
    pkgs.qt6.qtdeclarative
    pkgs.quickshell # For a Quickshell project; omit otherwise.
  ];
}
```

Use matching Qt and Quickshell packages from the project's nixpkgs. For CMake
projects, also generate the project's `.qmlls.ini` / build metadata. Neovim starts
`qmlls` with `-E` to read the environment's QML import paths. NixC's own devenv
already supplies the tools and Qt/Quickshell import paths for its shell configuration.

## Nix and dendritic completion

`devenv lsp` launches nixd with devenv's evaluated option schema and package set.
It runs in the directory containing `devenv.nix`, including when Neovim starts in a
subdirectory. Other Nix files use the project's `nixd` executable. If devenv is
unavailable, a present `nixd` can handle `devenv.nix` with its ordinary settings.

For NixOS projects, `env.NVIM_NIXD_NIXOS_FLAKE = config.devenv.root` opts into
completion from that flake's `nixosConfigurations.<current-hostname>.options`.
The host must exist in that flake. NixC declares this already for Yoga and Legion.

Additional nixd settings can be supplied declaratively as JSON in a store file:

```nix
{pkgs, config, ...}: {
  packages = [pkgs.nixd pkgs.alejandra];
  env.NVIM_NIXD_SETTINGS_FILE = pkgs.writeText "nixd-settings.json" (builtins.toJSON {
    nixpkgs.expr = ''import (builtins.getFlake "path:${config.devenv.root}").inputs.nixpkgs {}'';
  });
}
```

The contents are the `nixd` settings object, without an outer `nixd` key. NixC's
`devenv.nix` additionally evaluates its flake-parts module tree for option completion,
including its dendritic declarations. Keep these project-specific expressions out
of the reusable Lua configuration. Invalid settings files generate a warning and
fall back to ordinary nixd settings.

## Commands and keys

- `:ProjectTools`: show executable paths and the active devenv root.
- `:checkhealth vim.lsp` and `:LspInfo`: inspect clients; `:LspLog` shows server errors.
- `:ConformInfo`: inspect formatter availability.
- `<leader>cf`: format the buffer or selection. There is no automatic format on save.
- `gd`, `gr`, `K`, `<leader>rn`, `<leader>ca`: definition, references, hover, rename, code actions.
- `<C-Space>`: completion; Enter accepts an explicitly selected suggestion.
- Tab / Shift-Tab: completion selection and snippet expansion/jumps, with normal-key fallback.

## Treesitter and lazy.nvim updates

Launch Neovim in NixC's `devenv shell`, then run `:TSInstallProject` once. This
installs parsers for all configured languages into the writable Neovim data
directory; they can then be reused in other projects without compilers. The command
checks for a C compiler, `tree-sitter`, `curl` and `tar`, all provided by NixC's
devenv. It does not install missing tools. Until a parser is installed, regular
syntax highlighting remains available.

Treesitter uses its current `main` API and requires Neovim 0.12+. After updating it
through lazy.nvim, run `:TSUpdate` from the same environment to synchronize parsers
with its queries. A NixOS rebuild does not install or update lazy.nvim plugins.

Your writable lazy lockfile remains under `stdpath("state")`. The repository's
`lazy-lock.json` seeds fresh installations; existing writable lockfiles are preserved.
After intentional plugin updates, copy that writable lockfile back into the
repository to make the revisions reusable on other machines.

## References

- [devenv language server](https://devenv.sh/lsp/)
- [devenv activation](https://devenv.sh/auto-activation/)
- [Neovim LSP configuration](https://neovim.io/doc/user/lsp/)
- [nixd configuration](https://github.com/nix-community/nixd/blob/main/nixd/docs/configuration.md)
- [Treesitter setup and requirements](https://github.com/nvim-treesitter/nvim-treesitter)
- [QML language server import paths](https://doc.qt.io/qt-6/qtqml-tooling-qmlls.html)
