{ config, pkgs, ... }:
{
  networking.firewall.allowedTCPPorts = [ 22 69 2222 ];
  networking.firewall.allowedUDPPorts = [ 22 69 2222 ];
}
