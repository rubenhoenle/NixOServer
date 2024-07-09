{ pkgs, lib, config, ... }:
{
  options.ruben.minecraft = {
    enable = lib.mkEnableOption "minecraft server";
  };

  config = lib.mkIf (config.ruben.minecraft-server.enable)
    {
      services.minecraft-server = {
        enable = true;
        eula = true;
        openFirewall = true;
        package = pkgs.minecraftServers.vanilla-1-19;
        declarative = true;
        serverProperties = {
          server-port = 25565;
          difficulty = 3;
          gamemode = 1;
          max-players = 5;
          motd = "NixOS Minecraft server!";
          white-list = false;
          enable-rcon = false;
        };
      };
    };
}
