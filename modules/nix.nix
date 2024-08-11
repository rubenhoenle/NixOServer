{
  system.autoUpgrade = {
    flake = "github:rubenhoenle/NixOServer";
    flags = [ "--accept-flake-config" ];
    randomizedDelaySec = "1h";
    allowReboot = true;
    rebootWindow = {
      lower = "04:00";
      upper = "06:00";
    };
    /* Note: This must be during the reboot window for the reboot to happen. */
    dates = "04:00";
  };

  nix = {
    # nix garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    # Enable experimental support for flakes
    settings.experimental-features = [ "nix-command" "flakes" ];
  };
}
