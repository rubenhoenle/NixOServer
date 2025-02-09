{ pkgs, inputs, config, lib, ... }:
let
  sangam-quiz = inputs.sangam-quiz.packages."${pkgs.system}".ssh;
  sangam-quiz-path = "/var/lib/sangam-quiz";
in
{
  options.ruben.sangam-quiz = {
    enable = lib.mkEnableOption "sangam quiz ssh service";
  };

  config = lib.mkIf (config.ruben.sangam-quiz.enable)
    {
      /* sangam-quiz service user */
      users.users.sangam-quiz = {
        group = "sangam-quiz";
        isSystemUser = true;
      };
      users.groups.sangam-quiz = { };

      /* create sangam-quiz directory */
      systemd.tmpfiles.settings."sangam-quiz" = {
        "${sangam-quiz-path}".d = {
          mode = "0770";
          user = "sangam-quiz";
          group = "sangam-quiz";
        };
      };

      /* sangam quiz service */
      systemd.services.sangam-quiz = {
        description = "Sangam Quiz - SSH Service";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        stopIfChanged = false;
        startLimitIntervalSec = 60;
        environment = {
          SSH_HOST = "0.0.0.0";
        };
        serviceConfig = {
          ExecStart = "${sangam-quiz}/bin/sangam-quiz-ssh";
          WorkingDirectory = "${sangam-quiz-path}";
          Restart = "always";
          RestartSec = "10s";
          User = "sangam-quiz";
          Group = "sangam-quiz";
        };
      };

      /* open firewall ports */
      networking.firewall =
        let
          port = 23235;
        in
        {
          allowedTCPPorts = [ port ];
          allowedUDPPorts = [ port ];
        };
    };
}
