{ config, lib, ... }:

let
  cfg = config.mani.dotfiles;
in
{
  imports = [
    ./modules/hyprland.nix
    ./modules/kitty.nix
    ./modules/quickshell.nix
    ./modules/rofi.nix
    ./modules/waybar.nix
  ];

  options.mani.dotfiles.enable =
    lib.mkEnableOption "Mani's complete dotfiles setup";

  config = lib.mkIf cfg.enable {
    mani.dotfiles = {
      hyprland.enable = lib.mkDefault true;
      kitty.enable = lib.mkDefault true;
      quickshell.enable = lib.mkDefault true;
      rofi.enable = lib.mkDefault true;
      waybar.enable = lib.mkDefault true;
    };
  };
}
