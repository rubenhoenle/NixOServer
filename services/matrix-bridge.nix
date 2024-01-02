{ config, pkgs, lib, ... }:
with lib;
let
  configFile = config.age.secrets.matrixMqttBridgeConfig.path;
in
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
}
