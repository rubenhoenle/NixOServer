{ pkgs, config, lib, ... }:
let
  port = 7451;
  icons = {
    paperless = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/NX211/homer-icons/master/png/paperless-ng.png";
      sha256 = "19dnqpmypf1fb4a20xgr3x7wd6bcir4rclrpcjgls5m0dsm5d1gx";
    };
    nextcloud = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/NX211/homer-icons/master/png/nextcloud.png";
      sha256 = "1gqm8kldmbd60vigww3xyfy61zpn1w64v1rlk50167pk6184r444";
    };
    gatus = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/TwiN/gatus/11aeec45c9763c76719420b8e93bb7f669033839/.github/assets/logo.png";
      sha256 = "1y1maqm0w8jpi8c7w8amzpy7zvfw0ijxsl1x4nfd0hpaxpy8w74f";
    };
  };

  # generate a homer config yaml file
  # as yaml is just a superset of json, we can just use json for this 
  configFile = pkgs.writeText "homer-config.yml" (builtins.toJSON {
    title = "Dashboard";
    subtitle = "Hönle";
    logo = "logo.png";

    header = true;
    footer = false;

    services = [
      {
        name = "Tools";
        icon = "fas fa-wrench";
        items = [
          {
            name = "Gatus";
            logo = "assets/icons/gatus.png";
            subtitle = "Health dashboard";
            keywords = "Health dashboard";
            url = "https://status.home.hoenle.xyz";
            target = "_blank";
          }
          {
            name = "Paperless";
            logo = "assets/icons/paperless.png";
            subtitle = "Document management";
            keywords = "Document management";
            url = "https://paperless.home.hoenle.xyz";
            target = "_blank";
          }
          {
            name = "Nextcloud";
            logo = "assets/icons/nextcloud.png";
            subtitle = "Private cloud suite";
            keywords = "Private cloud suite";
            url = "https://cloud.hoenle.xyz";
            target = "_blank";
          }
        ];
      }
    ];
  });
in
{
  options.ruben.homer = {
    enable = lib.mkEnableOption "homer service dashboard";
  };

  config = lib.mkIf (config.ruben.homer.enable)
    {
      virtualisation.oci-containers.containers = {
        homer = {
          image = "docker.io/b4bz/homer:latest";
          autoStart = true;
          volumes = [
            "${configFile}:/www/assets/config.yml"
            "${icons.paperless}:/www/assets/icons/paperless.png"
            "${icons.nextcloud}:/www/assets/icons/nextcloud.png"
            "${icons.gatus}:/www/assets/icons/gatus.png"
          ];
          ports = [ "127.0.0.1:${toString port}:8080" ];
        };
      };

      /* reverse proxy configuration */
      services.nginx.virtualHosts."${config.ruben.nginx.domain}" = {
        forceSSL = true;
        useACMEHost = "${config.ruben.nginx.domain}";
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString port}";
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
