# NixOS Server Configuration

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

#### Backup testing / restoring backups

``` bash
# only when testing backups
systemctl stop hedgedoc
sudo rm -r /var/lib/hedgedoc

# only when testing backup or restoring backup on a new machine
update-switch # hedgedoc will now create a new db etc.

# finally, let's restore the backup
systemctl stop hedgedoc
sudo restic-hedgedoc restore --target / latest && sudo mv /var/lib/hedgedoc/db-dumps/db-dump.sqlite3 /var/lib/hedgedoc/db.sqlite
systemctl start hedgedoc
```

