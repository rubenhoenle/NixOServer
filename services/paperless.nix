{ config, lib, pkgs, ... }:
let
  passwordFile = config.age.secrets.paperlessPassword.path;
  cfg = config.ruben.paperless;
in
{
  options.ruben.paperless = {
    enable = lib.mkEnableOption "paperless service";
    path = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/paperless";
    };
    database-path = lib.mkOption {
      type = lib.types.str;
      default = "${cfg.path}/data/db.sqlite3";
    };
    backup-path = lib.mkOption {
      type = lib.types.str;
      default = "/home/paperless";
    };
    backupPrepareCommandDatabase = lib.mkOption {
      type = lib.types.str;
      default = "${pkgs.sqlite}/bin/sqlite3 ${cfg.database-path} \".backup '${cfg.backup-path}/paperless-db-dump.sqlite3'\"";
    };
    backupPrepareCommandExport = lib.mkOption {
      type = lib.types.str;
      default = "${pkgs.coreutils}/bin/mkdir -p ${cfg.backup-path}/export && ${cfg.path}/data/paperless-manage document_exporter ${cfg.backup-path}/export --compare-checksums --delete";
    };
  };

  config = lib.mkIf (cfg.enable)
    {
      /* paperless service user */
      users.users.paperless = {
        name = "paperless";
        group = "paperless";
        description = "Paperless service user";
        home = lib.mkForce cfg.backup-path;
        createHome = true;
        isSystemUser = true;
        uid = lib.mkForce 987;
      };
      users.groups.paperless.gid = lib.mkForce 985;

      /* paperless service */
      services.paperless = {
        enable = true;
        address = "127.0.0.1";
        port = 8085;
        passwordFile = passwordFile;
        user = "paperless";
        dataDir = "${cfg.path}/data";
        mediaDir = "${cfg.path}/media";
        consumptionDir = "${cfg.path}/input";
        # whether the paperless consumption dir is accessible to all users
        consumptionDirIsPublic = false;
        settings = {
          PAPERLESS_OCR_LANGUAGE = "deu+eng";
          PAPERLESS_ADMIN_USER = "ruben";
          PAPERLESS_TASK_WORKERS = 2;
          PAPERLESS_THREADS_PER_WORKER = 2;
          PAPERLESS_WORKER_TIMEOUT = 3600;
          PAPERLESS_FORCE_SCRIPT_NAME = "/paperless";
        };
      };
    };
}

