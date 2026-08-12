{ config, lib, pkgs, ... }:

let
  cfg = config.mani.dotfiles.quickshell;
in
{
  options.mani.dotfiles.quickshell.enable =
    lib.mkEnableOption "Mani's Quickshell configuration";

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.quickshell
    ];

    xdg.configFile."quickshell".source =
      ../../dotfiles/quickshell;
  };
}
