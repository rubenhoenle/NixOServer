{ pkgs, ... }:
{
  imports = [
    ./gatus.nix
    ./gickup.nix
    ./hedgedoc.nix
    ./homer.nix
    ./ssh.nix
    ./unbound.nix
    ./nginx.nix
    ./paperless.nix
    ./tandoor.nix
    ./matrix-bridge.nix
    ./stashapp.nix
    ./nextcloud.nix
    ./postgres.nix
  ];
}
