# NixOS Server Configuration

`nixos-rebuild switch --build-host root@mandalore --target-host root@mandalore --flake ".#mandalore"`

`nixos-rebuild switch --target-host root@scarif --flake ".#scarif"`

## Rebuilding
`sudo nixos-rebuild switch --flake .#<HOSTNAME>`

## Startup
`ssh root@<IP> -p 2222`

*Don't forget to specify root as username when connecting to the initrd ssh session!*

## Podman containers
To view the logs of the podman containers specified in the nix config, use the following command: 
``` bash
journalctl -u podman-<SERVICE_NAME>

# e.g. for tandoor app:
journalctl -u podman-tandoor-app

# e.g. for matrix-mqtt bridge:
journalctl -u podman-matrix-mqtt-bridge
```

## Services

`sudo -u tandoor_recipes bash`

### Hedgedoc service

``` bash
# testing the backup
systemctl start restic-backups-hedgedoc.service
systemctl stop hedgedoc.service
sudo rm -rf /var/lib/hedgedoc
update-switch
```

### Tandoor recipes service

``` bash
# testing the backup
systemctl start restic-backups-tandoor.service
systemctl stop tandoor-recipes.service
sudo rm -rf /var/lib/tandoor-recipes
update-switch
```

### Paperless service

``` bash
# testing the backup
systemctl start restic-backups-paperless.service
systemctl stop paperless-consumer.service paperless-scheduler.service paperless-task-queue.service paperless-web.service redis-paperless.service
sudo rm -rf /var/lib/paperless
update-switch
```


