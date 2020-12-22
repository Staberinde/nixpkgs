{ stdenv
, fetchFromGitHub
, autoreconfHook
, pkgconfig
, rofi-unwrapped
, glib
, cairo
, gobject-introspection
, libgtop
, wrapGAppsHook
}:

stdenv.mkDerivation rec {
  pname = "rofi-top";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "davatorium";
    repo = pname;
    rev = "9416addf91dd1bd25dfd5a8c5f1c7297c444408e";
    sha256 = "sha256-lNsmx1xirepITpUD30vpcs5slAQYQcvDW8FkA2K9JtU=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkgconfig
    gobject-introspection
    wrapGAppsHook
  ];

  buildInputs = [
    rofi-unwrapped
    glib
    libgtop
    cairo
  ];

  patches = [
    ./0001-Patch-plugindir-to-output.patch
  ];


  meta = with stdenv.lib; {
    description = "A plugin for rofi that emulates top behaviour.";
    homepage = "https://github.com/davatorium/rofi-top";
    license = licenses.mit;
    maintainers = with maintainers; [ Staberinde ];
    platforms = [ "x86_64-linux" "x86_64-darwin" ];
  };
}
