{ pkgs, ... }:
let
  hddMountScript = import ../pkgs/hdd-mount.nix { inherit pkgs; };
  hddUnmountScript = import ../pkgs/hdd-unmount.nix { inherit pkgs; };
in
{
  users.users.ruben = {
    isNormalUser = true;
    description = "Ruben";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      curl
      btop
      podman-compose
      dnsutils
    ];
    uid = 1000;
  };
  users.groups.users.gid = 100;

  /* group which provides access to restic agenix secrets */
  users.groups.backup = { };

  users.users.root.packages = [ hddMountScript hddUnmountScript ];
}
