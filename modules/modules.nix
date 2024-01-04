{ pkgs, ... }: {
  imports = [
    ./backup.nix
    ./locales.nix
    ./networking.nix
    ./nix.nix
    ./podman.nix
    ./secrets.nix
  ];
}
