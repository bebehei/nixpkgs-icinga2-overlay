{ bison
, boost
, cmake
, fetchFromGitHub
, flex
, libmysqlclient
, mariadb
, openssl
, postgresql
, stdenv
, systemd
, yajl
}:

stdenv.mkDerivation rec {
  name = "icinga2-${version}";
  version = "2.12.3";

  src = fetchFromGitHub {
    owner = "icinga";
    repo = "icinga2";
    rev = "v${version}";
    sha256 = "0pq6ixv7d9bqys8qjxqq0jki3zncj8jdfavkp7qw125iyfjq48xk";
  };

  patches = [
    ./noinstall-initrundir.patch
    # We want systemd support for the Watchdog.
    # Systemd unit installation fails and is not necessary,
    # we have to write our own unit anyways
    ./nosystemdunit.patch
    # see: https://github.com/Icinga/icinga2/pull/8581
    # intended to get fixed on 2.13
    ./shellimprov.patch
  ];

  cmakeFlags = [
    "-DICINGA2_PLUGINDIR=plugins"
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
    "-DCMAKE_INSTALL_LOCALSTATEDIR=${placeholder "out"}/var/"
    "-DICINGA2_CONFIGDIR=${placeholder "out"}/etc/icinga2"
    "-DICINGA2_CACHEDIR=${placeholder "out"}/var/cache/icinga2"
    "-DICINGA2_DATADIR=${placeholder "out"}/var/lib/icinga2"
    "-DICINGA2_LOGDIR=${placeholder "out"}/var/log/icinga2"
    "-DICINGA2_SPOOLDIR=${placeholder "out"}/var/spool/icinga2"
    "-DICINGA2_INITRUNDIR=/run/icinga2"
    "-DMYSQL_INCLUDE_DIR='${libmysqlclient.dev}/include/mariadb'"
    # Enable systemd Watchdog support
    "-DUSE_SYSTEMD=ON"
    "-DINSTALL_SYSTEMD_SERVICE_AND_INITSCRIPT=OFF"
    "-DSYSTEMD_INCLUDE_DIR=${systemd.dev}/include"
  ];

  buildInputs = [
    boost
    libmysqlclient
    mariadb
    openssl
    postgresql
    systemd
    yajl
  ];
  nativeBuildInputs = [
    bison
    cmake
    flex
  ];

  meta = with stdenv.lib; {
    description = "Open source monitoring system";
    homepage = http://www.icinga.org;
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ bebehei ];
  };
}
