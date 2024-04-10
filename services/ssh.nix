{ config, pkgs, ... }:
{
  /* Endless SSH honeypot */
  services.endlessh = {
    enable = true;
    port = 22;
    openFirewall = false;
  };

  /* actual OpenSSH daemon */
  services.openssh = {
    enable = true;
    ports = [ 69 ];
    openFirewall = false;
    settings.AllowUsers = [ "ruben" ];
    # require public key authentication for better security
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "no";
  };

  users.users."ruben".openssh.authorizedKeys.keys = [
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGz2voOKRU2i2BECmdXRw+1okyV+Kwm6PSN0ghaD8zuqAAAABHNzaDo= ruben"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPsnp3qCYwCpb49UptuZ8csHzIZzZr0Buyl7uVW9udFdAAAABHNzaDo= ruben"
  ];

  # run 'screenfetch' command on SSH logins
  programs.bash.interactiveShellInit = "screenfetch";
}
