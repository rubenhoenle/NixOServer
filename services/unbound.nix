{ config, pkgs, ... }:
{
  services.unbound = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      server = {
        interface = [ "127.0.0.1@53" "enp0s31f6@53" ];
        access-control = [
          "127.0.0.0/8      allow"
          "::1/128          allow"
          "192.168.178.0/24 allow"
        ];
        local-data = [
          "\"paperless.local A 192.168.178.5\""
          "\"tandoor.local   A 192.168.178.5\""
          "\"mandalore       A 192.168.178.5\""

          "\"fritz.box       A 192.168.178.1\""
          "\"fritz.repeater  A 192.168.178.3\""

          "\"printer01           A 192.168.178.20\""
          "\"printer01.fritz.box A 192.168.178.20\""
        ];
      };
    };
  };
}
