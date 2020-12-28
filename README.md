# nixpkgs-icinga2-overlay
NixOS overlay to add support for icinga2 (intended to track WIP state until finally merged into nixpkgs)

Include via:

```
git clone https://github.com/bebehei/nixpkgs-icinga2-overlay.git
```

in you nix-configuration,
```

imports = [
	/<pathtoclone>/nixpkgs-icinga2-overlay
];

services.icinga2.enable = true;
```

This will currently produce state in the following folders

- `/etc/icinga2`
- `/var/cache/icinga2`
- `/var/lib/icinga2`
- `/var/log/icinga2`
- `/var/spool/icinga2`

# Goals

Run icinga2 as effortlessly as possible on a NixOS host.

Idk yet the full path to do this. Icinga2 isn't built with NixOS in mind. The software has a few assumptions in its code, countering the.

Possible goals and TODOs:

- Automatic setup for local IDO
- Automatic configuration with icingaweb2
- Full configuration in Nix-code (?)
  - I'm not sure about this yet. AFAIK, Icinga2 fails without an error message, whenever some paths are on readonly devices. If it's the config path, then this will be unfeasible.
  - Will this be beneficial?
- TODO: Make a wrapper, that `icinga2 feature <list|enable|disable|...>` works.
  - If done in config, this won't be necessary
- TODO: How to include the template library and the monitoring-plugins?
