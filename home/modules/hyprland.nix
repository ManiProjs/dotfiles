{ config, lib, pkgs, ... }:

let
  cfg = config.mani.dotfiles.hyprland;
in
{
  options.mani.dotfiles.hyprland.enable =
    lib.mkEnableOption "Mani's Hyprland configuration";

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.hyprland
      pkgs.hyprpaper
      pkgs.hyprlock
    ];

    xdg.configFile."hypr".source =
      ../../dotfiles/hypr;
  };
}
