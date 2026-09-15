{self, ...}: {
  flake.nixosModules.audio = {pkgs, ...}: {
    imports = with self.nixosModules; [
      wiremix
    ];

    environment.systemPackages = with pkgs; [
      pavucontrol
      playerctl
    ];

    services.pulseaudio.enable = false;

    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;

      alsa = {
        enable = true;
        support32Bit = true;
      };

      pulse.enable = true;
      jack.enable = true;
    };
  };
}
