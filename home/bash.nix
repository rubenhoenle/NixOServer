{
  programs.bash = {
    enable = true;
    shellAliases = {
      # shortcuts
      ll = "ls -lisa";
      s = "screenfetch";

      # nixos update commands
      update = "echo '+++ NixOS Rebuild TEST +++\nRunning: nixos-rebuild test' && sudo nixos-rebuild test --flake .#";
      update-switch = "echo '+++ NixOS Rebuild SWITCH +++\nRunning: nixos-rebuild switch' && sudo nixos-rebuild switch --flake .#";
      update-boot = "echo '+++ NixOS Rebuild BOOT +++\nRunning: nixos-rebuild boot' && sudo nixos-rebuild boot --flake .#";

      # other stuff
      ntfy = "curl -L ntfy.hoenle.xyz/test -d";
    };
  };
}
