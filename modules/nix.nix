{
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
