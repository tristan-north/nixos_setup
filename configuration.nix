# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.kernelPackages = pkgs.linuxPackages_6_17;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  zramSwap = {
    enable = true;
    memoryMax = 4 * 1024 * 1024 * 1024; # 4Gig
  };


  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

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
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tristan = {
    isNormalUser = true;
    description = "Tristan";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  #### tnorth additions

  # For running in vmware
  virtualisation.vmware.guest.enable = true;
  environment.sessionVariables = {
    WLR_RENDERER = "pixman";
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
    WLR_NO_HARDWARE_CURSORS = "1";

    LIBGL_ALWAYS_SOFTWARE = "1";
    # MESA_LOADER_DRIVER_OVERRIDE = "llvmpipe";
    # GALLIUM_DRIVER = "llvmpipe";

    # WLR_DRM_NO_ATOMIC = "1";
  };

  # Enable flakes and the new command line tool
  #nix.settings.experimental-features = ["nix-command" "flakes"];

  # Auto login to TTY, if end up changing to use a display manager
  # gdm/sddm/lightdm/greetd can probably remove this.
  services.getty.autologinUser = "tristan";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  wget
  kitty
  waybar
  rofi-wayland
  vscode.fhs # FHS for compatibility with extensions with binaries.
  brave
  firefox
  nautilus
  stow # GNU Stow for managing dotfiles
  obsidian
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

  hardware.graphics.enable = true;

  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;

  # Hint electron apps to use wayland
  environment.variables.ELECTRON_OZONE_PLATFORM_HINT = "wayland";

  fonts.packages = with pkgs; [
    roboto
    jetbrains-mono
    fira-code
    font-awesome # For waybar
    nerd-fonts.fira-code
  ];
  

  ####


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
