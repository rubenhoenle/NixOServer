{ pkgs-unstable, config, lib, ... }:
with lib;
let
  cfg = config.ruben.gatus;
  configFile = ./gatus-config.yml;
in
{
  options.ruben.gatus = {
    enable = mkEnableOption "gatus health dashboard service";
  };

  config = mkIf (cfg.enable)
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
