{ buildOpenRAEngine, fetchFromGitHub, extraPostFetch }:

let
  buildUpstreamOpenRAEngine = { version, rev, sha256 }: name: (buildOpenRAEngine {
    inherit version;
    description = "Open-source re-implementation of Westwood Studios' 2D Command and Conquer games";
    homepage = "https://www.openra.net/";
    mods = [ "cnc" "d2k" "ra" "ts" ];
    src = fetchFromGitHub {
      owner = "OpenRA";
      repo = "OpenRA" ;
      inherit rev sha256 extraPostFetch;
    };
  } name).overrideAttrs (origAttrs: {
    postInstall = ''
      ${origAttrs.postInstall}
      cp -r mods/ts $out/lib/openra/mods/
      cp mods/ts/icon.png $(mkdirp $out/share/pixmaps)/openra-ts.png
      ( cd $out/share/applications; sed -e 's/Dawn/Sun/g' -e 's/cnc/ts/g' openra-cnc.desktop > openra-ts.desktop )
    '';
  });

in {
  release = name: (buildUpstreamOpenRAEngine rec {
    version = "20190314";
    rev = "${name}-${version}";
    sha256 = "15pvn5cx3g0nzbrgpsfz8dngad5wkzp5dz25ydzn8bmxafiijvcr";
  } name);

  playtest = name: (buildUpstreamOpenRAEngine rec {
    version = "20190302";
    rev = "${name}-${version}";
    sha256 = "1vqvfk2p2lpk3m0d3rpvj34i8cmk3mfc7w4cn4llqd9zp4kk9pya";
  } name);

  bleed = buildUpstreamOpenRAEngine {
    version = "20210321";
    rev = "b8e64df4b158b079462192485c213648bf1b2758";
    sha256 = "tPsayjk0xbXbV/zHu01JHSQiFgGK3kUEwKBNFdzF1no=";
  };
}
