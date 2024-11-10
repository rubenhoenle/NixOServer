{ pkgs, ... }: pkgs.writeShellApplication {
  name = "hdd-mount";
  text = ''
    mkdir -p /mnt/SAMSUNG
    mount LABEL=SAMSUNG /mnt/SAMSUNG
  '';
}
