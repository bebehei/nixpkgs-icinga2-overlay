{ lib, pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {icinga2 = pkgs.callPackage ./icinga2/default.nix {};})
  ];
}
