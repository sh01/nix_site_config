with (import <nixpkgs/lib/kernel.nix> {lib = null; version = null;});
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
    netStd = {
NF_CONNTRACK_IRC = no;
NF_NAT = yes;
NF_TABLES = yes;
NF_TABLES_INET = yes;
NFT_CT = yes;
NFT_HASH = yes;
NFT_COUNTER = yes;
NFT_LOG = yes;
NFT_LIMIT = yes;
NFT_MASQ = module;
NFT_REDIR = module;
NFT_NAT = yes;
NFT_REJECT = yes;
NFT_COMPAT = yes;

NF_TABLES_IPV4 = yes;
NF_TABLES_IPV6 = yes;
};

    base = {
ACPI_PROCESSOR = yes;
X86_ACPI_CPUFREQ = yes;
IDE = no;

# CVE-2017-7308 mitigation
# USER_NS = no;
# CVE-2017-1000405 mitigation
# TRANSPARENT_HUGEPAGE = no;
};

    blkStd = {
EXT2_FS = yes;
EXT3_FS = yes;
EXT4_FS = yes;
BTRFS_FS = yes;

DM_CRYPT = yes;
CRYPTO_XTS = yes;

FUSE_FS = yes;
CONFIGFS_FS = yes;
};

    termHwStd = {
KEYBOARD_ATKBD = yes;
};
    # It's typically fine to keep these as modules instead, which NixOS will do by default.
    termVideo = {
AGP = no;
I2C_ALGOBIT = yes;
DRM_KMS_HELPER = yes;
DRM = yes;
DRM_I915 = yes;

FRAMEBUFFER_CONSOLE = yes;
FRAMEBUFFER_CONSOLE_DETECT_PRIMARY = yes;
};
    # This doesn't currently mix well with the default Nix kernel config, since that one forces the conflicting "DRM_LOAD_EDID_FIRMWARE y".
    termHeadless = {
KEYBOARD_ATKBD = yes;
VT = no;
DRM = no;
};
  };

  kernelPatches = [
    #{ name = "CVE-2016-5195-fix"; patch = ./cve-2016-5195_v4.4.patch; }
  ];
}
