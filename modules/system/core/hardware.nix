{...}: {
  flake.nixosModules.hardware = {...}: {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;

      settings = {
        General = {
          ControllerMode = "dual";
          Experimental = true;
        };

        Policy = {
          AutoEnable = true;
        };
      };
    };

    services.blueman.enable = true;

    # Explicitly enable the PipeWire session manager.
    services.pipewire.wireplumber.enable = true;
  };
}
