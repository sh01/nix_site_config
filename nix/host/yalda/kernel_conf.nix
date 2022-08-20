{lib, ...}:
let
  vars = import ../../base/vars.nix {inherit lib;};
  ko = vars.kernelOpts;
in with ko; with (import <nixpkgs/lib/kernel.nix> {lib = null;}); base // netStd // termHwStd // termVideo // blkStd // {
IRQ_TIME_ACCOUNTING = yes;
MODULE_FORCE_LOAD = yes;
MODULE_SRCVERSION_ALL = yes;
IOSCHED_DEADLINE = option yes;
X86_MSR = yes;
X86_CPUID = yes;
MEMORY_FAILURE = yes;
ACPI_PROCESSOR = yes;
ACPI_THERMAL = yes;
CPU_FREQ_STAT = yes;
CPU_FREQ_GOV_POWERSAVE = yes;
CPU_FREQ_GOV_USERSPACE = yes;
CPU_FREQ_GOV_ONDEMAND = yes;
#CPU_FREQ_DEFAULT_GOV_ONDEMAND = yes;
#CPU_FREQ_DEFAULT_GOV_PERFORMANCE = no;
CPU_FREQ_GOV_CONSERVATIVE = yes;

BINFMT_MISC = yes;
PACKET = yes;
XFRM_ALGO = yes;
XFRM_USER = yes;
XFRM_MIGRATE = yes;
NET_KEY = yes;
NET_KEY_MIGRATE = yes;
IP_FIB_TRIE_STATS = yes;
INET_DIAG = yes;
INET_TCP_DIAG = yes;
TCP_CONG_CUBIC = yes;
DEFAULT_CUBIC = yes;

IPV6 = yes;
INET6_AH = yes;
INET6_XFRM_MODE_TRANSPORT = option yes;
INET6_XFRM_MODE_TUNNEL = option yes;
INET6_XFRM_MODE_BEET = option yes;
IPV6_SIT = yes;
IPV6_MULTIPLE_TABLES = yes;
IPV6_FOU_TUNNEL = yes;

NETFILTER_NETLINK = yes;
NETFILTER_NETLINK_LOG = yes;
NF_CT_NETLINK = yes;
NETFILTER_XTABLES = yes;
NETFILTER_XT_MARK = yes;
NETFILTER_XT_CONNMARK = yes;
NETFILTER_XT_TARGET_CONNSECMARK = yes;
NETFILTER_XT_MATCH_CONNMARK = yes;
NETFILTER_XT_MATCH_CONNTRACK = yes;
NETFILTER_XT_MATCH_POLICY = yes;
NETFILTER_XT_MATCH_STATE = yes;

NF_DEFRAG_IPV4 = yes;
NF_REJECT_IPV4 = yes;

IP_DCCP = option yes;
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

BLK_DEV_LOOP = yes;
BLK_DEV_RAM = yes;

SCSI_MOD = yes;
RAID_ATTRS = yes;
SCSI = yes;
BLK_DEV_SD = yes;
BLK_DEV_SR = yes;
CHR_DEV_SG = yes;
SCSI_SPI_ATTRS = yes;
SCSI_SAS_ATTRS = yes;
SCSI_MPT2SAS = yes;

SATA_AHCI = yes;
PATA_VIA = yes;

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
FUSION_LOGGING = yes;

MII = yes;
E100 = yes;
E1000 = yes;
R8169 = yes;

I2C = yes;

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
RTC_HCTOSYS = yes;
RTC_DRV_CMOS = yes;

ASYNC_TX_DMA = yes;


EXT2_FS = yes;
EXT3_FS = yes;
EXT4_FS = yes;
JBD2 = yes;
FS_MBCACHE = yes;
FS_ENCRYPTION = yes;
BTRFS_FS = yes;
FUSE_FS = yes;
CUSE = yes;
FSCACHE_STATS = yes;
ISO9660_FS = yes;
CONFIGFS_FS = yes;

#NLS_CODEPAGE_437 = yes;
#NLS_ASCII = yes;
#NLS_ISO8859_1 = yes;
#NLS_UTF8 = yes;

DEVFREQ_GOV_SIMPLE_ONDEMAND = yes;
DEVFREQ_GOV_PERFORMANCE = yes;
DEVFREQ_GOV_POWERSAVE = yes;
DEVFREQ_GOV_USERSPACE = yes;
UNWINDER_ORC = no;
UNWINDER_FRAME_POINTER = yes;
}
