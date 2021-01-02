{ config, lib, pkgs, ... }:

# TODO:
#  - Write icinga2 command, which is a wrapper, but seeded with the correct variables

with lib;
let
  cfg = config.services.icinga2;
  environmentfile = pkgs.writeText "icinga-env" ''
    DAEMON=${lib.getBin pkgs.icinga2}/sbin/icinga2

    # FIXME: are these variables needed?
    ICINGA2_CONFIG_FILE=/etc/icinga2/icinga2.conf
    ICINGA2_RUN_DIR=/run
    ICINGA2_STATE_DIR=/var/lib/icinga2
    ICINGA2_INIT_RUN_DIR=$ICINGA2_RUN_DIR/icinga2
    ICINGA2_LOG_DIR=/var/log/icinga2
    ICINGA2_CACHE_DIR=/var/cache/icinga2
    ICINGA2_PID_FILE=/run/icinga2/icinga2.pid
    ICINGA2_ERROR_LOG=$ICINGA2_STATE_DIR/error.log
    ICINGA2_STARTUP_LOG=$ICINGA2_STATE_DIR/startup.log
    ICINGA2_LOG=$ICINGA2_LOG_DIR/icinga2.log
    ICINGA2_USER=${cfg.user}
    ICINGA2_GROUP=${cfg.group}
    ICINGA2_COMMAND_GROUP=${cfg.cmdgroup}
  '';

  prestartscript = pkgs.writeScript "icinga-prestart" ''
    #!${pkgs.bash}/bin/bash
    ${pkgs.icinga2}/lib/icinga2/prepare-dirs ${environmentfile}

    if ! [ -d /etc/icinga2 ]; then
      cp -r ${pkgs.icinga2}/etc/icinga2 /etc/icinga2
      chown -R ${cfg.user}:${cfg.group} /etc/icinga2
      chmod -R go-w /etc/icinga2
    fi
  '';
in
{
  ###### interface

  options = {

    services.icinga2 = {
      enable = mkEnableOption "icinga2";

      user = mkOption {
        type = types.str;
        default = "icinga";
        description = "User account under which icinga2 runs.";
      };
      group = mkOption {
        type = types.str;
        default = "icinga";
        description = "group under which icinga2 runs.";
      };
      cmdgroup = mkOption {
        type = types.str;
        default = "icingacmd";
        description = "Command group for icinga2";
      };
    };
  };


  ###### implementation

  config = mkIf cfg.enable {

    users.extraUsers.icinga2 = {
      name = cfg.user;
      description = "Icinga2 service user";
      group = cfg.group;
      extraGroups = [
        cfg.cmdgroup
      ];
    };
    users.groups."${cfg.group}" = {
      name = cfg.group;
    };
    users.groups.icingacmd = {
      name = cfg.cmdgroup;
    };

    systemd.services.icinga2 = {
      description = "icinga2 service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "forking";
        EnvironmentFile = environmentfile;
        ExecStart = "${pkgs.icinga2}/bin/icinga2 daemon -d -D LogDir=/var/log/icinga2 -D DataDir=/var/lib/icinga2 -D CacheDir=/var/cache/icinga2 -D SpoolDir=/var/spool/icinga2 -D ConfigDir=/etc/icinga2";
        ExecReload = "${pkgs.icinga2}/lib/icinga2/safe-reload ${environmentfile}";
        PIDFile = "/run/icinga2/icinga2.pid";
        RuntimeDirectory = "icinga2";
        User = "${cfg.user}";
        Group = "${cfg.group}";
      };

    };

    systemd.services.icinga2-setup = {
      description = "icinga2 Initial File Setup";
      wantedBy = [ "multi-user.target" "icinga2.service" ];
      before = [ "icinga2.service" ];
      serviceConfig = {
        Type = "oneshot";
        EnvironmentFile = environmentfile;
        ExecStart = prestartscript;
      };
      # We need glibc for `getent`
      path = [ pkgs.glibc ];
    };

  };
}
