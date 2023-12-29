{ pkgs, ... }: {
  imports = [
    ./locales.nix
    ./networking.nix
    ./secrets.nix
    ./backup.nix
  ];
}
