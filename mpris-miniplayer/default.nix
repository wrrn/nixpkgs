# MPRIS MiniPlayer — a small GTK4/libadwaita remote control for whatever is
# playing on the session bus.
#
# Built from the release tag rather than a release asset: upstream ships a
# Flatpak bundle, an amd64 .deb and an x86_64 .rpm, all of which assume a
# distro filesystem. The source is plain Vala + Meson and compiles cleanly, so
# there is nothing to gain from unpacking a binary package here.
#
# Two things about upstream's meson.build worth knowing:
#   * `find_program('dbus-run-session')` and `find_program('python3')` are
#     called at the top level, so both are needed to *configure*, not just to
#     test — hence dbus and python3 in nativeBuildInputs even though the test
#     suite is mostly skipped.
#   * The `dbus` suite opens a private bus over a unix socket, which the build
#     sandbox will not allow; checkPhase runs everything else.
{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  vala,
  pkg-config,
  gettext,
  glib,
  desktop-file-utils,
  appstream,
  python3,
  dbus,
  wrapGAppsHook4,
  gtk4,
  libadwaita,
  gdk-pixbuf,
  libsoup_3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mpris-miniplayer";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "ChrisLauinger77";
    repo = "mpris-miniplayer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3y4B77uiRNBlmpPKOnv/GAuNg3DOxj12m+EG0ZMIUqc=";
  };

  nativeBuildInputs = [
    meson
    ninja
    vala
    pkg-config
    gettext
    glib # glib-compile-resources, glib-compile-schemas
    desktop-file-utils # desktop-file-validate, via gnome.post_install
    appstream
    python3 # tools/check-release.py, resolved at configure time
    dbus # dbus-run-session, likewise
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    libadwaita
    glib
    gdk-pixbuf
    libsoup_3
  ];

  doCheck = true;

  # The `dbus` suite needs to create a local socket for its private bus, which
  # the sandbox denies. Upstream documents this exact escape hatch in the
  # README for restricted environments.
  checkPhase = ''
    runHook preCheck

    meson test --no-suite dbus --print-errorlogs

    runHook postCheck
  '';

  # Meson installs the binary, desktop entry, metainfo, schemas and icons, but
  # the manpage is only wired up by the Debian packaging. `..` because this
  # runs from the Meson build directory.
  postInstall = ''
    install -Dm644 ../debian/mpris-miniplayer.1 -t $out/share/man/man1
  '';

  meta = {
    description = "Small GTK4/libadwaita mini player for MPRIS-compatible media players";
    longDescription = ''
      MPRIS MiniPlayer is a compact remote control for any Linux media player
      that exposes the MPRIS interface on the session D-Bus — Cider, VLC,
      Spotify, Strawberry, Rhythmbox, Elisa, Slipmat, browsers with media
      sessions, mpv with an MPRIS plugin, and others. It shows track metadata
      and album art, offers transport, seek and volume controls, an optional
      status indicator, and can sit in the background showing and hiding
      itself as players come and go.
    '';
    homepage = "https://github.com/ChrisLauinger77/mpris-miniplayer";
    changelog = "https://github.com/ChrisLauinger77/mpris-miniplayer/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    mainProgram = "mpris-miniplayer";
    platforms = lib.platforms.linux;
  };
})
