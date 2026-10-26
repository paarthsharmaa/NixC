{self, ...}: {
  flake.nixosModules.ai = {
    imports = with self.nixosModules; [
      claudeCode
      codex
      omo
      opencode
      pi
    ];
  };
}
