{ pkgs, lib, config, ... }:
let
  key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDIh+ZKG3LQgCVpPP6ywWhz71Y6K0yhC3+u1KVCtY7wEGoJXueNdopcWO7aHCNfqIOhcsWS+fsqCTVRpzoMRsT+Tx6sk499xeFp2IWCXiEYmohQMGfGg5mVEw/YYDPvBZ4A6XeGd4Oehj3HTxjRgdZRRyWK3JNzZzWcaNgk6v8InmQx6VHtiFa0Qt9hdq66cUUMhqDxXGHPLsaVRdzQ6KoePGCzajwQk1fEi5XqcacAyfGJn7GQVO8nfRec6yFNB5pi585HoNZUqj9wPzUNxR6BYWSlYsF1AvjIjogNzLSegzI2NdUXrin8b+ygGwdLUTKYzMcDR5cXqUGmg1mf4UFRk5F5pmtF3LozLQPXuhmcHpZfEdCdlxR4luTDhhvPu3Z5ERhtVeOqNUY7d9FqH7WkV5I2qzri1UpiHkjJtIQVkWrjGKAFKB01jV9oBQhrWcPwpMayqqJKt/dsFR48a1GpU5DdYllh2RO50ICUlXWP+iVtmyicrlGW9LjW8jtbpUOFqjZntsg7di4jQSrmxs6REqwjpeKJMNGFNkBFzgef5wI+PV8iw/lSZT6Fmd7a+zgj67ffluCGPKPGXJrJNVZD+linfxLKfyWGUEE8kcJ4dt09zF+lxrdaM1UjFd0ATeB2sjSc+i9Z1zKp+HUzzCm4oK1pbwtVE1scSwcWhvpO8w==";
in
{
  options.ruben.phone-backup = {
    enable = lib.mkEnableOption "phone backup rsync endpoint";
  };

  config = lib.mkIf (config.ruben.phone-backup.enable)
    {
      users.users.phone-backup = {
        isNormalUser = true;
        createHome = true;
        home = "/home/phone-backup";
        extraGroups = [ "backup" ];
        /* only allow rsync connections and nothing else */
        openssh.authorizedKeys.keys = [
          ''command="${pkgs.rrsync}/bin/rrsync /home/phone-backup",restrict ${key}''
        ];
        uid = 1002;
      };

      /* backup service */
      services.restic.backups.phone-backup = {
        user = "phone-backup";
        initialize = true;
        passwordFile = config.age.secrets.resticPassword.path;
        repository = "s3:https://s3.eu-central-003.backblazeb2.com/nixos-server-restic-backup/services/phone-backup";
        environmentFile = config.age.secrets.backblazeB2ResticS3EnvironmentSecrets.path;
        paths = [
          "/home/phone-backup"
        ];
        pruneOpts = [
          "--keep-hourly 48"
          "--keep-daily 7"
          "--keep-weekly 4"
          "--keep-monthly 12"
          "--keep-yearly 3"
        ];
        extraOptions = [ "s3.region=eu-central-003" ];
        timerConfig = {
          OnCalendar = "hourly";
          Persistent = true;
        };
      };
    };
}
