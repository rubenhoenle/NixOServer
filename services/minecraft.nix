{ pkgs, ... }:
{
  services.minecraft-server = {
    eula = true;
    openFirewall = true;
    package = pkgs.minecraftServers.vanilla-1-19;
    declarative = true;
    serverProperties = {
      server-port = 25565;
      difficulty = 3;
      gamemode = 0;
      max-players = 5;
      motd = "NixOS Minecraft server!";
      white-list = true;
      enable-rcon = false;
    };
    whitelist = {
      "Rubin0n" = "1b0f8f4e-7602-4858-b5a4-3c0eccc9ea32";
      "Gamer_Ruben" = "145e0dd2-0a6a-46be-9d61-0cfe6a84c233";
    };
  };
}
