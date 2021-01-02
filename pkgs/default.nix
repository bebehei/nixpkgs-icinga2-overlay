{ lib, pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {icinga2 = pkgs.callPackage ./icinga2/default.nix {};})
    (self: super: {icingaweb2-module-grafana = pkgs.callPackage ./icingaweb2-module-grafana/default.nix {};})
  ];
}
