# castLabs Electron — Electron with Widevine wired in.
#
# Slipmat plays Apple Music, which is DRM'd: the audio only decodes inside a
# Widevine CDM, and upstream Electron ships no CDM at all. castLabs maintain a
# fork ("+wvcus" = Widevine CDM Update Service, US) whose only job is to carry
# the component updater that fetches the CDM on first run. It is not on the npm
# registry — `sidecar/.npmrc` sets `allow-git=root` precisely so npm will take
# it from a GitHub release — so there is nothing for nixpkgs' `electron` to
# stand in for here. Substituting plain `electron` builds fine and plays
# nothing.
#
# This mirrors pkgs/development/tools/electron/binary/generic.nix: unzip the
# release, point the interpreter and rpath at the store. The CDM itself is
# *not* vendored; Chromium's component updater downloads it into the user's
# profile at first run, which is both why the Flatpak asks for `--share=network`
# unconditionally and why nothing proprietary lands in /nix/store.
{
  lib,
  stdenv,
  fetchurl,
  unzip,
  makeWrapper,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-atk,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  gtk4,
  libGL,
  libdrm,
  libgbm,
  libnotify,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbfile,
  libxrandr,
  libpulseaudio,
  libsecret,
  libxkbcommon,
  libxshmfence,
  nspr,
  nss,
  pango,
  pciutils,
  pipewire,
  speechd-minimal,
  systemd,
  vulkan-loader,
}:

let
  version = "43.0.0+wvcus";

  electronLibPath = lib.makeLibraryPath [
    alsa-lib
    at-spi2-atk
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    gtk4
    libGL
    libdrm
    libgbm
    libnotify
    libpulseaudio
    libsecret
    libxkbcommon
    libxshmfence
    nspr
    nss
    pango
    pciutils
    pipewire
    speechd-minimal
    stdenv.cc.cc
    systemd
    vulkan-loader
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbfile
    libxrandr
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "electron-castlabs";
  inherit version;

  src = fetchurl {
    # The literal release asset the Flatpak manifest pins, same hash.
    url = "https://github.com/castlabs/electron-releases/releases/download/v43.0.0%2Bwvcus/electron-v43.0.0+wvcus-linux-x64.zip";
    hash = "sha256-U3gvRLiohwPtVNoWAsVMCvmYzgdoOfcZ7+HIULBbrM8=";
  };

  nativeBuildInputs = [
    unzip
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gtk3
    gtk4
  ];

  dontUnpack = true;
  dontBuild = true;
  dontWrapGApps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/electron
    unzip -q -d $out/libexec/electron $src
    chmod u-x $out/libexec/electron/*.so*

    # The SUID sandbox helper cannot be setuid root in the store, and Chromium
    # refuses to start when it finds one that is not ("is owned by root and has
    # mode 4755"). Removing it sends Chromium down the unprivileged user
    # namespace sandbox instead, which is what NixOS has. This is the job zypak
    # does inside the Flatpak.
    rm -f $out/libexec/electron/chrome-sandbox

    runHook postInstall
  '';

  preFixup = ''
    makeWrapper "$out/libexec/electron/electron" $out/bin/electron \
      "''${gappsWrapperArgs[@]}"
  '';

  postFixup = ''
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${electronLibPath}:$out/libexec/electron" \
      $out/libexec/electron/electron \
      $out/libexec/electron/chrome_crashpad_handler

    rm "$out/libexec/electron/libvulkan.so.1"
    ln -s -t "$out/libexec/electron" "${lib.getLib vulkan-loader}/lib/libvulkan.so.1"

    patchelf \
      --set-rpath "${
        lib.makeLibraryPath [
          libGL
          pciutils
          vulkan-loader
        ]
      }" \
      $out/libexec/electron/lib*GL*
  '';

  # Where Slipmat's `electron_binary()` expects to find `dist/electron`.
  passthru.dist = finalAttrs.finalPackage + "/libexec/electron";

  meta = {
    description = "Electron fork from castLabs with Widevine CDM support";
    homepage = "https://github.com/castlabs/electron-releases";
    license = lib.licenses.mit;
    mainProgram = "electron";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };
})
