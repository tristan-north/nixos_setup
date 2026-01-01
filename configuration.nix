# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

# Make unstable packages available as `pkgs.unstable`
let
  unstable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz")
  { config = config.nixpkgs.config;};
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.kernelPackages = pkgs.linuxPackages_6_17;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Clean up the boot process so the login prompt looks nicer
  # This hides kernel logs on boot so tuigreet is the first thing you see
  boot.kernelParams = [ "quiet" "splash" ];

  zramSwap = {
    enable = true;
    memoryMax = 4 * 1024 * 1024 * 1024; # 4Gig
  };


  services.udev.extraRules = ''
    # Disable Touchscreen to stop phantom touches
    ACTION=="add|change", KERNEL=="event*", ATTRS{name}=="quicki2c-hid 27C6:012D", ENV{LIBINPUT_IGNORE_DEVICE}="1"
  '';

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;

  services.upower.enable = true; # Battery features, needed by quickshell

  # DNLA media serving
  services.minidlna.enable = true;
  services.minidlna.openFirewall = true;
  services.minidlna.settings = {
    friendly_name = "NixOS Media";
    media_dir = [ "V,/mnt/media-share" ];
    inotify = "yes";  # Auto update the library
    log_level = "error";
  };
  users.users.minidlna = {
    extraGroups = [ "users" ]; # so minidlna can access the files.
  };
  # For DNLA to access the Videos dir, since it has trouble
  # accessing from within my home dir.
  systemd.tmpfiles.rules = [
    "d /mnt/media-share 0755 tristan users -"
  ];
  systemd.mounts = [{
    what = "/home/tristan/Videos";
    where = "/mnt/media-share";
    type = "none";
    options = "bind";
    wantedBy = [ "multi-user.target" ];
    before = [ "minidlna.service" ];
    requiredBy = [ "minidlna.service" ];
  }];

  # Flatpak setup
  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome pkgs.xdg-desktop-portal-gtk ];
    config.common.default = ["gnome" "gtk"];
  };

  # System wide dark mode
  environment.variables.GTK_THEME = "Adwaita-dark";

  # Set your time zone.
  time.timeZone = "Australia/Sydney";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_AU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "au";
    variant = "";
    options = "caps:escape";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tristan = {
    isNormalUser = true;
    description = "Tristan";
    extraGroups = [ "networkmanager" "wheel" "kvm" "adbusers"];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  hardware.graphics.enable = true;

  # Enable flakes and the new command line tool
  nix.settings.experimental-features = ["nix-command"];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  wget
  btop
  alacritty
  gcc15
  wl-clipboard-rs # For nvim
  ripgrep # For nvim
  gnome-software # Flatpak installer
  vscode.fhs # FHS for compatibility with extensions with binaries.
  nautilus
  stow # GNU Stow for managing dotfiles
  unstable.quickshell
  brightnessctl # Monitor brightness controller
  wlsunset # Nightlight
  gnome-themes-extra   # provides Adwaita-dark
  # unstable.flutter
  lazygit
  yazi
  fzf
  starship
  swaylock
  swayidle
  unstable.opencode
  xwayland-satellite # Niri X11 support, for eg android emulator

  # Neovim stuff
  tree-sitter
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.git = {
    enable = true;
    config = {
      user.name = "Tristan North";
      user.email = "git@tristan-north.com";
    };
  };

  services.mullvad-vpn.package = pkgs.mullvad-vpn;
  services.mullvad-vpn.enable = true;

  programs.niri.enable = true;

  # Enable Greetd
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # Use tuigreet.
        # --time --cmd niri-session: Tells it to show time and run niri after login
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
        user = "greeter";
      };
    };
  };

  # Hint electron apps to use wayland
  environment.variables.ELECTRON_OZONE_PLATFORM_HINT = "wayland";

  fonts.packages = with pkgs; [
    roboto
    inter
    jetbrains-mono
    fira-code
    font-awesome # For waybar
    nerd-fonts.fira-code
  ];
  


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
