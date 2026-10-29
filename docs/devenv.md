# Development environments with devenv

The `development` preset installs the wrapped devenv CLI on Yoga, Legion, and Lazarus. The Zsh wrapper uses the same package for its existing auto-activation hook.

For the shared editor setup, project language servers, formatters, uv, and QML
imports, see [Neovim with project environments](neovim.md). Launch Neovim from
`devenv shell` (or after devenv's native Zsh activation); no direnv is needed.

## Enable the new module

From the NixC checkout on Yoga:

```sh
git add modules/components/terminal/devenv/default.nix
sudo nixos-rebuild switch --flake .#yoga
exec zsh
```

Git-based flakes include new files after Git tracks them. Use the corresponding host name when rebuilding another machine.

## Create a project environment

Run these commands inside your project's directory:

```sh
mkdir -p ~/projects/python-demo
cd ~/projects/python-demo
devenv init
```

`devenv init` creates `devenv.nix`, `devenv.yaml`, and Git ignore rules. `devenv.nix` describes the project's tools and behavior; `devenv.yaml` defines its Nix inputs. The generated `devenv.lock` pins those inputs.

Put each project's `devenv.nix` in that project's root. Files beneath NixC's `modules/` are automatically imported as flake-parts modules, so project environment definitions do not belong there.

Replace the project's generated `devenv.nix` with:

```nix
{pkgs, ...}: {
  packages = [
    pkgs.git
    pkgs.jq
  ];

  languages.python = {
    enable = true;
    venv.enable = true;
  };

  env.APP_ENV = "development";

  enterShell = ''
    echo "Python environment ready"
    python --version
  '';

  scripts.serve.exec = "python -m http.server 8000 --bind 127.0.0.1";
  processes.web.exec = "serve";
}
```

Enter the environment:

```sh
devenv shell
python --version
echo "$APP_ENV"
serve
```

`packages` adds Nix tools to the environment. `languages.python` supplies Python and activates a project virtual environment. `env` sets variables, `enterShell` runs startup commands, and `scripts` adds commands such as `serve` to the environment's PATH.

Use `Ctrl-C` to stop the example HTTP server and `exit` to leave a manually entered shell. Run a single command without staying in the shell with `devenv shell -- python --version`.

To manage the declared web process with devenv, run `devenv up` from the project directory. The example serves the project directory at `http://127.0.0.1:8000`. Service and process data belong to the project environment, and changes to this file are applied through devenv rather than a NixOS rebuild.

## Python dependencies

For a project with a `requirements.txt`, extend `languages.python` with:

```nix
venv.requirements = ./requirements.txt;
```

For a project managed with uv and a `pyproject.toml`, use:

```nix
languages.python = {
  enable = true;
  venv.enable = true;
  uv = {
    enable = true;
    sync.enable = true;
  };
};
```

Manage Python dependencies with `uv add` and commit `pyproject.toml` and `uv.lock` with the project.

## Other stacks

For JavaScript, replace the Python language settings and Python-specific scripts/startup commands with your project's equivalents:

```nix
languages.javascript = {
  enable = true;
  npm.enable = true;
};

scripts.dev.exec = "npm run dev";
processes.web.exec = "dev";
```

This assumes the project has a `package.json` defining a `dev` script. Enter with `devenv shell`, run `npm install`, then `dev`, or start the declared process with `devenv up`.

To add a project PostgreSQL instance:

```nix
services.postgres = {
  enable = true;
  initialDatabases = [{name = "app";}];
};
```

Start it using `devenv up`. Its data is kept in the project's devenv state directory. If another PostgreSQL server already uses the default port, set a different `services.postgres.port` in this project.

## Auto activation and updates

Your Zsh configuration already evaluates `devenv hook zsh`. Run `devenv allow` once inside a project to enable automatic activation on subsequent directory changes. Use `devenv revoke` in that project to disable it.

Commit `devenv.nix`, `devenv.yaml`, `devenv.lock`, and language dependency manifests/lockfiles. Keep generated state, virtual environments, and credentials out of Git using the project's ignore rules. Run `devenv update` when you intentionally want newer Nix inputs; this is separate from updating NixC's flake or the installed devenv CLI.

## Documentation

- [Getting started and CLI commands](https://devenv.sh/getting-started/)
- [Packages, variables, and shell setup](https://devenv.sh/basics/)
- [Python, virtual environments, and uv](https://devenv.sh/languages/python/)
- [JavaScript](https://devenv.sh/languages/javascript/)
- [Scripts](https://devenv.sh/scripts/)
- [PostgreSQL](https://devenv.sh/services/postgres/)
- [Auto activation](https://devenv.sh/auto-activation/)
- [Inputs and lockfiles](https://devenv.sh/inputs/)
