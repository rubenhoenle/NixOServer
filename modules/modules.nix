{ pkgs, agenix, ... }: {
  imports = [
    ./backup.nix
    ./boot.nix
    ./firmware.nix
    ./locales.nix
    ./networking.nix
    ./nix.nix
    ./podman.nix
    ./secrets.nix
    ./users.nix
  ];

  environment.systemPackages = with pkgs; [
    screenfetch
    agenix
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
