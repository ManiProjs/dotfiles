{ config, lib, pkgs, ... }:

let
  cfg = config.mani.dotfiles.kitty;
in
{
  options.mani.dotfiles.kitty.enable =
    lib.mkEnableOption "Mani's Kitty configuration";

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.kitty
    ];

    xdg.configFile."kitty".source =
      ../../dotfiles/kitty;
  };
}
