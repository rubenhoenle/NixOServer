{ pkgs, ... }:
{
  users.users.bk_nc_backup = {
    name = "bk_nc_backup";
    group = "bk_nc_backup";
    description = "BK Nextcloud backup service user";
    isSystemUser = true;
    createHome = true;
    home = "/home/bk_nc_backup";
    #extraGroups = [ "backup" ];
  };
  users.groups.bk_nc_backup = { };

  systemd.tmpfiles.settings."bk_nc_backup" = {
    "/var/lib/bk_nc_backup".d = {
      mode = "0770";
      user = "bk_nc_backup";
      group = "bk_nc_backup";
    };
    "/var/lib/bk_nc_backup/Briefkasten".d = {
      mode = "0770";
      user = "bk_nc_backup";
      group = "bk_nc_backup";
    };
  };

  systemd.services.bk-nc-backup = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "bk_nc_backup";
      Group = "bk_nc_backup";
      ExecStart = "${pkgs.nextcloud-client}/bin/nextcloudcmd -h -n --path /Briefkasten /var/lib/bk_nc_backup/Briefkasten https://cloud.shw-bergkapelle.de";
    };
  };
}
