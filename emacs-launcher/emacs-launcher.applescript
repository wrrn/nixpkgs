-- Emacs launcher AppleScript application
--
-- Starts a fresh Emacs process on every launch instead of activating an
-- already-running one. LaunchServices activates a running app by bundle ID
-- rather than re-executing it, so the only way to get a new instance from a
-- Dock/Spotlight/Finder click is a separate launcher that calls `open -n`
-- and exits.
--
-- The Emacs.app path below is substituted at build time by Nix.

-- Launch without files (Spotlight, Dock, Finder, Leader Key, ...)
on run
  do shell script "/usr/bin/open -n -a '@emacsApp@'"
end run

-- Files dropped on the icon or opened via Finder "Open With". All files go to
-- one new instance.
on open theDropped
  set filePaths to ""
  repeat with oneDrop in theDropped
    set filePaths to filePaths & " " & quoted form of POSIX path of oneDrop
  end repeat
  do shell script "/usr/bin/open -n -a '@emacsApp@'" & filePaths
end open
