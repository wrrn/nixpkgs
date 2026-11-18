# An "Emacs.app" that starts a new Emacs process on every launch.
#
# Pass the Emacs you want launched as `emacsPkg`. Consumers that wrap Emacs
# (e.g. home-manager's programs.emacs.finalPackage) should override this so
# new instances get the wrapper's packages and environment:
#
#   emacs-plus-launcher.override { emacsPkg = config.programs.emacs.finalPackage; }
#
# The bundle uses its own CFBundleIdentifier on purpose. Sharing org.gnu.Emacs
# would make LaunchServices treat a click as "activate the running Emacs",
# which is exactly the behaviour this package exists to avoid. The Emacs
# windows themselves still belong to org.gnu.Emacs.
{
  lib,
  pkgs,
  emacsPkg,
}:
let
  appName = "Emacs";
  # emacsWithPackages has no .version; getVersion parses it from the name.
  version = lib.getVersion emacsPkg;

  emacsApp = "${emacsPkg}/Applications/Emacs.app";

  applescript = pkgs.replaceVars ./emacs-launcher.applescript {
    inherit emacsApp;
  };

  buildSymlinks = pkgs.runCommand "emacs-launcher-build-symlinks" { } ''
    mkdir -p $out/bin
    ln -s /usr/bin/osacompile $out/bin
    ln -s /usr/bin/plutil $out/bin
    ln -s /usr/bin/codesign $out/bin
  '';

  icon = "${emacsApp}/Contents/Resources/Emacs.icns";

  # Keys -replace'd onto the Info.plist that osacompile writes. Keys we don't
  # set (CFBundleExecutable, applet runtime keys, ...) are left alone.
  plistOverlay = lib.generators.toPlist { escape = true; } {
    CFBundleIdentifier = "org.gnu.EmacsLauncher";
    CFBundleName = appName;
    CFBundleDisplayName = appName;
    CFBundleVersion = version;
    CFBundleShortVersionString = version;
    CFBundleGetInfoString = "${appName} ${version} (new-instance launcher)";
    LSApplicationCategoryType = "public.app-category.productivity";

    # Icon (osacompile defaults to "droplet"; we ship Emacs.icns as applet.icns)
    CFBundleIconFile = "applet";

    # File associations (drag-and-drop / Finder "Open With")
    CFBundleDocumentTypes = [
      {
        CFBundleTypeRole = "Editor";
        CFBundleTypeName = "Text Document";
        LSItemContentTypes = [
          "public.text"
          "public.plain-text"
          "public.source-code"
          "public.script"
          "public.shell-script"
          "public.data"
        ];
      }
    ];
  };

  overlayFile = pkgs.writeText "emacs-launcher-overlay.plist" plistOverlay;

  overlayKeys = [
    "CFBundleIdentifier"
    "CFBundleName"
    "CFBundleDisplayName"
    "CFBundleVersion"
    "CFBundleShortVersionString"
    "CFBundleGetInfoString"
    "LSApplicationCategoryType"
    "CFBundleIconFile"
    "CFBundleDocumentTypes"
  ];
in
pkgs.runCommand "emacs-launcher-app"
  {
    inherit version;
    nativeBuildInputs = [ buildSymlinks ];
    passthru = { inherit emacsPkg; };
    meta = {
      description = "Emacs.app that starts a new Emacs instance on every launch";
      platforms = lib.platforms.darwin;
    };
  }
  ''
    # osacompile can't always create bundles directly inside a sandbox output
    # path, so build in a temp dir and move into $out.
    workDir="$(mktemp -d)"
    osacompile -o "$workDir/${appName}.app" ${applescript}

    mkdir -p "$out/Applications"
    mv "$workDir/${appName}.app" "$out/Applications/${appName}.app"

    contentsDir="$out/Applications/${appName}.app/Contents"
    resourcesDir="$contentsDir/Resources"

    # Use the Emacs icon. Drop Assets.car so macOS doesn't prefer the droplet
    # icon embedded in the asset catalog.
    cp ${icon} "$resourcesDir/applet.icns"
    rm -f "$resourcesDir/droplet.icns" "$resourcesDir/droplet.rsrc" "$resourcesDir/Assets.car"

    plist="$contentsDir/Info.plist"
    for key in ${lib.concatStringsSep " " overlayKeys}; do
      value_xml="$(plutil -extract "$key" xml1 -o - ${overlayFile})"
      plutil -replace "$key" -xml "$value_xml" "$plist"
    done
    plutil -remove CFBundleIconName "$plist" 2>/dev/null || true

    # Editing Info.plist invalidates osacompile's ad-hoc signature; re-sign.
    codesign --force --sign - "$out/Applications/${appName}.app"
  ''
