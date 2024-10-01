{ lib, ...}:
with (import <nixpkgs/lib/kernel.nix> {lib = null;});
let
  inherit (lib) mkForce;
  ssh_pub = import ./ssh_pub.nix;
  ssho_gitannex = ''command="PATH=/run/current-system/sw/bin/ GIT_ANNEX_SHELL_READONLY=true git-annex-shell -c \"$SSH_ORIGINAL_COMMAND\"" '';
in {
  userSpecs = { u2g ? {}, keys ? {}}:
  let
    sh_keys = keys.sh or [ssh_pub.sh_allison];
    ratheka_keys = keys.ratheka or [ssh_pub.gungnir.ratheka];
    ilzo_keys = keys.rtanen or [ssh_pub.euphorbia.rtanen];
    sophia_keys = keys.sophia or [ssh_pub.sophia_wot];
  in rec {
    sh = ["sh" 1000 (["wheel" "nix-users" "audio" "video" "sh_x" "stash" "pulse-access" "game_pad" "input_game"] ++ (u2g.sh or [])) sh_keys {}];
    sophia = ["sophia" 1006 (["nix-users" "audio" "video" "stash" "pulse-access" "game_pad" "input_game"] ++ (u2g.sh or [])) sophia_keys {}];
    ilzo = ["ilzo" 1007 ["nix-users" "audio" "stash" "pulse-access"] ilzo_keys {}];
    ratheka = ["ratheka" 1008 ["audio" "video" "stash" "pulse-access"] ratheka_keys {}];
    #root_sh = ["root_sh" 0 (["wheel" "root"]) sh_keys {home = "/root/sh";}];
    prsw = ["prsw" 1001 (["audio" "video" "sh_x" "stash" "pulse-access" "input_game"] ++ (u2g.prsw or [])) (keys.sh_prsw or []) {}];
    prsw_net = ["prsw_net" 1005 ["audio" "video" "sh_x" "stash" "pulse-access" "input_game"] (keys.sh_prsw or []) {}];
    sh_x = ["sh_x" 1002 [] [] {}];
    sh_cbrowser = ["browsers_sh" 1003 ["sh_x"] (keys.sh_cbrowser or []) {home="/home/browsers/sh";}];
    stash = ["stash" 1004 [] (sh_keys ++ [ssh_pub.root_keiko]) {}];

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

  kernelOpts = rec {
    # We'd really want NFT_MASQ and NFT_REDIR as y, but that's impossible due to forward-y dependencies which are not supported by this version of the nix kernel conf infrastructure.
    netStd = {
BRIDGE = yes;

NF_CONNTRACK = yes;
NF_CONNTRACK_IRC = no;
NF_NAT = yes;
NF_TABLES = yes;
NF_TABLES_INET = yes;
NFT_CT = yes;
NFT_HASH = yes;
NFT_COUNTER = option yes;
NFT_LOG = yes;
NFT_LIMIT = yes;
NFT_MASQ = module;
NFT_REDIR = module;
NFT_NAT = yes;
NFT_REJECT = yes;
#NFT_COMPAT = option yes;

NF_CT_NETLINK = yes;
NF_DEFRAG_IPV4 = yes;
NF_REJECT_IPV4 = yes;
NF_TABLES_IPV4 = yes;
NF_TABLES_IPV6 = yes;

NETFILTER_NETLINK = yes;
NETFILTER_NETLINK_LOG = yes;
NETFILTER_XTABLES = yes;
NETFILTER_XT_MARK = yes;
NETFILTER_XT_CONNMARK = yes;
NETFILTER_XT_TARGET_CONNSECMARK = yes;
NETFILTER_XT_MATCH_CONNMARK = yes;
NETFILTER_XT_MATCH_CONNTRACK = yes;
NETFILTER_XT_MATCH_POLICY = yes;
NETFILTER_XT_MATCH_STATE = yes;

IP_DCCP = option module;
IP_DCCP_CCID3 = option no;
IP_NF_IPTABLES = yes;
IP_NF_FILTER = yes;
IP_NF_TARGET_REJECT = yes;
IP_NF_MANGLE = yes;
IP_NF_RAW = yes;
IP_NF_SECURITY = yes;
IP_NF_ARPTABLES = yes;

NF_DEFRAG_IPV6 = yes;
NF_REJECT_IPV6 = yes;
IP6_NF_IPTABLES = yes;
IP6_NF_MATCH_IPV6HEADER = yes;
IP6_NF_FILTER = yes;
IP6_NF_TARGET_REJECT = yes;
IP6_NF_MANGLE = yes;
IP6_NF_RAW = yes;
IP6_NF_SECURITY = yes;

TUN = yes;

PACKET = yes;
NET_KEY = yes;
NET_KEY_MIGRATE = yes;
INET_DIAG = yes;
INET_TCP_DIAG = yes;
IP_FIB_TRIE_STATS = yes;

XFRM_ALGO = yes;
XFRM_USER = yes;
XFRM_MIGRATE = yes;
#INET6_XFRM_TUNNEL = option yes;

IPV6 = yes;
INET6_AH = yes;

IPV6_SIT = yes;
IPV6_MULTIPLE_TABLES = yes;
IPV6_FOU_TUNNEL = mkForce yes;

TCP_CONG_CUBIC = yes;
DEFAULT_CUBIC = yes;

PTP_1588_CLOCK = yes;
E100 = yes;
E1000 = yes;
E1000E = yes;
R8169 = yes;

MII = yes;
};

    x86Std = {
      X86_ACPI_CPUFREQ = yes;
      X86_PKG_TEMP_THERMAL = yes;
      X86_MSR = yes;
      X86_CPUID = yes;
      X86_AMD_PSTATE = mkForce no;
};
    base = {
SND_SOC_INTEL_SOUNDWIRE_SOF_MACH = mkForce (option module); # workaround

MODULE_SRCVERSION_ALL = yes;

UNWINDER_ORC = yes;
UNWINDER_FRAME_POINTER = no;

ACPI_PROCESSOR = yes;
# CVE-2017-7308 mitigation
# USER_NS = no;
# CVE-2017-1000405 mitigation
# TRANSPARENT_HUGEPAGE = no;
RTC_HCTOSYS = yes;
RTC_DRV_CMOS = yes;
MEMORY_FAILURE = yes;

# Work around options missing in newer kernels
NFSD_V3 = mkForce (option yes);
DEBUG_INFO = mkForce (option yes);
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

INET_MPTCP_DIAG = mkForce yes;
IDE = option no;

CRYPTO_DEFLATE = yes;
INTEL_MEI = yes;
INTEL_MEI_ME = yes;
I2C = yes;
I2C_I801 = yes;
I2C_SMBUS = yes;

CRYPTO_GHASH_CLMUL_NI_INTEL = option yes;
CONFIG_CRYPTO_AES_NI_INTEL = option yes;

BLK_DEV_LOOP = yes;
BLK_DEV_RAM = yes;

BINFMT_MISC = yes;
PACKET = yes;

# In-kernel contexts are unnecessarily privileged for this;
# we use userspace implementations, instead.
WIREGUARD = mkForce no;
};

    devFreq = {
ACPI_PROCESSOR = yes;
ACPI_THERMAL = yes;
CPU_FREQ_STAT = yes;
CPU_FREQ_GOV_POWERSAVE = yes;
CPU_FREQ_GOV_USERSPACE = yes;
CPU_FREQ_GOV_ONDEMAND = yes;
CPU_FREQ_GOV_CONSERVATIVE = yes;

DEVFREQ_GOV_SIMPLE_ONDEMAND = yes;
DEVFREQ_GOV_PERFORMANCE = yes;
DEVFREQ_GOV_POWERSAVE = yes;
DEVFREQ_GOV_USERSPACE = yes;
};
    blkStd = {
BFQ_GROUP_IOSCHED = yes;
MQ_IOSCHED_KYBER = yes;
MQ_IOSCHED_DEADLINE = yes;

ASYNC_TX_DMA = yes;

SCSI_MOD = yes;
RAID_ATTRS = yes;
SCSI = yes;
BLK_DEV_SD = yes;
BLK_DEV_SR = yes;
CHR_DEV_SG = yes;
SCSI_SPI_ATTRS = yes;
SCSI_SAS_ATTRS = yes;
SCSI_MPT2SAS = yes;

EXT2_FS = yes;
EXT2_FS_XATTR = yes;
EXT3_FS = yes;
EXT4_FS = yes;
BTRFS_FS = yes;

#ISO9660_FS = yes;

TRUSTED_KEYS = no;
ENCRYPTED_KEYS = yes;
#TRUSTED_KEYS = no;
DM_CRYPT = yes;
CRYPTO_ESSIV = yes;
CRYPTO_XTS = yes;

FUSE_FS = yes;
CUSE = yes;
CONFIGFS_FS = yes;

FS_ENCRYPTION = yes;
FS_MBCACHE = yes;
FSCACHE_STATS = yes;

ACPI_NFIT = yes;
LIBNVDIMM = yes;
BLK_DEV_PMEM = yes;
DAX = yes;
BLK_DEV_MD = yes;
MD_AUTODETECT = yes;
MD_LINEAR = yes;
MD_RAID0 = yes;
MD_RAID1 = yes;
MD_RAID10 = yes;
MD_RAID456 = yes;
BLK_DEV_DM = yes;
DM_MIRROR = yes;
DM_RAID = yes;
DM_ZERO = yes;
DM_UEVENT = yes;
DM_SWITCH = yes;
FUSION_LOGGING = yes;

BLK_DEV_NVME = yes;
NVME_CORE = yes;
NVME_HWMON = yes;
ATA = yes;
SATA_AHCI = yes;
};

    usbStd = {
HID = yes;
HID_GENERIC = yes;
USB_HID = yes;
USB_COMMON = yes;
USB = yes;
USB_MON = yes;
USB_XHCI_HCD = yes;
USB_XHCI_PCI = yes;
USB_EHCI_HCD = yes;
USB_EHCI_PCI = yes;
USB_STORAGE = yes;
};
    
    blkMultipath = {
DM_MULTIPATH = yes;
DM_MULTIPATH_QL = yes;
DM_MULTIPATH_ST = yes;
DM_MULTIPATH_HST = yes;
DM_MULTIPATH_IOA = yes;
SCSI_DH = yes;
SCSI_DH_ALUA = module;
SCSI_DH_RDAC = module;
SCSI_DH_EMC = module;
};
    
    hwAudio = {
SND_SOC = yes;
SND_SOC_SOF_HDA = yes;
SND_SOC_INTEL_SKL_HDA_DSP_GENERIC_MACH = yes;
SND_HDA_I915 = yes;
SND_HDA_GENERIC = yes;
SND_HDA_CODEC_HDMI = yes;
SND_SOC_INTEL_SKYLAKE_HDAUDIO_CODEC = yes;
SND_SOC_SOF_HDA_AUDIO_CODEC = yes;
SND_HDA_INTEL_HDMI_SILENT_STREAM = option yes;
SND_SOC_SOF_TOPLEVEL = yes;
SND_SOC_SOF_INTEL_TOPLEVEL = yes;
SND_SOC_SOF_PCI = mkForce yes;
SND_SOC_SOF_ACPI = mkForce yes;
SND_SOC_SOF_HDA_LINK = yes;
SND_SOC_INTEL_SKYLAKE = yes;
SND_SOC_INTEL_SKL = yes;
SND_SOC_INTEL_KBL = yes;
SND_SOC_INTEL_CML_H = yes;
SND_SOC_INTEL_CML_LP = yes;
SND_SOC_SOF_ALDERLAKE = yes;
SND_SOC_SOF_COFFEELAKE = mkForce yes;
SND_SOC_SPDIF = option module;
SND_SOC_SIMPLE_AMPLIFIER = yes;
SND_SOC_SIMPLE_MUX = yes;
SND_SOC_AC97_CODEC = yes;
SND_HDA_RECONFIG = yes;
SND_HDA_HWDEP = yes;
};
    termHwStd = {
KEYBOARD_ATKBD = yes;
USB4 = yes;
SOUND = yes;
SND = yes;
SND_HDA_INTEL = yes;
SND_TIMER = yes;
} // usbStd;
    
    # It's typically fine to keep these as modules instead, which NixOS will do by default.
    termVideo = {
AGP = mkForce no;
I2C_ALGOBIT = yes;
DRM = yes;
DRM_SCHED = option yes;
DRM_KMS_HELPER = option yes;
#DRM_TTM = option yes;
#DRM_TTM_HELPER = mkForce (option yes);
DRM_I915 = module;
AMD_IOMMU_V2 = yes;
DRM_AMDGPU = module;
I2C_CHARDEV = yes; # DDC monitor control

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
