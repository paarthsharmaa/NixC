{pkgs, ...}: {

  languages = {
    nix = {
      enable = true;
      lsp = {
        enable = true;
        package = pkgs.nixd;
      };
    };
  };
}
