{ config, pkgs, ... }:
{
  services.unbound = {
    enable = true;
    settings = {
      server = {
        interface = [ "0.0.0.0@53" ];
      };
    };
  };
}
