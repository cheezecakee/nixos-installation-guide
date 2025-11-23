{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "temp";
  networking.networkmanager.enable = true;

  # Enable nix-command and flakes
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    warn-dirty = false;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    useXkbConfig = true; 
  };

  services.xserver.enable = true;

  services.xserver.xkb.layout = "us";
  services.xserver.xkb.options = "eurosign:e,caps:escape";

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  security.sudo.wheelNeedsPassword = false;

  users.users.default = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    initialPassword = null;
    mutableUser = true;
  };

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    neovim 
    git
  ];

  environment.etc."init.sh".source = ./scripts/init.sh;
  system.activationScripts.copyInitScript = {
    text = ''
      for u in $(ls /home); do
        if [ -d /home/$u ] && [ ! -f /home/$u/init.sh ]; then
          echo "Initializing init.sh for user: $u"
          cp /etc/init.sh /home/$u/init.sh
          chmod +x /home/$u/init.sh
          chown $u:$u /home/$u/init.sh
        fi
      done
    '';
  };

  system.stateVersion = "25.05";
}
