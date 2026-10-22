{self, ...}: {
  flake.nixosModules.ai = {
    imports = with self.nixosModules; [
      opencode
      codex
      pi
      omo
    ];
  };
}
