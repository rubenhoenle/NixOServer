{ pkgs, ... }: {
  imports = [
    ./endless-ssh.nix
    ./gickup.nix
    ./ssh.nix
    ./unbound.nix
    ./nginx.nix
    ./paperless.nix
    ./tandoor.nix
    ./matrix-bridge.nix
  ];
}
