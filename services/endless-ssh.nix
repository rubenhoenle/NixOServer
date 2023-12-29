{ config, pkgs, ... }:
{
  services.endlessh = {
    enable = true;
    port = 22;
    openFirewall = false;
  };
}
