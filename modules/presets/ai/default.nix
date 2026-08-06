{self, ...}: {
  flake.nixosModules.ai = {
    imports = with self.nixosModules; [
      opencode
      codex
    ];
  };
}
