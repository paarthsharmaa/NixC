{...}: {
  flake.nixosModules.bat = {...}: {
    programs.bat = {
      enable = true;

      settings = {
        # No line numbers, grid, header or other decorations.
        # Syntax highlighting remains enabled.
        style = "plain";

        # Behave like cat unless explicitly piped into a pager.
        paging = "never";
      };
    };
  };
}
