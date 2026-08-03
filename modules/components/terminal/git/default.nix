{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.git = moduleWithSystem (
    {self', ...}: {...}: {
      programs.git = {
        enable = true;
        package = self'.packages.git;
      };
    }
  );
  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: {
    packages.git = inputs.wrappers.wrappers.git.wrap {
      inherit pkgs;

      settings = {
        user = {
          name = "paarthsharmaa";
          email = "paarthsharma0912@gmail.com";
        };

        init.defaultBranch = "main";

        core = {
          editor = lib.getExe self'.packages.nvim;
          autocrlf = "input";
        };
        pull.rebase = false;
        fetch.prune = true;
        push.autoSetupRemote = true;

        rerere.enabled = true;
        diff.colorMoved = "default";
        merge.conflictStyle = "zdiff3";
      };
    };
  };
}
