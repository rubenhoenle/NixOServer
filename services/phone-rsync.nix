{ pkgs, lib, config, ... }:
let
  key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDIh+ZKG3LQgCVpPP6ywWhz71Y6K0yhC3+u1KVCtY7wEGoJXueNdopcWO7aHCNfqIOhcsWS+fsqCTVRpzoMRsT+Tx6sk499xeFp2IWCXiEYmohQMGfGg5mVEw/YYDPvBZ4A6XeGd4Oehj3HTxjRgdZRRyWK3JNzZzWcaNgk6v8InmQx6VHtiFa0Qt9hdq66cUUMhqDxXGHPLsaVRdzQ6KoePGCzajwQk1fEi5XqcacAyfGJn7GQVO8nfRec6yFNB5pi585HoNZUqj9wPzUNxR6BYWSlYsF1AvjIjogNzLSegzI2NdUXrin8b+ygGwdLUTKYzMcDR5cXqUGmg1mf4UFRk5F5pmtF3LozLQPXuhmcHpZfEdCdlxR4luTDhhvPu3Z5ERhtVeOqNUY7d9FqH7WkV5I2qzri1UpiHkjJtIQVkWrjGKAFKB01jV9oBQhrWcPwpMayqqJKt/dsFR48a1GpU5DdYllh2RO50ICUlXWP+iVtmyicrlGW9LjW8jtbpUOFqjZntsg7di4jQSrmxs6REqwjpeKJMNGFNkBFzgef5wI+PV8iw/lSZT6Fmd7a+zgj67ffluCGPKPGXJrJNVZD+linfxLKfyWGUEE8kcJ4dt09zF+lxrdaM1UjFd0ATeB2sjSc+i9Z1zKp+HUzzCm4oK1pbwtVE1scSwcWhvpO8w==";
in
{
  options.ruben.phone-backup = {
    enable = lib.mkEnableOption "phone backup rsync endpoint";
    path = lib.mkOption {
      type = lib.types.str;
      default = "/home/phone-backup";
    };
  };

  config = lib.mkIf (config.ruben.phone-backup.enable)
    {
      users.users.phone-backup = {
        isNormalUser = true;
        createHome = true;
        home = config.ruben.phone-backup.path;
        extraGroups = [ "backup" ];
        /* only allow rsync connections and nothing else */
        openssh.authorizedKeys.keys = [
          ''command="${pkgs.rrsync}/bin/rrsync ${config.ruben.phone-backup.path}",restrict ${key}''
        ];
        uid = 1002;
      };
    };
}
