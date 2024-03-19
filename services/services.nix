{ pkgs, ... }: {
  imports = [
    ./endless-ssh.nix
    ./gickup.nix
    ./hedgedoc.nix
    ./homer.nix
    ./seafile.nix
    ./ssh.nix
    ./unbound.nix
    ./nginx.nix
    ./paperless.nix
    ./tandoor.nix
    ./matrix-bridge.nix
  ];
}
