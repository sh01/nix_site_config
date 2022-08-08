{lib, ...}:
let
  inherit (lib) mkForce;
  vars = import ../../base/vars.nix {inherit lib;};
  ko = vars.kernelOpts;
in with ko; with (import <nixpkgs/lib/kernel.nix> {lib = null;}); base // netStd // termHwStd // termVideo // blkStd // {
IRQ_TIME_ACCOUNTING = yes;
MODULE_FORCE_LOAD = yes;
MODULE_SRCVERSION_ALL = yes;
BFQ_GROUP_IOSCHED = yes;
MQ_IOSCHED_KYBER = yes;
MQ_IOSCHED_DEADLINE = yes;
X86_MSR = yes;
X86_CPUID = yes;
MEMORY_FAILURE = yes;
ACPI_PROCESSOR = yes;
ACPI_THERMAL = yes;
CPU_FREQ_STAT = yes;
CPU_FREQ_GOV_POWERSAVE = yes;
CPU_FREQ_GOV_USERSPACE = yes;
CPU_FREQ_GOV_ONDEMAND = yes;
CPU_FREQ_GOV_CONSERVATIVE = yes;

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

NETFILTER_NETLINK = yes;
NETFILTER_NETLINK_LOG = yes;

IP_DCCP = option module;
IP_DCCP_CCID3 = option no;

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

MII = yes;
E100 = yes;
E1000 = yes;
R8169 = yes;

I2C = yes;

RTC_HCTOSYS = yes;
RTC_DRV_CMOS = yes;

ASYNC_TX_DMA = yes;


FS_MBCACHE = yes;
CUSE = yes;
FSCACHE_STATS = yes;

DEVFREQ_GOV_SIMPLE_ONDEMAND = yes;
DEVFREQ_GOV_PERFORMANCE = yes;
DEVFREQ_GOV_POWERSAVE = yes;
DEVFREQ_GOV_USERSPACE = yes;
UNWINDER_ORC = no;
UNWINDER_FRAME_POINTER = yes;
}
