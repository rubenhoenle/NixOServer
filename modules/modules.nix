{ pkgs, ... }: {
  imports = [
    ./backup.nix
    ./firmware.nix
    ./locales.nix
    ./networking.nix
    ./nix.nix
    ./podman.nix
    ./secrets.nix
  ];
}
