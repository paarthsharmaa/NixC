{...}: {
  flake.nixosModules.audio = {pkgs}: {
    environment.systemPackages = with pkgs; [
      pavucontrol
      playerctl
    ];
    services.pulseaudio.enable = false;
    services.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.enable32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };
}
