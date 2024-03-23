{ pkgs, ... }:
{
  users.users.ruben = {
    isNormalUser = true;
    description = "Ruben";
    extraGroups = [ "networkmanager" "wheel" "backup" ];
    packages = with pkgs; [
      #vim
    ];
    uid = 1000;
  };

  # group which provides access to restic agenix secrets 
  users.groups.backup = { };

  users.groups.users.gid = 100;
}
