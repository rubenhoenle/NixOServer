{ config, pkgs, ... }:
let
  domain = "home.hoenle.xyz";
  ovhApplicationKey = config.age.secrets.ovhApplicationKey.path;
  ovhApplicationSecret = config.age.secrets.ovhApplicationSecret.path;
  ovhConsumerKey = config.age.secrets.ovhConsumerKey.path;
in
{
  security.acme = {
    acceptTerms = true;
    defaults.email = "acme@hoenle.xyz";
    #defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory";
    certs."${domain}" = {
      dnsProvider = "ovh";
      domain = "${domain}";
      extraDomainNames = [ "*.${domain}" ];
      credentialsFile = "${pkgs.writeText "ovh-creds" ''
      OVH_APPLICATION_KEY_FILE=${ovhApplicationKey}
      OVH_APPLICATION_SECRET_FILE=${ovhApplicationSecret}
      OVH_CONSUMER_KEY_FILE=${ovhConsumerKey}
      OVH_ENDPOINT=ovh-eu
    ''}";
    };
  };

  users.users.nginx.extraGroups = [ "acme" ];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # paperless
    virtualHosts."paperless.${domain}" = {
      forceSSL = true;
      useACMEHost = "${domain}";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8085";
        proxyWebsockets = true; # needed if you need to use WebSocket
        extraConfig =
          # required when the target is also TLS server with multiple hosts
          "proxy_ssl_server_name on;" +
          # required when the server wants to use HTTP Authentication
          "proxy_pass_header Authorization;" +
          "client_max_body_size 200M;"
        ;
      };
    };

    # hedgedoc
    virtualHosts."pad.${domain}" = {
      forceSSL = true;
      useACMEHost = "${domain}";
      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
        proxyWebsockets = true; # needed if you need to use WebSocket
        extraConfig =
          # required when the target is also TLS server with multiple hosts
          "proxy_ssl_server_name on;" +
          # required when the server wants to use HTTP Authentication
          "proxy_pass_header Authorization;" +
          "client_max_body_size 200M;"
        ;
      };
    };

    # tandoor
    virtualHosts."recipes.${domain}" = {
      forceSSL = true;
      useACMEHost = "${domain}";
      locations."/" = {
        proxyPass = "http://127.0.0.1:7450";
        proxyWebsockets = true; # needed if you need to use WebSocket
        extraConfig =
          # required when the target is also TLS server with multiple hosts
          "proxy_ssl_server_name on;" +
          # required when the server wants to use HTTP Authentication
          "proxy_pass_header Authorization;"
        ;
      };
    };

    # homer
    virtualHosts."${domain}" = {
      forceSSL = true;
      useACMEHost = "${domain}";
      locations."/" = {
        proxyPass = "http://127.0.0.1:7451";
        proxyWebsockets = true; # needed if you need to use WebSocket
        extraConfig =
          # required when the target is also TLS server with multiple hosts
          "proxy_ssl_server_name on;" +
          # required when the server wants to use HTTP Authentication
          "proxy_pass_header Authorization;"
        ;
      };
    };

    # seafile
    virtualHosts."seafile.${domain}" = {
      forceSSL = true;
      useACMEHost = "${domain}";
      locations."/" = {
        proxyPass = "http://unix:/run/seahub/gunicorn.sock";
        extraConfig = ''
          proxy_set_header X-Forwarded-Proto https;
        '';
      };
      locations."/seafhttp" = {
        proxyPass = "http://127.0.0.1:8082";
        extraConfig = ''
          rewrite ^/seafhttp(.*)$ $1 break;
          client_max_body_size 0;
          proxy_connect_timeout  36000s;
          proxy_set_header X-Forwarded-Proto https;
          proxy_set_header Host $host:$server_port;
          proxy_read_timeout  36000s;
          proxy_send_timeout  36000s;
          send_timeout  36000s;
          proxy_http_version 1.1;
        '';
      };
    };

  };
}
