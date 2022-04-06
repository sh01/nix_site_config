with (import <nixpkgs/lib/kernel.nix> {lib = null;});
let
  ssh_pub = import ./ssh_pub.nix;
  ssho_gitannex = ''command="PATH=/run/current-system/sw/bin/ GIT_ANNEX_SHELL_READONLY=true git-annex-shell -c \"$SSH_ORIGINAL_COMMAND\"" '';
in {
  userSpecs = { u2g ? {}, keys ? {}}:
  let
    sh_keys = keys.sh or [ssh_pub.sh_allison];
  in rec {
    sh = ["sh" 1000 (["wheel" "nix-users" "audio" "video" "sh_x" "stash" "pulse"] ++ (u2g.sh or [])) sh_keys {}];
    #root_sh = ["root_sh" 0 (["wheel" "root"]) sh_keys {home = "/root/sh";}];
    sh_prsw = ["prsw_sh" 1001 (["audio" "video" "sh_x" "stash" "pulse"] ++ (u2g.prsw or [])) (keys.sh_prsw or []) {home="/home/prsw/sh";}];
    sh_prsw_net = ["prsw_net_sh" 1005 ["audio" "video" "sh_x" "stash" "pulse"] (keys.sh_prsw or []) {home="/home/prsw_net/sh";}];
    sh_x = ["sh_x" 1002 [] [] {}];
    sh_cbrowser = ["browsers_sh" 1003 ["sh_x"] (keys.sh_cbrowser or []) {home="/home/browsers/sh";}];
    stash = ["stash" 1004 [] sh_keys {}];

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

    mon_0 = ["mon_0" 2080 [] [] {}];
    mon_1 = ["mon_1" 2081 [] [] {}];

    default = [sh backup_client nix_mirror];
    monitoring = [mon_0 mon_1];
  };

  iproute2 = {
    enable = true;
    rttablesExtraConfig = ''
      # local
      16 containers
      17 memespace
    '';
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
NFT_COMPAT = option yes;
BRIDGE = yes;

NF_TABLES_IPV4 = yes;
NF_TABLES_IPV6 = yes;
TUN = yes;

PTP_1588_CLOCK = yes;
E1000E = yes;
};

    base = {
ACPI_PROCESSOR = yes;
X86_ACPI_CPUFREQ = yes;
# CVE-2017-7308 mitigation
# USER_NS = no;
# CVE-2017-1000405 mitigation
# TRANSPARENT_HUGEPAGE = no;

# Work around options missing in newer kernels
JOYSTICK_IFORCE_USB = option no;
JOYSTICK_IFORCE_232 = option no;
BLK_WBT_SQ = option yes;
CFQ_GROUP_IOSCHED = option yes;
CIFS_ACL = option yes;
#DEBUG_STACKOVERFLOW = option yes;
#IOSCHED_CFQ = option yes;
LDM_PARTITION = option yes;
SECURITY_SELINUX_BOOTPARAM_VALUE = option no;

VMD = yes;
CRYPTO_AES_NI_INTEL = yes;
USB_XHCI_PCI = yes;
USB_XHCI_PCI_RENESAS = yes;

INET_MPTCP_DIAG = yes;
IDE = option no;

CRYPTO_DEFLATE = yes;
INTEL_MEI = yes;
INTEL_MEI_ME = yes;
I2C = yes;
I2C_I801 = yes;
I2C_SMBUS = yes;
X86_PKG_TEMP_THERMAL = yes;

CRYPTO_GHASH_CLMUL_NI_INTEL = option yes;
CONFIG_CRYPTO_AES_NI_INTEL = option yes;
};

    blkStd = {
EXT2_FS = yes;
EXT3_FS = yes;
EXT4_FS = yes;
BTRFS_FS = yes;

TRUSTED_KEYS = no;
ENCRYPTED_KEYS = yes;
DM_CRYPT = yes;
CRYPTO_ESSIV = yes;
CRYPTO_XTS = yes;

FUSE_FS = yes;
CONFIGFS_FS = yes;

BLK_DEV_NVME = yes;
NVME_CORE = yes;
NVME_HWMON = yes;
SATA_AHCI = yes;
};

termHwStd = {
KEYBOARD_ATKBD = yes;
USB4 = yes;
USB_HID = yes;
SOUND = yes;
SND = yes;
SND_HDA_INTEL = yes;
SND_TIMER = yes;
};
    # It's typically fine to keep these as modules instead, which NixOS will do by default.
    termVideo = {
AGP = no;
I2C_ALGOBIT = yes;
DRM = yes;
DRM_SCHED = option yes;
DRM_KMS_HELPER = option yes;
DRM_TTM = option yes;
DRM_TTM_HELPER = option yes;
DRM_I915 = module;
AMD_IOMMU_V2 = yes;
DRM_AMDGPU = module;

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
