let
  ssh_pub = import ./ssh_pub.nix;
  ssho_gitannex = ''command="PATH=/run/current-system/sw/bin/ GIT_ANNEX_SHELL_READONLY=true git-annex-shell -c \"$SSH_ORIGINAL_COMMAND\"" '';
in {
  userSpecs = { u2g ? {}, keys ? {}}: rec {
    sh = ["sh" 1000 (["wheel" "nix-users" "audio" "video" "sh_x"] ++ (u2g.sh or [])) (keys.sh or [ssh_pub.sh_allison]) {}];
    sh_prsw = ["sh_prsw" 1001 (["audio" "video" "sh_x"] ++ (u2g.prsw or [])) (keys.sh_prsw or []) {}];
    sh_prsw_net = ["sh_prsw_net" 1005 ["audio" "video" "sh_x"] (keys.sh_prsw or []) {}];
    sh_x = ["sh_x" 1002 [] [] {}];
    sh_cbrowser = ["sh_cbrowser" 1003 ["sh_x"] (keys.sh_cbrowser or []) {}];
    
    ### Host-user remote sets
    sh_yalda = ["sh_yalda" 1536 [] [(ssho_gitannex + ssh_pub.yalda.sh)] {}];

    ### System users
    backup_client = ["backup-client" 2000 [] [ssh_pub.root_keiko] {}];
    openvpn = ["openvpn" 2001 [] [] {}];
    nix_mirror = ["nix_mirror" 2002 [] [ssh_pub.root_keiko] {home = "/var/cache/nix_mirror";}];
    bouncer = ["bouncer" 2003 [] [] {}];
    cc = ["cc" 2048 [] [] {}];
    dovecot-auth = ["dovecot-auth" 2050 [] [] {}];
    mail-sh = ["mail-sh" 2056 ["dspam"] [] {}];
    sh_i401 = ["sh_i401" 2056 [] [] {}];
    es_github = ["es_github" 4096 [] [] {}];

    default = [sh backup_client nix_mirror];
  };

  kernelOpts = {
    # We'd really want NFT_MASQ and NFT_REDIR as y, but that's impossible due to forward-y dependencies which are not supported by this version of the nix kernel conf infrastructure.
    netStd = ''
NF_CONNTRACK_IRC n
NF_NAT y
NF_TABLES y
NF_TABLES_INET y
NFT_META y
NFT_CT y
NFT_RBTREE y
NFT_HASH y
NFT_COUNTER y
NFT_LOG y
NFT_LIMIT y
NFT_MASQ m
NFT_REDIR m
NFT_NAT y
NFT_REJECT y
NFT_COMPAT y

NF_TABLES_IPV4 y
NF_TABLES_IPV6 y
'';
  
    base = ''
X86_INTEL_PSTATE n
X86_ACPI_CPUFREQ y
IDE n

# CVE-2017-7308 mitigation
USER_NS n
'';

    blkStd = ''
EXT2_FS y
EXT3_FS y
EXT4_FS y
BTRFS_FS y

DM_CRYPT y
CRYPTO_XTS y

FUSE_FS y
CONFIGFS_FS y
'';

    termHwStd = ''
KEYBOARD_ATKBD y
'';
    # It's typically fine to keep these as modules instead, which NixOS will do by default.
    termVideo = ''
AGP n
I2C_ALGOBIT y
DRM_KMS_HELPER y
DRM y
DRM_I915 y

FRAMEBUFFER_CONSOLE y
FRAMEBUFFER_CONSOLE_DETECT_PRIMARY y
'';
    # This doesn't currently mix well with the default Nix kernel config, since that one forces the conflicting "DRM_LOAD_EDID_FIRMWARE y".
    termHeadless = ''
KEYBOARD_ATKBD y
VT n
DRM n
'';
  };

  kernelPatches = [
    #{ name = "CVE-2016-5195-fix"; patch = ./cve-2016-5195_v4.4.patch; }
  ];
}
