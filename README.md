# NixOS Server Configuration

## TODOs
- Paperless
- Tandoor
- Reverse Proxy
- Git config
- Nix File Formatter
- Wake on LAN

## Rebuilding

`sudo nixos-rebuild switch -I nixos-config=$(pwd)/configuration.nix`

## Startup
`ssh root@<IP> -p 2222`

*Don't forget to specify root as username when connecting to the initrd ssh session!*

