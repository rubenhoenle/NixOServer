{ pkgs, ... }:
{
  users.users.ruben = {
    isNormalUser = true;
    description = "Ruben";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      #vim
    ];
    uid = 1000;
  };

  users.groups.users.gid = 100;
}
