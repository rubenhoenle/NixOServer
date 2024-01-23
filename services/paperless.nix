{ config, lib, ... }:
with lib;
let
  cfg = config.ruben.paperless;
  paperlessDir = "/home/ruben/services/paperless";
  passwordFile = config.age.secrets.paperlessPassword.path;
in
{
  options.ruben.paperless = {
    enable = mkEnableOption "paperless service";
  };

  config = mkIf (cfg.enable)
    {
      services.paperless = {
        enable = true;
        address = "127.0.0.1";
        port = 8085;
        passwordFile = passwordFile;
        user = "ruben";
        dataDir = "${paperlessDir}/data";
        mediaDir = "${paperlessDir}/media";
        consumptionDir = "${paperlessDir}/input";
        extraConfig = {
          PAPERLESS_OCR_LANGUAGE = "deu+eng";
          PAPERLESS_ADMIN_USER = "ruben";
          PAPERLESS_TASK_WORKERS = 2;
          PAPERLESS_THREADS_PER_WORKER = 2;
          PAPERLESS_WORKER_TIMEOUT = 3600;
        };
      };
    };
}

