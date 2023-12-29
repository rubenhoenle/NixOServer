{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    curl
    restic
    screenfetch
    htop
  ];

  home.stateVersion = "23.11";

  home.username = "ruben";
  home.homeDirectory = "/home/ruben";

  programs.home-manager.enable = true;

  # make vim the default editor
  programs.vim.defaultEditor = true;

  imports = [
    ./git.nix
    ./vim.nix
    ./bash.nix
  ];
}
