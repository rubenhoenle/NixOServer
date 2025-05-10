{ pkgs, inputs, config, lib, ... }:
let
  commanderer = inputs.pixelknecht.packages."${pkgs.system}".commanderer;
in
{
  options.ruben.commanderer = {
    enable = lib.mkEnableOption "commanderer service";
  };

  config = lib.mkIf (config.ruben.commanderer.enable)
    {
      /* commanderer service user */
      users.users.commanderer = {
        group = "commanderer";
        isSystemUser = true;
      };
      users.groups.commanderer = { };

      /* commanderer service */
      systemd.services.commanderer = {
        description = "Commanderer service";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        stopIfChanged = false;
        startLimitIntervalSec = 60;
        environment = {
          COMMANDERER_LISTEN_HOST = "0.0.0.0";
        };
        serviceConfig = {
          ExecStart = "${commanderer}/bin/commanderer";
          Restart = "always";
          RestartSec = "10s";
          User = "commanderer";
          Group = "commanderer";
        };
      };

      /* open firewall ports */
      networking.firewall.allowedTCPPorts = [ 9000 ];
    };
}
