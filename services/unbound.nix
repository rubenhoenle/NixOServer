{ config, pkgs, ... }:
{
  services.unbound = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      server = {
        interface = [ "0.0.0.0@53" "::0@53" ];
        access-control = [
          "127.0.0.0/8      allow"
          "::1/128          allow"
          "192.168.178.0/24 allow"
        ];
        local-data = [
          "\"home.hoenle.xyz A 192.168.178.5\""
          "\"pad.home.hoenle.xyz A 192.168.178.5\""
          "\"recipes.home.hoenle.xyz A 192.168.178.5\""
          "\"paperless.home.hoenle.xyz A 192.168.178.5\""
          "\"stash.home.hoenle.xyz A 192.168.178.5\""

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
