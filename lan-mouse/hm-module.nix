lan-mouse:
{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ lan-mouse.homeManagerModules.default ];

  options.programs.lan-mouse = {
    After = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "The targets that lan-mouse should run after in systemd";
      default = null;
    };
    Wants = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "The targets that lan-mouse wants to run in systemd";
      default = null;
    };
  };

  config = lib.mkIf config.programs.lan-mouse.enable (
    lib.mkMerge [
      (lib.mkIf (config.programs.lan-mouse.systemd && config.programs.lan-mouse.After != null) {
        systemd.user.services.lan-mouse.Unit.After = lib.mkForce config.programs.lan-mouse.After;
      })

      (lib.mkIf (config.programs.lan-mouse.systemd && config.programs.lan-mouse.Wants != null) {
        systemd.user.services.lan-mouse.Unit.Wants = lib.mkForce config.programs.lan-mouse.Wants;
      })
    ]
  );

}
