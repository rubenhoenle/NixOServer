{ config, pkgs, lib, ... }:
let
  user = "filebrowser";
  dataDir = "/var/lib/filebrowser";
  settings = {
    port = 3000;
    baseURL = "";
    address = "";
    log = "stdout";
    database = "${dataDir}/filebrowser.db";
    root = "${dataDir}-files";
    "auth.method" = "json";
    username = "hoenle";
    # Generate password: 
    # nix-shell -p filebrowser
    # filebrowser hash <password>
    password = "$2a$10$aRddaU5/9OE.yZXTYnW/2.PlMa9Csjh83ako2JYtEeTY8GlUWNN5e";
  };

in
{
  options.ruben.filebrowser = {
    enable = lib.mkEnableOption "filebrowser service";
  };

  config = lib.mkIf (config.ruben.filebrowser.enable)
    {
      /* open the port in the firewall */
      networking.firewall.allowedTCPPorts = [ settings.port ];

      environment.etc."filebrowser/.filebrowser.json".text = builtins.toJSON settings;

      systemd.services.filebrowser = {
        description = "Filebrowser cloud file services";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        startLimitIntervalSec = 14400;
        startLimitBurst = 10;
        serviceConfig = {
          ExecStart = "${pkgs.filebrowser}/bin/filebrowser";
          DynamicUser = true;
          # We need this since the binary also requires `getent`.
          Environment = "PATH=/run/current-system/sw/bin";
          User = user;
          Group = user;
          ReadWritePaths = [ dataDir settings.root ];
          StateDirectory = [ "filebrowser" "filebrowser-files" ];
          Restart = "on-failure";
          RestartPreventExitStatus = 1;
          RestartSec = "5s";
        };
      };
    };
}
