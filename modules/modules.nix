{ pkgs, agenix, ... }: {
  imports = [
    ./firmware.nix
    ./locales.nix
    ./networking.nix
    ./nix.nix
    ./secrets.nix
    ./users.nix
  ];

  environment.systemPackages = with pkgs; [
    screenfetch
    agenix
    git
    vim
    tldr
  ];
}
