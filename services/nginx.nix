{ config, pkgs, ... }:
{
  security.acme = {
    acceptTerms = true;
    defaults.email = "acme@hoenle.xyz";
    #preliminarySelfsigned = true;
    #defaults.server = "";
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."paperless.local" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8085";
        proxyWebsockets = true; # needed if you need to use WebSocket
        extraConfig =
          # required when the target is also TLS server with multiple hosts
          "proxy_ssl_server_name on;" +
          # required when the server wants to use HTTP Authentication
          "proxy_pass_header Authorization;"
        ;
      };
    };
  };
}
