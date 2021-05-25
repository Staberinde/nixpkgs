/*  The reusable code, and package attributes, between OpenRA engine packages (engine.nix)
    and out-of-tree mod packages (mod.nix).
*/
{ lib, makeSetupHook, curl, unzip, dos2unix, pkg-config, makeWrapper
, lua, mono6, dotnet-sdk, dotnetPackages, python
, libGL, freetype, openal, SDL2
, zenity, dotnetbuildhelpers
}:

with lib;

let
  path = makeBinPath ([ mono6 python ] ++ optional (zenity != null) zenity);
  rpath = makeLibraryPath [ lua freetype openal SDL2 ];
  mkdirp = makeSetupHook { } ./mkdirp.sh;

in {
  patchEngine = dir: version: ''
    sed -i \
      -e 's/^VERSION.*/VERSION = ${version}/g' \
      -e '/fetch-geoip-db/d' \
      -e '/GeoLite2-Country.mmdb.gz/d' \
      ${dir}/Makefile

  '';

  wrapLaunchGame = openraSuffix: ''
    # Setting TERM=xterm fixes an issue with terminfo in mono: System.Exception: Magic number is wrong: 542
    # https://github.com/mono/mono/issues/6752#issuecomment-365212655
    wrapProgram $out/lib/openra${openraSuffix}/launch-game.sh \
      --prefix PATH : "${path}" \
      --prefix LD_LIBRARY_PATH : "${rpath}" \
      --set TERM xterm

    makeWrapper $out/lib/openra${openraSuffix}/launch-game.sh $(mkdirp $out/bin)/openra${openraSuffix} \
      --run "cd $out/lib/openra${openraSuffix}"
  '';

  packageAttrs = {
    # TODO nuget is trying to getch packages so I think that this list is incomplete
    buildInputs = with dotnetPackages; [
      FuzzyLogicLibrary
      MaxMindDb
      MaxMindGeoIP2
      MonoNat
      NewtonsoftJson
      NUnit3
      NUnitConsole
      NUnit3TestAdapter
      OpenNAT
      RestSharp
      SharpFont
      SharpZipLib
      SmartIrc4net
      StyleCopAnalyzers
      StyleCopMSBuild
      StyleCopPlusMSBuild
      rix0rrr-BeaconLib
      DiscordRichPresence
      Pfim
      OpenRA-Freetype6
      OpenRA-Eluant
      OpenRA-FuzzyLogicLibrary
      OpenRA-SDL2-CS
      OpenRA-OpenAL-CS
      MicrosoftDotNetPlatformAbstractions
      MicrosoftExtensionsDependencyModel
      MicrosoftNETTestSdk
      MicrosoftNETFrameworkReferenceAssemblies
      MicrosoftWin32Registry
      SystemNetHttp
      SystemRuntimeLoader
    ] ++ [
      dotnet-sdk
      libGL
      dotnetbuildhelpers
    ];

    # TODO: Test if this is correct.
    nativeBuildInputs = [
      curl
      unzip
      dos2unix
      pkg-config
      makeWrapper
      mkdirp
      mono6
      python
      dotnetbuildhelpers
    ];

    makeFlags = [ "prefix=$(out)" ];

    doCheck = true;

    dontStrip = true;

    meta = {
      maintainers = with maintainers; [ fusion809 msteen rardiol ];
      license = licenses.gpl3;
      platforms = platforms.linux;
    };
  };
}
