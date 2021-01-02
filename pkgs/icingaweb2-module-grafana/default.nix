{ fetchFromGitHub
, lib
, stdenv
}:

with lib;

stdenv.mkDerivation rec {

  name = "icingaweb2-module-grafana";
  version = "1.3.6";

  src = fetchFromGitHub {
    owner = "Mikesch-mp";
    repo = name;
    rev = "v${version}";
    sha256 = "1zvfk9x831fssypf7hhay76ymvr277xz7g1z8ljmhdysiaqvg5r6";
  };

  installPhase = ''
    mkdir -p "$out"
    cp -r * "$out"
  '';

  meta = {
    description = "Grafana module for Icinga Web 2 (supports InfluxDB & Graphite)";
    homepage = "https://github.com/Mikesch-mp/icingaweb2-module-grafana";
    license = licenses.gpl2;
    platforms = platforms.all;
    maintainers = with maintainers; [ bebehei ];
  };
}
