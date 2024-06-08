{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.ruben.nginx;

  domain = "home.hoenle.xyz";
  ovhApplicationKey = config.age.secrets.ovhApplicationKey.path;
  ovhApplicationSecret = config.age.secrets.ovhApplicationSecret.path;
  ovhConsumerKey = config.age.secrets.ovhConsumerKey.path;
in
{
  options.ruben.nginx = {
    enable = mkEnableOption "nginx service";
  };

  config = mkIf (cfg.enable)
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

      /* add nginx service user to acme group to allow file access to certificates */
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

        # stashapp
        virtualHosts."stash.${domain}" = {
          forceSSL = true;
          useACMEHost = "${domain}";
          locations."/" = {
            proxyPass = "http://127.0.0.1:9999";
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

        # nextcoud
        virtualHosts."cloud.${domain}" = {
          forceSSL = true;
          useACMEHost = "${domain}";
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
      };
    };
}
