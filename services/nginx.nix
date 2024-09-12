{ config, pkgs, lib, ... }:
{
  options.ruben.nginx = {
    enable = lib.mkEnableOption "nginx service";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "home.hoenle.xyz";
    };
  };

  config = lib.mkIf (config.ruben.nginx.enable)
    {
      security.acme =
        let
          ovhApplicationKey = config.age.secrets.ovhApplicationKey.path;
          ovhApplicationSecret = config.age.secrets.ovhApplicationSecret.path;
          ovhConsumerKey = config.age.secrets.ovhConsumerKey.path;
        in
        {
          acceptTerms = true;
          defaults.email = "acme@hoenle.xyz";
          #defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory";
          certs."${config.ruben.nginx.domain}" = {
            dnsProvider = "ovh";
            domain = "${config.ruben.nginx.domain}";
            extraDomainNames = [ "*.${config.ruben.nginx.domain}" ];
            credentialsFile = "${pkgs.writeText "ovh-creds" ''
            OVH_APPLICATION_KEY_FILE=${ovhApplicationKey}
            OVH_APPLICATION_SECRET_FILE=${ovhApplicationSecret}
            OVH_CONSUMER_KEY_FILE=${ovhConsumerKey}
            OVH_ENDPOINT=ovh-eu
          ''}";
          };
        };

      /* add nginx service user to acme group to allow file access to certificates */
      users.users.nginx.extraGroups = [ "acme" ];

      services.nginx = {
        enable = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;
      };

      /* open firewall ports */
      networking.firewall.allowedTCPPorts = [ 80 443 ];
    };
}
