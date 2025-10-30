{
  config,
  pkgs,
  emacsPkg,
}:
let
  appName = "Emacs Client";

  # Use the emacsclient binary from the emacs package that is provided. This
  # means that emacPkg must be installed.
  binary = "${emacsPkg}/bin/emacsclient";

  # Building requires a few system tools to be in PATH.
  # Specifically osacompile for creating an EmacsClient.app from the launcher script.
  # Symlinking them in this way is better than just putting all of /usr/bin in there.
  buildSymlinks = pkgs.runCommand "macvim-build-symlinks" { } ''
    mkdir -p $out/bin
    ln -s /usr/bin/osacompile $out/bin
  '';

  ## Create a wrapper around the binary so that we can pass a flag.
  launcher = pkgs.writeText "emacsclient" ''
    on run
        do shell script "${binary} -c -n"
    end run
  '';

  infoPlist = pkgs.writeText "Info.plist" (
    pkgs.lib.generators.toPlist { } {
      CFBundleName = appName;
      CFBundleDisplayName = appName;
      CFBundleExecutable = "applet";
      CFBundleIconFile = "Emacs";
      CFBundleIdentifier = "org.gnu.${appName}";
      CFBundleInfoDictionaryVersion = "6.0";
      CFBundlePackageType = "APPL";
      CFBundleVersion = emacsPkg.version;
      CFBundleShortVersionString = emacsPkg.version;
      CFBundleURLTypes = [
        {
          CFBundleURLName = "org-protocol handler";
          CFBundleURLSchemes = "org-protocol";
        }
      ];
    }
  );

  icon = "${emacsPkg}/Applications/Emacs.app/Contents/Resources/Emacs.icns";
in

# This builds the EmacsClient.app from an apple script. Then installs the plist
# and emacs icons.
pkgs.runCommand "emacsclient-app"
  {
    # Add osacompile to list of build dependencies.
    nativeBuildInputs = [ buildSymlinks ];
  }
  ''
    mkdir -p $out/Applications
    osacompile -o "$out/Applications/${appName}.app" ${launcher}

    install -Dm644 ${infoPlist} "$out/Applications/${appName}.app/Contents/Info.plist"
    install -Dm755 ${binary} "$out/Applications/${appName}.app/Contents/MacOS/emacsclient"
    install -Dm644 ${icon} "$out/Applications/${appName}.app/Contents/Resources/Emacs.icns"
  ''
