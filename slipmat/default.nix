# Slipmat — a native GNOME client for Apple Music, plus its daemon and its
# terminal client.
#
# **Built from the release tag, not from the release asset.** The only artefact
# on https://github.com/SoftARV/Slipmat/releases is `Slipmat.flatpak`: an
# x86_64 bundle that needs org.gnome.Platform/49 under it and carries a
# zypak-wrapped Chromium. Unpacking that into the store would mean shipping a
# Flatpak runtime we do not have and a sandbox shim we do not need, so this
# follows the upstream AUR PKGBUILD instead and compiles v0.11.1 from source.
# The one piece that is genuinely a binary — castLabs Electron — is fetched the
# same way the Flatpak manifest fetches it, see ./electron-castlabs.nix.
#
# Three binaries come out, matching the three AUR packages:
#   slipmatd  the engine: owns the Chromium sidecar, the queue and MPRIS
#   slipmat   the GNOME app, a client of the daemon
#   climat    the terminal client, the same
# The clients look for `slipmatd` *beside their own binary* (via current_exe),
# which the makeWrapper layout preserves: the wrapped real binaries and the
# wrappers all live in $out/bin.
{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  wrapGAppsHook4,
  makeWrapper,
  librsvg,
  gtk4,
  libadwaita,
  glib,
  libpulseaudio,
  callPackage,
  electron-castlabs ? callPackage ./electron-castlabs.nix { },
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "slipmat";
  version = "0.11.1";

  src = fetchFromGitHub {
    owner = "SoftARV";
    repo = "Slipmat";
    tag = "v${finalAttrs.version}";
    hash = "sha256-w5pr/EDl8pgSaoLzg7YAMzR1Z7w3MnfBy3ScTn2frg0=";
  };

  cargoLock.lockFile = "${finalAttrs.src}/Cargo.lock";

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
    makeWrapper
    librsvg # rsvg-convert, for the rasterised icon sizes
  ];

  buildInputs = [
    gtk4
    libadwaita
    glib
    librsvg
    libpulseaudio # climat's visualiser and the daemon's mixer read PulseAudio
  ];

  # The GTK app is wrapped by hand below, together with the sidecar variable.
  dontWrapGApps = true;

  postInstall = ''
    # The sidecar, laid out exactly where `electron_binary()` looks:
    #   <sidecar>/node_modules/electron/dist/electron
    # Only four files of JavaScript are needed at runtime — every npm
    # dependency in sidecar/package.json exists solely to download the Electron
    # binary, which we already have from the store.
    install -Dm644 -t $out/share/slipmat/sidecar \
      sidecar/package.json sidecar/main.js sidecar/preload.js sidecar/queue-identity.js
    mkdir -p $out/share/slipmat/sidecar/node_modules/electron
    ln -s ${electron-castlabs.dist} $out/share/slipmat/sidecar/node_modules/electron/dist

    for appid in dev.miguelrincon.Slipmat dev.miguelrincon.Climat; do
      install -Dm644 data/$appid.desktop -t $out/share/applications
      install -Dm644 data/icons/hicolor/scalable/apps/$appid.svg \
        -t $out/share/icons/hicolor/scalable/apps
      for sz in 16 32 48 64 128 256 512; do
        install -d $out/share/icons/hicolor/''${sz}x''${sz}/apps
        rsvg-convert -w $sz -h $sz data/icons/hicolor/scalable/apps/$appid.svg \
          -o $out/share/icons/hicolor/''${sz}x''${sz}/apps/$appid.png
      done
    done
    install -Dm644 data/icons/hicolor/symbolic/apps/dev.miguelrincon.Slipmat-symbolic.svg \
      -t $out/share/icons/hicolor/symbolic/apps

    # Optional: the daemon starts itself on the first client connection. The
    # unit is only for keeping playback alive with every window closed.
    substitute packaging/systemd/slipmatd.service \
      $out/share/systemd/user/slipmatd.service \
      --replace-fail /usr/bin/slipmatd $out/bin/slipmatd
  '';

  preInstall = ''
    mkdir -p $out/share/systemd/user
  '';

  # `locate()` would find the sidecar through XDG_DATA_DIRS on a NixOS profile
  # install, but not when the binary is run straight out of the store or from a
  # nix shell. Naming it removes the guess — and removes the failure mode the
  # upstream comments keep warning about, which is fresh Rust silently paired
  # with a stale sidecar found somewhere else on the path.
  postFixup = ''
    for bin in slipmat slipmatd climat; do
      wrapProgram $out/bin/$bin \
        "''${gappsWrapperArgs[@]}" \
        --set-default SLIPMAT_SIDECAR $out/share/slipmat/sidecar
    done
  '';

  passthru.electron = electron-castlabs;

  meta = {
    description = "Native GNOME client for Apple Music, with a daemon and a terminal client";
    longDescription = ''
      Slipmat plays an Apple Music subscription on Linux: a GTK4/libadwaita
      library browser and player, a `slipmatd` daemon that owns playback and
      exports MPRIS, and `climat`, a Winamp-shaped terminal client for the same
      engine. Playback happens in a hidden castLabs Electron window, because
      Apple Music audio is Widevine-encrypted; the CDM is fetched by Chromium's
      component updater on first run, so a network connection is required every
      time.
    '';
    homepage = "https://github.com/SoftARV/Slipmat";
    changelog = "https://github.com/SoftARV/Slipmat/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    mainProgram = "slipmat";
    # Widevine on Linux is x86_64 only, which is what the PKGBUILD says too.
    platforms = [ "x86_64-linux" ];
    broken = !stdenv.hostPlatform.isLinux;
  };
})
