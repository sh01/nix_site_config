let
  vars = (import ../../base/vars.nix);
  ko = vars.kernelOpts;
  kp = vars.kernelPatches;
in {
  #### Kernel config
  powerManagement.cpuFreqGovernor = "ondemand";
  nixpkgs.config.packageOverrides = p: {
    linux = p.linux.override {
      kernelPatches = p.linux.kernelPatches ++ kp;
      extraConfig = with ko; base + termHwStd + blkStd + ''
IRQ_TIME_ACCOUNTING y
MODULE_FORCE_LOAD y
MODULE_SRCVERSION_ALL y
IOSCHED_DEADLINE y
X86_MSR y
X86_CPUID y
MEMORY_FAILURE y
ACPI_PROCESSOR y
ACPI_THERMAL y
CPU_FREQ_STAT y
CPU_FREQ_STAT_DETAILS y
CPU_FREQ_GOV_POWERSAVE y
CPU_FREQ_GOV_USERSPACE y
CPU_FREQ_GOV_ONDEMAND y
CPU_FREQ_GOV_CONSERVATIVE y
PCIE_ECRC y

BINFMT_MISC y
PACKET y
XFRM_ALGO y
XFRM_USER y
XFRM_MIGRATE y
NET_KEY y
NET_KEY_MIGRATE y
IP_FIB_TRIE_STATS y
INET_DIAG y
INET_TCP_DIAG y
TCP_CONG_CUBIC y
DEFAULT_CUBIC y

IPV6 y
INET6_AH y
INET6_XFRM_MODE_TRANSPORT y
INET6_XFRM_MODE_TUNNEL y
INET6_XFRM_MODE_BEET y
IPV6_SIT y
IPV6_MULTIPLE_TABLES y

NETFILTER_NETLINK y
NETFILTER_NETLINK_LOG y
NF_CONNTRACK y
NF_CT_NETLINK y
NETFILTER_XTABLES y
NETFILTER_XT_MARK y
NETFILTER_XT_CONNMARK y
NETFILTER_XT_TARGET_CONNSECMARK y
NETFILTER_XT_MATCH_CONNMARK y
NETFILTER_XT_MATCH_CONNTRACK y
NETFILTER_XT_MATCH_POLICY y
NETFILTER_XT_MATCH_STATE y

NF_DEFRAG_IPV4 y
NF_CONNTRACK_IPV4 y
NF_REJECT_IPV4 y

IP_NF_IPTABLES y
IP_NF_FILTER y
IP_NF_TARGET_REJECT y
IP_NF_MANGLE y
IP_NF_RAW y
IP_NF_SECURITY y
IP_NF_ARPTABLES y

NF_DEFRAG_IPV6 y
NF_CONNTRACK_IPV6 y
NF_REJECT_IPV6 y
IP6_NF_IPTABLES y
IP6_NF_MATCH_IPV6HEADER y
IP6_NF_FILTER y
IP6_NF_TARGET_REJECT y
IP6_NF_MANGLE y
IP6_NF_RAW y
IP6_NF_SECURITY y

UEVENT_HELPER y

BLK_DEV_LOOP y
BLK_DEV_RAM y

SCSI_MOD y
RAID_ATTRS y
SCSI y
BLK_DEV_SD y
BLK_DEV_SR y
CHR_DEV_SG y
SCSI_SPI_ATTRS y
SCSI_SAS_ATTRS y
SCSI_MPT2SAS y
SCSI_MPT2SAS_LOGGING y

ATA y
SATA_AHCI y
PATA_VIA y

BLK_DEV_MD y
MD_AUTODETECT y
MD_LINEAR y
MD_RAID0 y
MD_RAID1 y
MD_RAID10 y
MD_RAID456 y
BLK_DEV_DM y
DM_MIRROR y
DM_RAID y
DM_ZERO y
DM_UEVENT y
FUSION_LOGGING y

MII y
E1000 y
R8169 y

I2C y

HID y
HID_GENERIC y
USB_HID y
USB_COMMON y
USB y
USB_MON y
USB_XHCI_HCD y
USB_XHCI_PCI y
USB_EHCI_HCD y
USB_EHCI_PCI y
USB_STORAGE y
RTC_HCTOSYS y
RTC_DRV_CMOS y

ASYNC_TX_DMA y


EXT2_FS y
EXT3_FS y
EXT4_FS y
JBD2 y
FS_MBCACHE y
BTRFS_FS y
FUSE_FS y
CUSE y
FSCACHE_STATS y
ISO9660_FS y
CONFIGFS_FS y

NLS_CODEPAGE_437 y
NLS_ASCII y
NLS_ISO8859_1 y
NLS_UTF8 y


DEBUG_INFO y

DEVFREQ_GOV_SIMPLE_ONDEMAND y
DEVFREQ_GOV_PERFORMANCE y
DEVFREQ_GOV_POWERSAVE y
DEVFREQ_GOV_USERSPACE y
      '';
      ignoreConfigErrors = true;
    };
  };
}
