{
  lib,
  pkgs,
  emacsPkg,
}:
let
  appName = "Emacs Client";
  version = emacsPkg.version;

  emacsclientBin = "${emacsPkg}/bin/emacsclient";

  # Nix store paths don't contain single quotes, so no shell-escaping is needed.
  # We build a minimal PATH that includes the emacs bin dir so emacsclient can
  # find its helpers, plus the standard macOS locations for `open`.
  emacsBinPath = lib.concatStringsSep ":" [
    "${emacsPkg}/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
  ];

  # Substitute build-time paths into the AppleScript template.
  applescript = pkgs.replaceVars ./emacs-client.applescript {
    inherit emacsclientBin emacsBinPath;
  };

  buildSymlinks = pkgs.runCommand "emacsclient-build-symlinks" { } ''
    mkdir -p $out/bin
    ln -s /usr/bin/osacompile $out/bin
    ln -s /usr/bin/plutil $out/bin
  '';

  icon = "${emacsPkg}/Applications/Emacs.app/Contents/Resources/Emacs.icns";

  currentYear = "2025";

  # Our additions / overrides on top of whatever osacompile writes. Each
  # top-level key here will be -replace'd into the bundle's Info.plist, so
  # osacompile-provided keys we don't override (CFBundleExecutable, the
  # AppleScript applet runtime keys, NS*UsageDescription defaults, etc.)
  # are preserved.
  plistOverlay = pkgs.writeText "emacsclient-overlay.plist" (
    lib.generators.toPlist { } {
      CFBundleIdentifier = "org.gnu.EmacsClient";
      CFBundleName = appName;
      CFBundleDisplayName = appName;
      CFBundleVersion = version;
      CFBundleShortVersionString = version;
      CFBundleGetInfoString = "${appName} ${version}";
      LSApplicationCategoryType = "public.app-category.productivity";
      NSHumanReadableCopyright = "Copyright © 1989-${currentYear} Free Software Foundation, Inc.";

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

      # org-protocol:// URL handler (for org-capture, org-roam, etc.)
      CFBundleURLTypes = [
        {
          CFBundleURLName = "Org Protocol";
          CFBundleURLSchemes = [ "org-protocol" ];
        }
      ];
    }
  );

  # Top-level keys to copy from plistOverlay onto the osacompile plist.
  # Must match the attribute names in plistOverlay above.
  overlayKeys = [
    "CFBundleIdentifier"
    "CFBundleName"
    "CFBundleDisplayName"
    "CFBundleVersion"
    "CFBundleShortVersionString"
    "CFBundleGetInfoString"
    "LSApplicationCategoryType"
    "NSHumanReadableCopyright"
    "CFBundleIconFile"
    "CFBundleDocumentTypes"
    "CFBundleURLTypes"
  ];
in
pkgs.runCommand "emacsclient-app"
  {
    nativeBuildInputs = [ buildSymlinks ];
    meta = {
      description = "Emacs Client macOS application bundle";
      platforms = lib.platforms.darwin;
    };
  }
  ''
    # osacompile refuses to write into a path that already exists, and on some
    # macOS versions it can't create app bundles directly inside a Nix sandbox
    # output path. Build into a temp dir, then move into $out.
    workDir="$(mktemp -d)"
    osacompile -o "$workDir/${appName}.app" ${applescript}

    mkdir -p "$out/Applications"
    mv "$workDir/${appName}.app" "$out/Applications/${appName}.app"

    contentsDir="$out/Applications/${appName}.app/Contents"
    resourcesDir="$contentsDir/Resources"

    # Install the Emacs icon. Remove Assets.car and CFBundleIconName so macOS
    # uses applet.icns rather than the droplet icon embedded in the asset catalog.
    cp ${icon} "$resourcesDir/applet.icns"
    rm -f "$resourcesDir/droplet.icns" "$resourcesDir/droplet.rsrc" "$resourcesDir/Assets.car"

    # Overlay our declarative additions onto osacompile's Info.plist.
    # For each key, extract its XML representation from the overlay and
    # -replace it on the target plist (creating it if absent, replacing
    # if present). osacompile-provided keys we don't touch are preserved.
    plist="$contentsDir/Info.plist"
    for key in ${lib.concatStringsSep " " overlayKeys}; do
      value_xml="$(plutil -extract "$key" xml1 -o - ${plistOverlay})"
      plutil -replace "$key" -xml "$value_xml" "$plist"
    done

    # Remove CFBundleIconName so macOS doesn't ignore CFBundleIconFile in favour
    # of the droplet icon that was embedded in Assets.car by osacompile.
    plutil -remove CFBundleIconName "$plist" 2>/dev/null || true
  ''
