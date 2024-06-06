{ config, lib, ... }:
with lib;
let
  cfg = config.ruben.matrixbridge;

  configFile = config.age.secrets.matrixMqttBridgeConfig.path;
in
{
  options.ruben.matrixbridge = {
    enable = mkEnableOption "matrixbridge service";
  };

  config = mkIf (cfg.enable)
    {
      virtualisation.oci-containers.containers = {
        matrix-mqtt-bridge = {
          image = "ghcr.io/rubenhoenle/matrix-mqtt-bridge:latest";
          autoStart = true;
          volumes = [
            "${configFile}:/config.ini"
          ];
        };
      };
    };
}
