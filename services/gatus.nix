{ pkgs-unstable, config, lib, ... }:
let
  configFile = ./gatus-config.yml;
in
{
  options.ruben.gatus = {
    enable = lib.mkEnableOption "gatus health dashboard service";
  };

  config = lib.mkIf (config.ruben.gatus.enable)
    {
      /* gatus service user */
      users.users.gatus = {
        group = "gatus";
        isSystemUser = true;
      };
      users.groups.gatus = { };

      /* gatus service */
      systemd.services.gatus = {
        description = "Gatus - Automated service health dashboard";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        stopIfChanged = false;
        startLimitIntervalSec = 60;
        environment = {
          GATUS_CONFIG_PATH = configFile;
        };
        serviceConfig = {
          ExecStart = "${pkgs-unstable.gatus}/bin/gatus";
          Restart = "always";
          RestartSec = "10s";
          User = "gatus";
          Group = "gatus";
        };
      };

      /* gatus reverse proxy config */
      services.nginx = {
        virtualHosts = {
          "status.home.hoenle.xyz" = {
            forceSSL = true;
            useACMEHost = "home.hoenle.xyz";
            locations."/".proxyPass = "http://127.0.0.1:2020";
          };
        };
      };
    };
}
