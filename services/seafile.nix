{ config, pkgs, ... }:
{
  services.seafile = {
    enable = true;
    seafileSettings.fileserver = {
      host = "127.0.0.1";
      port = 8082;
    };
    adminEmail = "ruben@hoenle.xyz";
    initialAdminPassword = "ruben";
    ccnetSettings.General.SERVICE_URL = "https://seafile.home.hoenle.xyz";
    seahubExtraConf = ''
      SITE_NAME = 'seafile.home.hoenle.xyz'
      SITE_TITLE = 'Seafile'
      FILE_SERVER_ROOT = 'https://seafile.home.hoenle.xyz/seafhttp'
    '';
  };
}
