{ pkgs, ... }: pkgs.writeShellApplication {
  name = "hdd-unmount";
  text = ''
    umount LABEL=SAMSUNG
  '';
}
