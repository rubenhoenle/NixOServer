{ pkgs, ... }:
{
  users.users.ruben = {
    isNormalUser = true;
    description = "Ruben";
    extraGroups = [ "networkmanager" "wheel" "backup" ];
    packages = with pkgs; [
      curl
      restic
      screenfetch
      btop
      podman-compose
      dnsutils
    ];
    uid = 1000;
  };
  users.groups.users.gid = 100;

  /* group which provides access to restic agenix secrets */
  users.groups.backup = { };
}
