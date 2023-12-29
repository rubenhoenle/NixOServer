# NixOS Server Configuration

## TODOs
- Paperless
- Tandoor
- Reverse Proxy
- Git config
- Restic Backup Service
- Nix File Formatter

## Rebuilding

`sudo nixos-rebuild switch -I nixos-config=$(pwd)/configuration.nix`

## Startup
`ssh root@<IP> -p 2222`

*Don't forget to specify root as username when connecting to the initrd ssh session!*

