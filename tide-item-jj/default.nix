{
  lib,
  fetchFromGitHub,
  fishPlugins,
}:

fishPlugins.buildFishPlugin {
  pname = "tide-item-jj";
  version = "unstable-2026-08-19";

  src = fetchFromGitHub {
    owner = "lucasadelino";
    repo = "tide-item-jj";
    rev = "153be2b33a212ef633dcaf2f743308ea2e068309";
    hash = "sha256-pseflhnpPf1Rqx+CHetinfI3gCQHW/nISO+EHVXPmts=";
  };

  meta = {
    description = "Jujutsu item for the Tide Fish prompt";
    homepage = "https://github.com/lucasadelino/tide-item-jj";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
