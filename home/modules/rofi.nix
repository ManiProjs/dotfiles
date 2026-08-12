{ config, lib, pkgs, ... }:

let
  cfg = config.mani.dotfiles.rofi;
in
{
  options.mani.dotfiles.rofi.enable =
    lib.mkEnableOption "Mani's Rofi configuration";

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.rofi
    ];

    xdg.configFile."rofi".source =
      ../../dotfiles/rofi;
  };
}
