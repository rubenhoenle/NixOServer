{ pkgs, agenix, ... }:
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
      dnsutils
    ];
    uid = 1000;
  };
  users.groups.users.gid = 100;

  environment.systemPackages = with pkgs; [
    screenfetch
    agenix
    git
    vim
    tldr
  ];

  users.users.root.packages = [ hddMountScript hddUnmountScript ];
}
