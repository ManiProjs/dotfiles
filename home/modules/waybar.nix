{ config, lib, pkgs, ... }:

let
  cfg = config.mani.dotfiles.waybar;
in
{
  options.mani.dotfiles.waybar.enable =
    lib.mkEnableOption "Mani's Waybar configuration";

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.waybar
    ];

    xdg.configFile."waybar".source =
      ../../dotfiles/waybar;
  };
}
