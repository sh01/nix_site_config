{pkgs, ...}:
let
  slib = (pkgs.callPackage ../../lib {});
  vars = (pkgs.callPackage ../../base/vars.nix {});
  dns = (import ../dns.nix) {};
in {
  imports = [
    ./boot.nix
  ];

  services = {
    xserver = {
      enable = true;
      displayManager = {
        startx.enable = true;
        sx.enable = true;
        sddm = {
          enable = true;
          enableHidpi = true;
        };
        #defaultSession = "xfce";
      };
      libinput.enable = true;

      #windowManager.awesome.enable = true;
      #desktopManager.plasma5.enable = true;
      # Broken 2016-04-24 16.03.581.e409886
      #exportConfiguration = true;
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

  # xsecurelock setup.
  programs."xss-lock" = {
      enable = true;
      extraOptions = [''-l''];
      lockerCommand = ''env XSECURELOCK_PASSWORD_PROMPT=time_hex XSECURELOCK_SHOW_DATETIME=1 XSECURELOCK_DATETIME_FORMAT='%%Y-%%m-%%d %%H:%%M:%%S' XSECURELOCK_SHOW_HOSTNAME=1 XSECURELOCK_SHOW_USERNAME=1 ${pkgs.xsecurelock}/bin/xsecurelock'';
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
    #loader.grub.enable = false;
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
  }; default ++ [openvpn prsw prsw_net sh_x sh_cbrowser stash]);

  security.sudo.extraConfig = ''
sh    ALL=(prsw,sh_cbrowser) NOPASSWD: ALL
'';
}
