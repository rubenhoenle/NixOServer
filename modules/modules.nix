{ pkgs, agenix, ... }: {
  imports = [
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
}
