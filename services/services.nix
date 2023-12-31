{ pkgs, ... }: {
  imports = [
    ./endless-ssh.nix
    ./ssh.nix
    ./unbound.nix
    ./nginx.nix
    ./paperless.nix
  ];
}
