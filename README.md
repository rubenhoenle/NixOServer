[![run flake check](https://github.com/rubenhoenle/NixOServer/actions/workflows/build.yaml/badge.svg?branch=main&event=push)](https://github.com/rubenhoenle/NixOServer/actions/workflows/build.yaml)
[![update flake lock](https://github.com/rubenhoenle/NixOServer/actions/workflows/flake-update.yaml/badge.svg?branch=main)](https://github.com/rubenhoenle/NixOServer/actions/workflows/flake-update.yaml)

# NixOS Server Configuration

`nixos-rebuild switch --build-host root@mandalore --target-host root@mandalore --flake ".#mandalore"`

`nixos-rebuild switch --target-host root@scarif --flake ".#scarif"`

## Rebuilding

`sudo nixos-rebuild switch --flake .#<HOSTNAME>`

## Startup

`ssh root@<IP> -p 2222`

_Don't forget to specify root as username when connecting to the initrd ssh session!_

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
# testing the backup
systemctl start restic-backups-paperless.service
systemctl stop paperless-consumer.service paperless-scheduler.service paperless-task-queue.service paperless-web.service redis-paperless.service
sudo rm -rf /var/lib/paperless
update-switch
```

### Soft-serve service

```bash
# testing the backup
systemctl start restic-backups-soft-serve
systemctl stop soft-serve.service
sudo rm -rf /var/lib/soft-serve
update-switch
```

### Fileserver

```bash
# running the backup job
systemctl start restic-backups-fileserver.service

# restoring from backup
sudo -u fileserver /run/current-system/sw/bin/restic-fileserver restore --target / latest
```

## Troubleshooting

- In case of systemd temp files and directories not created properly when testing backups, run `sudo systemd-tmpfiles --create` on the server.
