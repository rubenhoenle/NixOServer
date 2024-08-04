{
  services.unbound = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      server = {
        interface = [
          "0.0.0.0@53"
          "::@53"
        ];
        access-control = [
          "127.0.0.0/8      allow" # allow ipv4 from localhost
          "192.168.178.0/24 allow" # allow ipv4 from local network
          "::1/128          allow" # allow ipv6 from localhost
          "::0/0            allow" # allow all ipv6
        ];
        local-data = [
          "\"home.hoenle.xyz A 192.168.178.5\""
          "\"recipes.home.hoenle.xyz A 192.168.178.5\""
          "\"paperless.home.hoenle.xyz A 192.168.178.5\""
          "\"status.home.hoenle.xyz A 192.168.178.5\""

          "\"mandalore       A 192.168.178.5\""
          "\"scarif       A 192.168.178.4\""

          "\"fritz.box       A 192.168.178.1\""
          "\"fritz.repeater  A 192.168.178.3\""

          "\"printer01           A 192.168.178.20\""
          "\"printer01.fritz.box A 192.168.178.20\""
        ];
      };
    };
  };
}
