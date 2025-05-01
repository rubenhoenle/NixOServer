{ config, lib, ... }: {
  options.ruben.nginx.enable = lib.mkEnableOption "nginx webserver";

  config = lib.mkIf (config.ruben.nginx.enable)
    {
      services.nginx = {
        enable = true;
        recommendedTlsSettings = true;

        virtualHosts."hoenle.xyz" = {
          forceSSL = true;
          enableACME = true;
          root = "/var/www/homepage";
        };
        virtualHosts."www.hoenle.xyz" = {
          forceSSL = true;
          enableACME = true;
          root = "/var/www/homepage";
        };
      };

      security.acme = {
        acceptTerms = true;
        defaults.email = "webmaster@hoenle.xyz";
      };

      users.users.www-data = {
        isNormalUser = true;
        home = "/home/www-data";
        description = "Nginx files user";
        extraGroups = [ "www-data" ];
        openssh.authorizedKeys.keys = [
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGz2voOKRU2i2BECmdXRw+1okyV+Kwm6PSN0ghaD8zuqAAAABHNzaDo="
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPsnp3qCYwCpb49UptuZ8csHzIZzZr0Buyl7uVW9udFdAAAABHNzaDo="

          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIN17O8nYCSqrUUboEl5fHFN5suqsAgDboPM/6ORrnqVaAAAABHNzaDo="
        ];
      };
      users.groups.www-data = { };

      systemd.tmpfiles.rules = [
        "d /var/www 0755 www-data www-data -"
        "d /var/www/homepage 0755 www-data www-data -"
      ];

      /* open ports in firewall */
      networking.firewall.allowedTCPPorts = [ 80 443 ];
    };
}

