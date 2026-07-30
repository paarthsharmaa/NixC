{ 
  self,
  inputs,
  ...
}: {
  flake.nixosModules.audio = {
    pkgs,
    lib,
   }: {
	environment.systemPackages = with pkgs; [
	  playerctl
	  pavuconrol
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
  
