[![run flake check](https://github.com/rubenhoenle/NixOServer/actions/workflows/build.yaml/badge.svg?branch=main&event=push)](https://github.com/rubenhoenle/NixOServer/actions/workflows/build.yaml)

# NixOS Server Configuration

## Rebuilding

`nixos-rebuild switch --build-host root@mandalore --target-host root@mandalore --flake ".#mandalore"`

## Startup

`ssh root@<IP> -p 2222`

_Don't forget to specify root as username when connecting to the initrd ssh session!_

## Backups

### Offsite backup

```bash
# start
systemctl start restic-backups-fullbackup

# view status
systemctl status restic-backups-fullbackup

# view snapshots
restic-fullbackup snapshots

# browse snapshots
restic-fullbackup ls latest /var/lib/

# restore
/run/current-system/sw/bin/restic-fullbackup restore --target / latest
```

### Local harddrive backup

```bash
# IMPORTANT: the mount/unmount pkgs are only available for the root user

# mount the HDD backup drive
hdd-mount

# starting the HDD backup
systemctl start restic-backups-hdd

# showing the status of the HDD backup
systemctl status restic-backups-hdd

# unmount the HDD backup drive
hdd-unmount

# showing the snapshots of the HDD backup
restic-hdd snapshots

# restoring the backup from the HDD
restic-hdd restore latest --target /
```

## Podman containers

To view the logs of the podman containers specified in the nix config, use the following command:

```bash
# show containers
sudo podman ps -a

# show logs for container
sudo podman logs -f <CONTAINER_ID>
```

## Services

### Paperless service

```bash
# export
/var/lib/paperless/data/paperless-manage document_exporter /home/ruben/paperless-export-001
```

### Git server

```bash
# create a repo on the server
sudo -u git bash -c "git init --bare ~/myproject.git"

# then you can use it via the following url
git@git.hoenle.xyz:myproject.git
```

## Troubleshooting

- In case of systemd temp files and directories not created properly when testing backups, run `sudo systemd-tmpfiles --create` on the server.

## SSH Tunnelling

```bash
# port forward localhost:3000 to mandalore:2020
ssh mandalore -L 3000:localhost:2020 -fN
```
