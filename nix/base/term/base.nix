{pkgs, ...}:
let
  slib = (pkgs.callPackage ../../lib {});
  vars = import ../../base/vars.nix;
  dns = (import ../dns.nix) {};
in {
  imports = [
    ./boot.nix
  ];

  services = {
    xserver = {
      enable = true;
      displayManager.sddm.enable = true;
      windowManager.awesome.enable = true;
      desktopManager.plasma5.enable = true;
      enableCtrlAltBackspace = true;
      # Broken 2016-04-24 16.03.581.e409886
      #exportConfiguration = true;
      synaptics = {
        #enable = true;
      };
      videoDrivers = ["intel"];
    };

    dnsmasq = {
      enable = true;
      extraConfig = ''
interface=lo
listen-address=10.231.1.1
except-interface=eth_wifi
except-interface=eth_lan
except-interface=tun_msvpn
server=/s/16.10.in-addr.arpa/5.5.5.3.2.5.8.1.d.9.d.f.ip6.arpa/fd9d:1852:3555::1
'';
    };
  };

  networking = {
    search = dns.conf.search;
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
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };

  ### User / Group config
  # Define paired user/group accounts.
  # Manually provided passwords are hashed empty strings.
  users = slib.mkUserGroups (with vars.userSpecs {
    u2g = {
      sh = ["sh_cbrowser"];
    };
  }; default ++ [openvpn sh_prsw sh_prsw_net sh_x sh_cbrowser]);

  security.sudo.extraConfig = ''
sh    ALL=(prsw,sh_cbrowser) NOPASSWD: ALL
'';
}
