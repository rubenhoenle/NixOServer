{ config, lib, ... }:
{
  /* Endless SSH honeypot */
  services.endlessh = {
    enable = true;
    port = 22;
    openFirewall = true;
  };

  /* actual OpenSSH daemon */
  services.openssh = {
    enable = true;
    ports = [ 41524 ];
    openFirewall = true;

    /* allow root login for remote deploy aka. rebuild-switch  */
    settings.AllowUsers = [ "ruben" "root" ]
      ++ lib.ifEnable config.ruben.phone-backup.enable [ "phone-backup" ]
      ++ lib.ifEnable config.ruben.fileserver.enable [ "fileserver" ]
      ++ lib.ifEnable config.ruben.gitserver.enable [ "git" ]
      ++ lib.ifEnable config.ruben.nginx.enable [ "www-data" ];
    settings.PermitRootLogin = "yes";

    /* require public key authentication for better security */
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  users.users."ruben".openssh.authorizedKeys.keys = [
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGz2voOKRU2i2BECmdXRw+1okyV+Kwm6PSN0ghaD8zuqAAAABHNzaDo= ruben"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPsnp3qCYwCpb49UptuZ8csHzIZzZr0Buyl7uVW9udFdAAAABHNzaDo= ruben"

    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIN17O8nYCSqrUUboEl5fHFN5suqsAgDboPM/6ORrnqVaAAAABHNzaDo="
  ];

  users.users."root".openssh.authorizedKeys.keys = [
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGz2voOKRU2i2BECmdXRw+1okyV+Kwm6PSN0ghaD8zuqAAAABHNzaDo="
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPsnp3qCYwCpb49UptuZ8csHzIZzZr0Buyl7uVW9udFdAAAABHNzaDo="

    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIN17O8nYCSqrUUboEl5fHFN5suqsAgDboPM/6ORrnqVaAAAABHNzaDo="
  ];

  # run 'screenfetch' command on SSH logins
  programs.bash.interactiveShellInit = "screenfetch";
}
