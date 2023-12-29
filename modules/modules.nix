{ pkgs, ... }: {
  imports = [
    ./locales.nix
    ./networking.nix
  ];
}
