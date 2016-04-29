{pkgs, ...}:
let
  slib = import ../../lib;
  vars = import ../../base/vars.nix;
in {
  imports = [
    ./boot.nix
  ];

  ### System profile packages
  environment.systemPackages = with (pkgs.callPackage ../../pkgs/pkgs/meta {}); [
    sys_terminal
  ];

  services.xserver = {
    enable = true;
    displayManager.kdm.enable = true;
    desktopManager.kde4.enable = true;
    enableCtrlAltBackspace = true;
    # Broken 2016-04-24 16.03.581.e409886
    #exportConfiguration = true;
    synaptics = {
      enable = true;
    };
    videoDrivers = ["intel"];
  };

  networking = {
    nameservers = [ "10.16.0.1" ];
    search = [ "sh.s ulwifi.s baughn-sh.s" ];
    usePredictableInterfaceNames = false;
    nat = {
      enable = true;
      internalInterfaces = ["ve-+"];
      externalInterface = "eth_lan";
    };
  };
  
  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    pulseaudio = {
      enable = true;
      support32Bit = true;
    };
  };
  
  sound.enable = true;

  boot = {
    kernelPackages = pkgs.linuxPackages_4_3;
    loader.grub.enable = false;
    enableContainers = true;
    postBootCommands = ''
LS=/run/current-system/sw/share/local
if [ -x $LS/setup_user_dirs] . $LS/setup_user_dirs
'';
    # DMA attack mitigation
    blacklistedKernelModules = ["firewire_ohci" "firewire_core" "firewire_sbp2"];
  };

  ### Services
  services.openssh.enable = true;

  ### User / Group config
  # Define paired user/group accounts.
  # Manually provided passwords are hashed empty strings.
  users = (slib.mkUserGroups (with vars.userSpecs {
    u2g = { sh = ["sh_cbrowser"] ;};
  }; default ++ [sh_prsw sh_x sh_cbrowser]));

  security.sudo.extraConfig = ''
sh    ALL=(prsw,sh_cbrowser) NOPASSWD: ALL
'';
}
