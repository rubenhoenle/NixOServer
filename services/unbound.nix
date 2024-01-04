{ config, pkgs, ... }:
{
  services.unbound = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      server = {
        interface = [ "127.0.0.1@53" ];
      };
    };
  };
}
