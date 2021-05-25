/*  The package defintion for an OpenRA engine.
    It shares code with `mod.nix` by what is defined in `common.nix`.
    Similar to `mod.nix` it is a generic package definition,
    in order to make it easy to define multiple variants of the OpenRA engine.
    For each mod provided by the engine, a wrapper script is created,
    matching the naming convention used by `mod.nix`.
    This package could be seen as providing a set of in-tree mods,
    while the `mod.nix` pacakges provide a single out-of-tree mod.
*/
{ lib, stdenv
, packageAttrs
, patchEngine
, wrapLaunchGame
, engine
# , dotnetbuildhelpers
}:

with lib;

stdenv.mkDerivation (recursiveUpdate packageAttrs rec {
  name = "${pname}-${version}";
  pname = "openra";
  # version = "${engine.name}-${engine.version}";
  # derivation version doesn't match dotnet-sdk version format constraints, so use the engine version
  # TODO fix this
  version = engine.version;
  engine_version = engine.version;

  src = engine.src;

  postPatch = patchEngine "." version;

  configurePhase = ''
    runHook preConfigure

    make version VERSION=${escapeShellArg engine.version}

    runHook postConfigure
  '';

  buildFlags = [ "all" "RUNTIME=mono6" ];

  checkTarget = "nunit test";

  installTargets = [
    "install"
    "install-linux-icons"
    "install-linux-desktop"
    "install-linux-appdata"
    "install-linux-mime"
    "install-man-page"
  ];

  # preConfigure = ''
  #   [ -z "''${dontPlacateNuget-}" ] && pkgs/build-support/dotnetbuildhelpers/placate-nuget.sh
  # '';

  postInstall = ''
    ${wrapLaunchGame ""}

    ${concatStrings (map (mod: ''
      makeWrapper $out/bin/openra $out/bin/openra-${mod} --add-flags Game.Mod=${mod}
    '') engine.mods)}
  '';

  meta = {
    inherit (engine) description homepage;
  };
})
