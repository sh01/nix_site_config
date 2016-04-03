{
  #### Kernel config
  nixpkgs.config.packageOverrides = p: {
    linux_4_3 = p.linux_4_3.override {
      extraConfig = ''
PERF_EVENTS_INTEL_UNCORE y
LOCKDEP_SUPPORT y
STACKTRACE_SUPPORT y
HAVE_LATENCYTOP_SUPPORT y
MMU y
NEED_DMA_MAP_STATE y
NEED_SG_DMA_LENGTH y
GENERIC_ISA_DMA y
GENERIC_BUG y
GENERIC_BUG_RELATIVE_POINTERS y
GENERIC_HWEIGHT y
ARCH_MAY_HAVE_PC_FDC y
RWSEM_XCHGADD_ALGORITHM y
GENERIC_CALIBRATE_DELAY y
ARCH_HAS_CPU_RELAX y
ARCH_HAS_CACHE_LINE_SIZE y
HAVE_SETUP_PER_CPU_AREA y
NEED_PER_CPU_EMBED_FIRST_CHUNK y
NEED_PER_CPU_PAGE_FIRST_CHUNK y
ARCH_HIBERNATION_POSSIBLE y
ARCH_SUSPEND_POSSIBLE y
ARCH_WANT_HUGE_PMD_SHARE y
ARCH_WANT_GENERAL_HUGETLB y
ZONE_DMA32 y
AUDIT_ARCH y
ARCH_SUPPORTS_OPTIMIZED_INLINING y
ARCH_SUPPORTS_DEBUG_PAGEALLOC y
X86_64_SMP y
ARCH_SUPPORTS_UPROBES y
FIX_EARLYCON_MEM y
IRQ_WORK y
BUILDTIME_EXTABLE_SORT y
HAVE_KERNEL_GZIP y
HAVE_KERNEL_BZIP2 y
HAVE_KERNEL_LZMA y
HAVE_KERNEL_XZ y
HAVE_KERNEL_LZO y
HAVE_KERNEL_LZ4 y
KERNEL_GZIP y
SWAP y
SYSVIPC y
SYSVIPC_SYSCTL y
POSIX_MQUEUE y
POSIX_MQUEUE_SYSCTL y
CROSS_MEMORY_ATTACH y
FHANDLE y
USELIB y
AUDIT y
HAVE_ARCH_AUDITSYSCALL y
AUDITSYSCALL y
AUDIT_WATCH y
AUDIT_TREE y
GENERIC_IRQ_PROBE y
GENERIC_IRQ_SHOW y
GENERIC_PENDING_IRQ y
IRQ_DOMAIN y
IRQ_DOMAIN_HIERARCHY y
GENERIC_MSI_IRQ y
GENERIC_MSI_IRQ_DOMAIN y
IRQ_FORCED_THREADING y
SPARSE_IRQ y
CLOCKSOURCE_WATCHDOG y
ARCH_CLOCKSOURCE_DATA y
CLOCKSOURCE_VALIDATE_LAST_CYCLE y
GENERIC_TIME_VSYSCALL y
GENERIC_CLOCKEVENTS y
GENERIC_CLOCKEVENTS_BROADCAST y
GENERIC_CLOCKEVENTS_MIN_ADJUST y
GENERIC_CMOS_UPDATE y
TICK_ONESHOT y
NO_HZ_COMMON y
NO_HZ_IDLE y
NO_HZ y
HIGH_RES_TIMERS y
IRQ_TIME_ACCOUNTING y
BSD_PROCESS_ACCT y
BSD_PROCESS_ACCT_V3 y
TASKSTATS y
TASK_DELAY_ACCT y
TASK_XACCT y
TASK_IO_ACCOUNTING y
TREE_RCU y
SRCU y
RCU_STALL_COMMON y
BUILD_BIN2C y
IKCONFIG y
IKCONFIG_PROC y
HAVE_UNSTABLE_SCHED_CLOCK y
ARCH_SUPPORTS_NUMA_BALANCING y
ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH y
ARCH_SUPPORTS_INT128 y
CGROUPS y
CGROUP_FREEZER y
CPUSETS y
PROC_PID_CPUSET y
CGROUP_CPUACCT y
CGROUP_SCHED y
FAIR_GROUP_SCHED y
NAMESPACES y
UTS_NS y
IPC_NS y
PID_NS y
NET_NS y
RELAY y
BLK_DEV_INITRD y
RD_GZIP y
RD_BZIP2 y
RD_LZMA y
RD_XZ y
RD_LZO y
RD_LZ4 y
SYSCTL y
ANON_INODES y
HAVE_UID16 y
SYSCTL_EXCEPTION_TRACE y
HAVE_PCSPKR_PLATFORM y
BPF y
UID16 y
MULTIUSER y
SGETMASK_SYSCALL y
SYSFS_SYSCALL y
KALLSYMS y
PRINTK y
BUG y
ELF_CORE y
PCSPKR_PLATFORM y
BASE_FULL y
FUTEX y
EPOLL y
SIGNALFD y
TIMERFD y
EVENTFD y
SHMEM y
AIO y
ADVISE_SYSCALLS y
PCI_QUIRKS y
MEMBARRIER y
HAVE_PERF_EVENTS y
PERF_EVENTS y
VM_EVENT_COUNTERS y
SLUB_DEBUG y
SLUB y
SLUB_CPU_PARTIAL y
PROFILING y
TRACEPOINTS y
KEXEC_CORE y
HAVE_OPROFILE y
OPROFILE_NMI_TIMER y
KPROBES y
JUMP_LABEL y
OPTPROBES y
HAVE_EFFICIENT_UNALIGNED_ACCESS y
ARCH_USE_BUILTIN_BSWAP y
KRETPROBES y
HAVE_IOREMAP_PROT y
HAVE_KPROBES y
HAVE_KRETPROBES y
HAVE_OPTPROBES y
HAVE_KPROBES_ON_FTRACE y
HAVE_ARCH_TRACEHOOK y
HAVE_DMA_ATTRS y
HAVE_DMA_CONTIGUOUS y
GENERIC_SMP_IDLE_THREAD y
ARCH_WANTS_DYNAMIC_TASK_STRUCT y
HAVE_REGS_AND_STACK_ACCESS_API y
HAVE_DMA_API_DEBUG y
HAVE_HW_BREAKPOINT y
HAVE_MIXED_BREAKPOINTS_REGS y
HAVE_USER_RETURN_NOTIFIER y
HAVE_PERF_EVENTS_NMI y
HAVE_PERF_REGS y
HAVE_PERF_USER_STACK_DUMP y
HAVE_ARCH_JUMP_LABEL y
ARCH_HAVE_NMI_SAFE_CMPXCHG y
HAVE_ALIGNED_STRUCT_PAGE y
HAVE_CMPXCHG_LOCAL y
HAVE_CMPXCHG_DOUBLE y
ARCH_WANT_COMPAT_IPC_PARSE_VERSION y
ARCH_WANT_OLD_COMPAT_IPC y
HAVE_ARCH_SECCOMP_FILTER y
SECCOMP_FILTER y
HAVE_CC_STACKPROTECTOR y
CC_STACKPROTECTOR y
CC_STACKPROTECTOR_REGULAR y
HAVE_CONTEXT_TRACKING y
HAVE_VIRT_CPU_ACCOUNTING_GEN y
HAVE_IRQ_TIME_ACCOUNTING y
HAVE_ARCH_TRANSPARENT_HUGEPAGE y
HAVE_ARCH_HUGE_VMAP y
HAVE_ARCH_SOFT_DIRTY y
MODULES_USE_ELF_RELA y
HAVE_IRQ_EXIT_ON_IRQ_STACK y
ARCH_HAS_ELF_RANDOMIZE y
HAVE_COPY_THREAD_TLS y
OLD_SIGSUSPEND3 y
COMPAT_OLD_SIGACTION y
ARCH_HAS_GCOV_PROFILE_ALL y
SLABINFO y
RT_MUTEXES y
MODULES y
MODULE_FORCE_LOAD y
MODULE_UNLOAD y
MODULE_FORCE_UNLOAD y
MODVERSIONS y
MODULE_SRCVERSION_ALL y
MODULES_TREE_LOOKUP y
STOP_MACHINE y
BLOCK y
BLK_DEV_BSG y
BLK_DEV_INTEGRITY y
PARTITION_ADVANCED y
OSF_PARTITION y
AMIGA_PARTITION y
MAC_PARTITION y
MSDOS_PARTITION y
BSD_DISKLABEL y
MINIX_SUBPARTITION y
SOLARIS_X86_PARTITION y
UNIXWARE_DISKLABEL y
SGI_PARTITION y
SUN_PARTITION y
KARMA_PARTITION y
EFI_PARTITION y
BLOCK_COMPAT y
IOSCHED_NOOP y
IOSCHED_DEADLINE y
IOSCHED_CFQ y
DEFAULT_CFQ y
PADATA y
INLINE_SPIN_UNLOCK_IRQ y
INLINE_READ_UNLOCK y
INLINE_READ_UNLOCK_IRQ y
INLINE_WRITE_UNLOCK y
INLINE_WRITE_UNLOCK_IRQ y
ARCH_SUPPORTS_ATOMIC_RMW y
MUTEX_SPIN_ON_OWNER y
RWSEM_SPIN_ON_OWNER y
LOCK_SPIN_ON_OWNER y
ARCH_USE_QUEUED_SPINLOCKS y
QUEUED_SPINLOCKS y
ARCH_USE_QUEUED_RWLOCKS y
QUEUED_RWLOCKS y
FREEZER y
ZONE_DMA y
SMP y
X86_FEATURE_NAMES y
X86_MPPARSE y
X86_EXTENDED_PLATFORM y
X86_SUPPORTS_MEMORY_FAILURE y
SCHED_OMIT_FRAME_POINTER y
NO_BOOTMEM y
GENERIC_CPU y
X86_TSC y
X86_CMPXCHG64 y
X86_CMOV y
X86_DEBUGCTLMSR y
CPU_SUP_INTEL y
CPU_SUP_AMD y
CPU_SUP_CENTAUR y
HPET_TIMER y
HPET_EMULATE_RTC y
DMI y
GART_IOMMU y
CALGARY_IOMMU y
CALGARY_IOMMU_ENABLED_BY_DEFAULT y
SWIOTLB y
IOMMU_HELPER y
SCHED_SMT y
SCHED_MC y
PREEMPT_VOLUNTARY y
X86_LOCAL_APIC y
X86_IO_APIC y
X86_REROUTE_FOR_BROKEN_BOOT_IRQS y
X86_MCE y
X86_MCE_INTEL y
X86_MCE_AMD y
X86_MCE_THRESHOLD y
X86_THERMAL_VECTOR y
X86_16BIT y
X86_ESPFIX64 y
X86_VSYSCALL_EMULATION y
MICROCODE y
MICROCODE_INTEL y
MICROCODE_AMD y
MICROCODE_OLD_INTERFACE y
MICROCODE_INTEL_EARLY y
MICROCODE_AMD_EARLY y
MICROCODE_EARLY y
X86_MSR y
X86_CPUID y
ARCH_PHYS_ADDR_T_64BIT y
ARCH_DMA_ADDR_T_64BIT y
X86_DIRECT_GBPAGES y
NUMA y
AMD_NUMA y
X86_64_ACPI_NUMA y
NODES_SPAN_OTHER_NODES y
ARCH_SPARSEMEM_ENABLE y
ARCH_SPARSEMEM_DEFAULT y
ARCH_SELECT_MEMORY_MODEL y
ARCH_PROC_KCORE_TEXT y
SELECT_MEMORY_MODEL y
SPARSEMEM_MANUAL y
SPARSEMEM y
NEED_MULTIPLE_NODES y
HAVE_MEMORY_PRESENT y
SPARSEMEM_EXTREME y
SPARSEMEM_VMEMMAP_ENABLE y
SPARSEMEM_ALLOC_MEM_MAP_TOGETHER y
SPARSEMEM_VMEMMAP y
HAVE_MEMBLOCK y
HAVE_MEMBLOCK_NODE_MAP y
ARCH_DISCARD_MEMBLOCK y
MEMORY_ISOLATION y
PAGEFLAGS_EXTENDED y
ARCH_ENABLE_SPLIT_PMD_PTLOCK y
COMPACTION y
MIGRATION y
ARCH_ENABLE_HUGEPAGE_MIGRATION y
PHYS_ADDR_T_64BIT y
BOUNCE y
VIRT_TO_BUS y
KSM y
ARCH_SUPPORTS_MEMORY_FAILURE y
MEMORY_FAILURE y
TRANSPARENT_HUGEPAGE y
TRANSPARENT_HUGEPAGE_ALWAYS y
GENERIC_EARLY_IOREMAP y
ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT y
X86_CHECK_BIOS_CORRUPTION y
X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK y
MTRR y
X86_PAT y
ARCH_USES_PG_UNCACHED y
ARCH_RANDOM y
X86_SMAP y
EFI y
SECCOMP y
HZ_1000 y
SCHED_HRTICK y
KEXEC y
CRASH_DUMP y
RELOCATABLE y
HOTPLUG_CPU y
MODIFY_LDT_SYSCALL y
HAVE_LIVEPATCH y
ARCH_ENABLE_MEMORY_HOTPLUG y
USE_PERCPU_NUMA_NODE_ID y
SUSPEND y
SUSPEND_FREEZER y
PM_SLEEP y
PM_SLEEP_SMP y
PM y
PM_DEBUG y
PM_SLEEP_DEBUG y
PM_TRACE y
PM_TRACE_RTC y
ACPI y
ACPI_LEGACY_TABLES_LOOKUP y
ARCH_MIGHT_HAVE_ACPI_PDC y
ACPI_SYSTEM_POWER_STATES_SUPPORT y
ACPI_SLEEP y
ACPI_REV_OVERRIDE_POSSIBLE y
ACPI_AC y
ACPI_BATTERY y
ACPI_BUTTON y
ACPI_FAN y
ACPI_DOCK y
ACPI_CPU_FREQ_PSS y
ACPI_PROCESSOR_IDLE y
ACPI_PROCESSOR y
ACPI_HOTPLUG_CPU y
ACPI_THERMAL y
ACPI_NUMA y
X86_PM_TIMER y
ACPI_CONTAINER y
ACPI_HOTPLUG_IOAPIC y
HAVE_ACPI_APEI y
HAVE_ACPI_APEI_NMI y
CPU_FREQ y
CPU_FREQ_GOV_COMMON y
CPU_FREQ_STAT y
CPU_FREQ_STAT_DETAILS y
CPU_FREQ_DEFAULT_GOV_ONDEMAND y
CPU_FREQ_GOV_PERFORMANCE y
CPU_FREQ_GOV_POWERSAVE y
CPU_FREQ_GOV_USERSPACE y
CPU_FREQ_GOV_ONDEMAND y
CPU_FREQ_GOV_CONSERVATIVE y
X86_PCC_CPUFREQ m
X86_ACPI_CPUFREQ y
X86_ACPI_CPUFREQ_CPB y
X86_POWERNOW_K8 m
X86_P4_CLOCKMOD m
X86_SPEEDSTEP_LIB m
CPU_IDLE y
CPU_IDLE_GOV_LADDER y
CPU_IDLE_GOV_MENU y
INTEL_IDLE y
I7300_IDLE_IOAT_CHANNEL y
I7300_IDLE y
PCI y
PCI_DIRECT y
PCI_MMCONFIG y
PCI_DOMAINS y
PCIEPORTBUS y
PCIEAER y
PCIE_ECRC y
PCIEASPM y
PCIEASPM_DEFAULT y
PCIE_PME y
PCI_BUS_ADDR_T_64BIT y
PCI_MSI y
PCI_MSI_IRQ_DOMAIN y
HT_IRQ y
PCI_ATS y
PCI_IOV y
PCI_PRI y
PCI_PASID y
PCI_LABEL y
ISA_DMA_API y
AMD_NB y
BINFMT_ELF y
COMPAT_BINFMT_ELF y
CORE_DUMP_DEFAULT_ELF_HEADERS y
BINFMT_SCRIPT y
BINFMT_MISC y
COREDUMP y
IA32_EMULATION y
COMPAT y
COMPAT_FOR_U64_ALIGNMENT y
SYSVIPC_COMPAT y
KEYS_COMPAT y
X86_DEV_DMA_OPS y
PMC_ATOM y
NET y
NET_INGRESS y
PACKET y
UNIX y
XFRM y
XFRM_ALGO y
XFRM_USER y
XFRM_MIGRATE y
XFRM_IPCOMP m
NET_KEY y
NET_KEY_MIGRATE y
INET y
IP_MULTICAST y
IP_ADVANCED_ROUTER y
IP_FIB_TRIE_STATS y
IP_MULTIPLE_TABLES y
IP_ROUTE_MULTIPATH y
IP_ROUTE_VERBOSE y
IP_ROUTE_CLASSID y
IP_PNP y
IP_PNP_DHCP y
IP_PNP_BOOTP y
IP_PNP_RARP y
NET_IPIP m
NET_IP_TUNNEL y
IP_MROUTE y
IP_PIMSM_V1 y
IP_PIMSM_V2 y
SYN_COOKIES y
INET_TUNNEL y
INET_XFRM_MODE_TRANSPORT m
INET_XFRM_MODE_TUNNEL m
INET_XFRM_MODE_BEET m
INET_LRO y
INET_DIAG y
INET_TCP_DIAG y
TCP_CONG_ADVANCED y
TCP_CONG_BIC m
TCP_CONG_CUBIC y
TCP_CONG_WESTWOOD m
TCP_CONG_HTCP m
TCP_CONG_HSTCP m
TCP_CONG_HYBLA m
TCP_CONG_VEGAS m
TCP_CONG_SCALABLE m
TCP_CONG_LP m
TCP_CONG_VENO m
TCP_CONG_YEAH m
TCP_CONG_ILLINOIS m
DEFAULT_CUBIC y
TCP_MD5SIG y
IPV6 y
INET6_AH y
INET6_IPCOMP m
IPV6_MIP6 m
INET6_XFRM_TUNNEL m
INET6_TUNNEL m
INET6_XFRM_MODE_TRANSPORT y
INET6_XFRM_MODE_TUNNEL y
INET6_XFRM_MODE_BEET y
INET6_XFRM_MODE_ROUTEOPTIMIZATION m
IPV6_SIT y
IPV6_NDISC_NODETYPE y
IPV6_TUNNEL m
IPV6_MULTIPLE_TABLES y
NETLABEL y
NETWORK_SECMARK y
NET_PTP_CLASSIFY y
NETFILTER y
NETFILTER_ADVANCED y
BRIDGE_NETFILTER m
NETFILTER_INGRESS y
NETFILTER_NETLINK y
NETFILTER_NETLINK_QUEUE m
NETFILTER_NETLINK_LOG y
NF_CONNTRACK y
NF_CONNTRACK_MARK y
NF_CONNTRACK_SECMARK y
NF_CONNTRACK_PROCFS y
NF_CT_PROTO_SCTP m
NF_CT_NETLINK y
NETFILTER_XTABLES y
NETFILTER_XT_MARK y
NETFILTER_XT_CONNMARK y
NETFILTER_XT_TARGET_AUDIT m
NETFILTER_XT_TARGET_CHECKSUM m
NETFILTER_XT_TARGET_CLASSIFY m
NETFILTER_XT_TARGET_CONNMARK m
NETFILTER_XT_TARGET_CONNSECMARK y
NETFILTER_XT_TARGET_DSCP m
NETFILTER_XT_TARGET_HL m
NETFILTER_XT_TARGET_IDLETIMER m
NETFILTER_XT_TARGET_LED m
NETFILTER_XT_TARGET_MARK m
NETFILTER_XT_TARGET_NFLOG y
NETFILTER_XT_TARGET_NFQUEUE m
NETFILTER_XT_TARGET_RATEEST m
NETFILTER_XT_TARGET_TEE m
NETFILTER_XT_TARGET_SECMARK y
NETFILTER_XT_TARGET_TCPMSS y
NETFILTER_XT_TARGET_TCPOPTSTRIP m
NETFILTER_XT_MATCH_ADDRTYPE m
NETFILTER_XT_MATCH_CLUSTER m
NETFILTER_XT_MATCH_COMMENT m
NETFILTER_XT_MATCH_CONNBYTES m
NETFILTER_XT_MATCH_CONNLIMIT m
NETFILTER_XT_MATCH_CONNMARK y
NETFILTER_XT_MATCH_CONNTRACK y
NETFILTER_XT_MATCH_CPU m
NETFILTER_XT_MATCH_DCCP m
NETFILTER_XT_MATCH_DEVGROUP m
NETFILTER_XT_MATCH_DSCP m
NETFILTER_XT_MATCH_ESP m
NETFILTER_XT_MATCH_HASHLIMIT m
NETFILTER_XT_MATCH_HELPER m
NETFILTER_XT_MATCH_HL m
NETFILTER_XT_MATCH_IPRANGE m
NETFILTER_XT_MATCH_LENGTH m
NETFILTER_XT_MATCH_LIMIT m
NETFILTER_XT_MATCH_MAC m
NETFILTER_XT_MATCH_MARK m
NETFILTER_XT_MATCH_MULTIPORT m
NETFILTER_XT_MATCH_OSF m
NETFILTER_XT_MATCH_OWNER m
NETFILTER_XT_MATCH_POLICY y
NETFILTER_XT_MATCH_PKTTYPE m
NETFILTER_XT_MATCH_QUOTA m
NETFILTER_XT_MATCH_RATEEST m
NETFILTER_XT_MATCH_REALM m
NETFILTER_XT_MATCH_RECENT m
NETFILTER_XT_MATCH_SCTP m
NETFILTER_XT_MATCH_STATE y
NETFILTER_XT_MATCH_STATISTIC m
NETFILTER_XT_MATCH_STRING m
NETFILTER_XT_MATCH_TCPMSS m
NETFILTER_XT_MATCH_TIME m
NETFILTER_XT_MATCH_U32 m
IP_SET m
IP_SET_BITMAP_IP m
IP_SET_BITMAP_IPMAC m
IP_SET_BITMAP_PORT m
IP_SET_HASH_IP m
IP_SET_HASH_IPPORT m
IP_SET_HASH_IPPORTIP m
IP_SET_HASH_IPPORTNET m
IP_SET_HASH_NET m
IP_SET_HASH_NETPORT m
IP_SET_LIST_SET m
NF_DEFRAG_IPV4 y
NF_CONNTRACK_IPV4 y
NF_CONNTRACK_PROC_COMPAT y
NF_DUP_IPV4 m
NF_REJECT_IPV4 y
IP_NF_IPTABLES y
IP_NF_FILTER y
IP_NF_TARGET_REJECT y
IP_NF_MANGLE y
IP_NF_RAW y
IP_NF_SECURITY y
IP_NF_ARPTABLES y
IP_NF_ARPFILTER m
IP_NF_ARP_MANGLE m
NF_DEFRAG_IPV6 y
NF_CONNTRACK_IPV6 y
NF_DUP_IPV6 m
NF_REJECT_IPV6 y
IP6_NF_IPTABLES y
IP6_NF_MATCH_IPV6HEADER y
IP6_NF_FILTER y
IP6_NF_TARGET_REJECT y
IP6_NF_MANGLE y
IP6_NF_RAW y
IP6_NF_SECURITY y
IP_SCTP m
SCTP_DEFAULT_COOKIE_HMAC_MD5 y
SCTP_COOKIE_HMAC_MD5 y
STP m
BRIDGE m
BRIDGE_IGMP_SNOOPING y
HAVE_NET_DSA y
LLC m
NET_SCHED y
NET_CLS y
NET_EMATCH y
NET_CLS_ACT y
NET_SCH_FIFO y
DNS_RESOLVER y
RPS y
RFS_ACCEL y
XPS y
NET_RX_BUSY_POLL y
BQL y
BPF_JIT y
NET_FLOW_LIMIT y
AF_RXRPC y
RXKAD y
FIB_RULES y
CEPH_LIB m
HAVE_BPF_JIT y
UEVENT_HELPER y
DEVTMPFS y
STANDALONE y
PREVENT_FIRMWARE_BUILD y
FW_LOADER y
FIRMWARE_IN_KERNEL y
ALLOW_DEV_COREDUMP y
DEBUG_DEVRES y
GENERIC_CPU_AUTOPROBE y
REGMAP y
REGMAP_I2C m
REGMAP_MMIO y
CONNECTOR y
PROC_EVENTS y
ARCH_MIGHT_HAVE_PC_PARPORT y
PNP y
PNP_DEBUG_MESSAGES y
PNPACPI y
BLK_DEV y
BLK_DEV_LOOP y
BLK_DEV_RAM y
HAVE_IDE y
SCSI_MOD y
RAID_ATTRS y
SCSI y
SCSI_DMA y
SCSI_NETLINK y
SCSI_PROC_FS y
BLK_DEV_SD y
BLK_DEV_SR y
BLK_DEV_SR_VENDOR y
CHR_DEV_SG y
SCSI_CONSTANTS y
SCSI_SPI_ATTRS y
SCSI_FC_ATTRS m
SCSI_SAS_ATTRS y
SCSI_LOWLEVEL y
SCSI_MPT2SAS m
SCSI_MPT2SAS_LOGGING y
ATA y
ATA_VERBOSE_ERROR y
ATA_ACPI y
SATA_PMP y
SATA_AHCI y
ATA_SFF y
SATA_SX4 y
ATA_BMDMA y
ATA_PIIX y
SATA_MV y
SATA_SIL m
PATA_AMD y
PATA_OLDPIIX y
PATA_SCH y
PATA_ACPI y
ATA_GENERIC y
MD y
BLK_DEV_MD y
MD_AUTODETECT y
MD_LINEAR y
MD_RAID0 y
MD_RAID1 y
MD_RAID10 y
MD_RAID456 y
MD_FAULTY m
BLK_DEV_DM_BUILTIN y
BLK_DEV_DM y
DM_BUFIO m
DM_CRYPT m
DM_SNAPSHOT m
DM_MIRROR y
DM_LOG_USERSPACE m
DM_RAID y
DM_ZERO y
DM_MULTIPATH m
DM_MULTIPATH_QL m
DM_MULTIPATH_ST m
DM_DELAY m
DM_UEVENT y
DM_FLAKEY m
FUSION y
FUSION_SPI m
FUSION_FC m
FUSION_SAS m
FUSION_CTL m
FUSION_LOGGING y
FIREWIRE m
FIREWIRE_OHCI m
FIREWIRE_SBP2 m
FIREWIRE_NET m
FIREWIRE_NOSY m
NETDEVICES y
MII y
NET_CORE y
BONDING m
DUMMY m
EQUALIZER m
IFB m
MACVLAN m
MACVTAP m
NETCONSOLE y
NETPOLL y
NET_POLL_CONTROLLER y
TUN m
VETH m
ARCNET m
ETHERNET y
NET_VENDOR_3COM y
NET_VENDOR_ADAPTEC y
NET_VENDOR_AGERE y
NET_VENDOR_ALTEON y
ACENIC m
NET_VENDOR_AMD y
NET_VENDOR_ARC y
NET_VENDOR_ATHEROS y
ATL1 m
ATL1E m
ATL1C m
NET_CADENCE y
NET_VENDOR_BROADCOM y
BNX2 m
CNIC m
TIGON3 y
NET_VENDOR_BROCADE y
NET_VENDOR_CAVIUM y
NET_VENDOR_CHELSIO y
NET_VENDOR_CISCO y
NET_VENDOR_DEC y
NET_TULIP y
NET_VENDOR_DLINK y
DL2K m
NET_VENDOR_EMULEX y
NET_VENDOR_EZCHIP y
NET_VENDOR_EXAR y
NET_VENDOR_HP y
NET_VENDOR_INTEL y
E100 y
E1000 y
E1000E m
IGB m
IGB_HWMON y
IGBVF m
NET_VENDOR_I825XX y
IP1000 m
JME m
NET_VENDOR_MARVELL y
SKGE m
SKY2 m
NET_VENDOR_MELLANOX y
NET_VENDOR_MICREL y
NET_VENDOR_MYRI y
NET_VENDOR_NATSEMI y
NS83820 m
NET_VENDOR_8390 y
NET_VENDOR_NVIDIA y
FORCEDETH y
NET_VENDOR_OKI y
NET_VENDOR_QLOGIC y
QLA3XXX m
NET_VENDOR_QUALCOMM y
NET_VENDOR_REALTEK y
8139TOO y
8139TOO_PIO y
R8169 y
NET_VENDOR_RENESAS y
NET_VENDOR_RDC y
NET_VENDOR_ROCKER y
NET_VENDOR_SAMSUNG y
NET_VENDOR_SEEQ y
NET_VENDOR_SILAN y
NET_VENDOR_SIS y
SIS190 m
NET_VENDOR_SMSC y
NET_VENDOR_STMICRO y
STMMAC_ETH m
STMMAC_PLATFORM m
DWMAC_GENERIC m
NET_VENDOR_SUN y
NET_VENDOR_SYNOPSYS y
NET_VENDOR_TEHUTI y
NET_VENDOR_TI y
NET_VENDOR_VIA y
VIA_VELOCITY m
NET_VENDOR_WIZNET y
FDDI y
NET_SB1000 m
PHYLIB y
USB_NET_DRIVERS y
INPUT y
INPUT_LEDS y
INPUT_FF_MEMLESS y
INPUT_POLLDEV y
INPUT_SPARSEKMAP y
INPUT_MOUSEDEV y
INPUT_EVDEV y
INPUT_KEYBOARD y
KEYBOARD_ATKBD y
INPUT_MOUSE y
MOUSE_PS2 y
MOUSE_PS2_ALPS y
MOUSE_PS2_LOGIPS2PP y
MOUSE_PS2_SYNAPTICS y
MOUSE_PS2_CYPRESS y
MOUSE_PS2_LIFEBOOK y
MOUSE_PS2_TRACKPOINT y
MOUSE_PS2_FOCALTECH y
INPUT_JOYSTICK y
INPUT_TABLET y
INPUT_TOUCHSCREEN y
TOUCHSCREEN_PROPERTIES y
INPUT_MISC y
SERIO y
ARCH_MIGHT_HAVE_PC_SERIO y
SERIO_I8042 y
SERIO_SERPORT y
SERIO_LIBPS2 y
TTY y
VT y
CONSOLE_TRANSLATIONS y
VT_CONSOLE y
VT_CONSOLE_SLEEP y
HW_CONSOLE y
VT_HW_CONSOLE_BINDING y
UNIX98_PTYS y
SERIAL_NONSTANDARD y
DEVMEM y
DEVKMEM y
SERIAL_EARLYCON y
SERIAL_8250 y
SERIAL_8250_DEPRECATED_OPTIONS y
SERIAL_8250_PNP y
SERIAL_8250_CONSOLE y
SERIAL_8250_DMA y
SERIAL_8250_PCI y
SERIAL_8250_EXTENDED y
SERIAL_8250_MANY_PORTS y
SERIAL_8250_SHARE_IRQ y
SERIAL_8250_DETECT_IRQ y
SERIAL_8250_RSA y
SERIAL_CORE y
SERIAL_CORE_CONSOLE y
HW_RANDOM y
HW_RANDOM_VIA y
NVRAM y
HPET y
HANGCHECK_TIMER y
DEVPORT y
I2C y
ACPI_I2C_OPREGION y
I2C_BOARDINFO y
I2C_COMPAT y
I2C_CHARDEV m
I2C_MUX m
I2C_HELPER_AUTO y
I2C_ALGOBIT m
I2C_I801 y
PPS y
PTP_1588_CLOCK y
ARCH_WANT_OPTIONAL_GPIOLIB y
POWER_SUPPLY y
HWMON y
HWMON_VID m
SENSORS_ABITUGURU m
SENSORS_ABITUGURU3 m
SENSORS_AD7414 m
SENSORS_AD7418 m
SENSORS_ADM1021 m
SENSORS_ADM1025 m
SENSORS_ADM1026 m
SENSORS_ADM1029 m
SENSORS_ADM1031 m
SENSORS_ADM9240 m
SENSORS_ADT7411 m
SENSORS_ADT7462 m
SENSORS_ADT7470 m
SENSORS_ADT7475 m
SENSORS_ASC7621 m
SENSORS_K8TEMP m
SENSORS_K10TEMP m
SENSORS_FAM15H_POWER m
SENSORS_APPLESMC m
SENSORS_ASB100 m
SENSORS_ATXP1 m
SENSORS_DS620 m
SENSORS_DS1621 m
SENSORS_I5K_AMB m
SENSORS_F71805F m
SENSORS_F71882FG m
SENSORS_F75375S m
SENSORS_FSCHMD m
SENSORS_GL518SM m
SENSORS_GL520SM m
SENSORS_G760A m
SENSORS_CORETEMP m
SENSORS_IT87 m
SENSORS_JC42 m
SENSORS_LINEAGE m
SENSORS_LTC4151 m
SENSORS_LTC4215 m
SENSORS_LTC4245 m
SENSORS_LTC4261 m
SENSORS_MAX16065 m
SENSORS_MAX1619 m
SENSORS_MAX6639 m
SENSORS_MAX6642 m
SENSORS_MAX6650 m
SENSORS_LM63 m
SENSORS_LM73 m
SENSORS_LM75 m
SENSORS_LM77 m
SENSORS_LM78 m
SENSORS_LM80 m
SENSORS_LM83 m
SENSORS_LM85 m
SENSORS_LM87 m
SENSORS_LM90 m
SENSORS_LM92 m
SENSORS_LM93 m
SENSORS_LM95241 m
SENSORS_PC87360 m
SENSORS_PC87427 m
SENSORS_PCF8591 m
PMBUS m
SENSORS_PMBUS m
SENSORS_ADM1275 m
SENSORS_MAX16064 m
SENSORS_MAX34440 m
SENSORS_MAX8688 m
SENSORS_UCD9000 m
SENSORS_UCD9200 m
SENSORS_SHT21 m
SENSORS_SIS5595 m
SENSORS_DME1737 m
SENSORS_EMC1403 m
SENSORS_EMC2103 m
SENSORS_EMC6W201 m
SENSORS_SMSC47M1 m
SENSORS_SMSC47M192 m
SENSORS_SMSC47B397 m
SENSORS_SCH56XX_COMMON m
SENSORS_SCH5627 m
SENSORS_SMM665 m
SENSORS_ADS1015 m
SENSORS_ADS7828 m
SENSORS_AMC6821 m
SENSORS_THMC50 m
SENSORS_TMP102 m
SENSORS_TMP401 m
SENSORS_TMP421 m
SENSORS_VIA_CPUTEMP m
SENSORS_VIA686A m
SENSORS_VT1211 m
SENSORS_VT8231 m
SENSORS_W83781D m
SENSORS_W83791D m
SENSORS_W83792D m
SENSORS_W83793 m
SENSORS_W83795 m
SENSORS_W83L785TS m
SENSORS_W83L786NG m
SENSORS_W83627HF m
SENSORS_W83627EHF m
SENSORS_ACPI_POWER m
SENSORS_ATK0110 m
THERMAL y
THERMAL_HWMON y
THERMAL_DEFAULT_GOV_STEP_WISE y
THERMAL_GOV_STEP_WISE y
THERMAL_GOV_USER_SPACE y
X86_PKG_TEMP_THERMAL m
WATCHDOG y
WATCHDOG_CORE y
SSB_POSSIBLE y
BCMA_POSSIBLE y
MFD_SYSCON y
VGA_ARB y
VGA_CONSOLE y
VGACON_SOFT_SCROLLBACK y
DUMMY_CONSOLE y
HID y
HIDRAW y
HID_GENERIC y
HID_A4TECH y
HID_APPLE y
HID_BELKIN y
HID_CHERRY y
HID_CHICONY y
HID_CYPRESS y
HID_EZKEY y
HID_KYE y
HID_GYRATION y
HID_KENSINGTON y
HID_LOGITECH y
HID_LOGITECH_DJ m
HID_LOGITECH_HIDPP m
LOGITECH_FF y
LOGIWHEELS_FF y
HID_MICROSOFT y
HID_MONTEREY y
HID_NTRIG y
HID_PANTHERLORD y
PANTHERLORD_FF y
HID_PETALYNX y
HID_PLANTRONICS y
HID_SAMSUNG y
HID_SONY y
HID_SUNPLUS y
HID_TOPSEED y
USB_HID y
HID_PID y
USB_HIDDEV y
USB_OHCI_LITTLE_ENDIAN y
USB_SUPPORT y
USB_COMMON y
USB_ARCH_HAS_HCD y
USB y
USB_ANNOUNCE_NEW_DEVICES y
USB_DEFAULT_PERSIST y
USB_MON y
USB_XHCI_HCD y
USB_XHCI_PCI y
USB_EHCI_HCD y
USB_EHCI_PCI y
USB_OHCI_HCD y
USB_OHCI_HCD_PCI y
USB_UHCI_HCD y
USB_STORAGE y
USB_SERIAL m
USB_SERIAL_GENERIC y
MMC m
MMC_BLOCK m
MMC_BLOCK_BOUNCE y
NEW_LEDS y
LEDS_CLASS y
LEDS_TRIGGERS y
EDAC_ATOMIC_SCRUB y
EDAC_SUPPORT y
EDAC y
EDAC_LEGACY_SYSFS y
EDAC_DECODE_MCE y
RTC_LIB y
RTC_CLASS y
RTC_HCTOSYS y
RTC_SYSTOHC y
RTC_INTF_SYSFS y
RTC_INTF_PROC y
RTC_INTF_DEV y
RTC_DRV_DS1307 m
RTC_DRV_DS1374 m
RTC_DRV_DS1672 m
RTC_DRV_DS3232 m
RTC_DRV_MAX6900 m
RTC_DRV_RS5C372 m
RTC_DRV_ISL1208 m
RTC_DRV_ISL12022 m
RTC_DRV_X1205 m
RTC_DRV_PCF8563 m
RTC_DRV_PCF8583 m
RTC_DRV_M41T80 m
RTC_DRV_M41T80_WDT y
RTC_DRV_BQ32K m
RTC_DRV_S35390A m
RTC_DRV_FM3130 m
RTC_DRV_RX8581 m
RTC_DRV_RX8025 m
RTC_DRV_EM3027 m
RTC_DRV_RV3029C2 m
RTC_DRV_CMOS y
RTC_DRV_DS1286 m
RTC_DRV_DS1511 m
RTC_DRV_DS1553 m
RTC_DRV_DS1742 m
RTC_DRV_STK17TA8 m
RTC_DRV_M48T86 m
RTC_DRV_M48T35 m
RTC_DRV_M48T59 m
RTC_DRV_MSM6242 m
RTC_DRV_BQ4802 m
RTC_DRV_RP5C01 m
RTC_DRV_V3020 m
DMADEVICES y
DMA_ENGINE y
DMA_ACPI y
INTEL_IOATDMA m
ASYNC_TX_DMA y
DMA_ENGINE_RAID y
DCA m
UIO m
VFIO_IOMMU_TYPE1 m
VFIO_VIRQFD m
VFIO m
VFIO_PCI m
VFIO_PCI_MMAP y
VFIO_PCI_INTX y
X86_PLATFORM_DEVICES y
CLKEVT_I8253 y
I8253_LOCK y
CLKBLD_I8253 y
IOMMU_API y
IOMMU_SUPPORT y
AMD_IOMMU y
AMD_IOMMU_STATS y
IIO m
RESET_CONTROLLER y
GENERIC_PHY y
RAS y
FIRMWARE_MEMMAP y
DMIID y
DMI_SCAN_MACHINE_NON_EFI_FALLBACK y
EFI_VARS y
EFI_ESRT y
EFI_RUNTIME_MAP y
EFI_RUNTIME_WRAPPERS y
DCACHE_WORD_ACCESS y
EXT2_FS y
EXT2_FS_XATTR y
EXT2_FS_POSIX_ACL y
EXT2_FS_SECURITY y
EXT3_FS y
EXT3_FS_POSIX_ACL y
EXT3_FS_SECURITY y
EXT4_FS y
EXT4_FS_POSIX_ACL y
EXT4_FS_SECURITY y
JBD2 y
FS_MBCACHE y
BTRFS_FS y
BTRFS_FS_POSIX_ACL y
FS_POSIX_ACL y
EXPORTFS y
FILE_LOCKING y
FSNOTIFY y
DNOTIFY y
INOTIFY_USER y
FANOTIFY y
QUOTA y
QUOTA_NETLINK_INTERFACE y
QUOTA_TREE y
QFMT_V2 y
QUOTACTL y
QUOTACTL_COMPAT y
AUTOFS4_FS y
FUSE_FS y
CUSE y
FSCACHE m
FSCACHE_STATS y
CACHEFILES m
ISO9660_FS y
JOLIET y
ZISOFS y
UDF_FS m
UDF_NLS y
FAT_FS m
MSDOS_FS m
VFAT_FS m
NTFS_FS m
NTFS_RW y
PROC_FS y
PROC_KCORE y
PROC_VMCORE y
PROC_SYSCTL y
PROC_PAGE_MONITOR y
KERNFS y
SYSFS y
TMPFS y
TMPFS_POSIX_ACL y
TMPFS_XATTR y
HUGETLBFS y
HUGETLB_PAGE y
CONFIGFS_FS y
MISC_FILESYSTEMS y
NETWORK_FILESYSTEMS y
NFS_FS y
NFS_V2 y
NFS_V3 y
NFS_V3_ACL y
NFS_V4 y
ROOT_NFS y
NFS_USE_KERNEL_DNS y
NFSD m
NFSD_V2_ACL y
NFSD_V3 y
NFSD_V3_ACL y
NFSD_V4 y
GRACE_PERIOD y
LOCKD y
LOCKD_V4 y
NFS_ACL_SUPPORT y
NFS_COMMON y
SUNRPC y
SUNRPC_GSS y
RPCSEC_GSS_KRB5 m
CEPH_FS m
CIFS m
CIFS_STATS y
CIFS_DEBUG y
NLS y
NLS_CODEPAGE_437 y
NLS_ASCII y
NLS_ISO8859_1 y
NLS_UTF8 y
DLM m
TRACE_IRQFLAGS_SUPPORT y
PRINTK_TIME y
DEBUG_INFO y
ENABLE_MUST_CHECK y
DEBUG_FS y
ARCH_WANT_FRAME_POINTERS y
FRAME_POINTER y
MAGIC_SYSRQ y
DEBUG_KERNEL y
HAVE_DEBUG_KMEMLEAK y
DEBUG_MEMORY_INIT y
HAVE_DEBUG_STACKOVERFLOW y
DEBUG_STACKOVERFLOW y
HAVE_ARCH_KMEMCHECK y
HAVE_ARCH_KASAN y
SCHED_INFO y
SCHEDSTATS y
TIMER_STATS y
STACKTRACE y
DEBUG_BUGVERBOSE y
ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS y
USER_STACKTRACE_SUPPORT y
NOP_TRACER y
HAVE_FUNCTION_TRACER y
HAVE_FUNCTION_GRAPH_TRACER y
HAVE_FUNCTION_GRAPH_FP_TEST y
HAVE_DYNAMIC_FTRACE y
HAVE_DYNAMIC_FTRACE_WITH_REGS y
HAVE_FTRACE_MCOUNT_RECORD y
HAVE_SYSCALL_TRACEPOINTS y
HAVE_FENTRY y
HAVE_C_RECORDMCOUNT y
TRACE_CLOCK y
RING_BUFFER y
EVENT_TRACING y
CONTEXT_SWITCH_TRACER y
TRACING y
GENERIC_TRACER y
TRACING_SUPPORT y
FTRACE y
BRANCH_PROFILE_NONE y
BLK_DEV_IO_TRACE y
KPROBE_EVENT y
PROBE_EVENTS y
PROVIDE_OHCI1394_DMA_INIT y
HAVE_ARCH_KGDB y
X86_VERBOSE_BOOTUP y
EARLY_PRINTK y
EARLY_PRINTK_DBGP y
DEBUG_RODATA y
DEBUG_NX_TEST m
DOUBLEFAULT y
HAVE_MMIOTRACE_SUPPORT y
IO_DELAY_0X80 y
DEBUG_BOOT_PARAMS y
OPTIMIZE_INLINING y
X86_DEBUG_FPU y
KEYS y
SECURITY y
SECURITY_NETWORK y
SECURITY_SELINUX y
SECURITY_SELINUX_BOOTPARAM y
SECURITY_SELINUX_DISABLE y
SECURITY_SELINUX_DEVELOP y
SECURITY_SELINUX_AVC_STATS y
INTEGRITY y
INTEGRITY_AUDIT y
DEFAULT_SECURITY_DAC y
XOR_BLOCKS y
ASYNC_CORE y
ASYNC_MEMCPY y
ASYNC_XOR y
ASYNC_PQ y
ASYNC_RAID6_RECOV y
CRYPTO y
CRYPTO_ALGAPI y
CRYPTO_ALGAPI2 y
CRYPTO_AEAD m
CRYPTO_AEAD2 y
CRYPTO_BLKCIPHER y
CRYPTO_BLKCIPHER2 y
CRYPTO_HASH y
CRYPTO_HASH2 y
CRYPTO_RNG m
CRYPTO_RNG2 y
CRYPTO_RNG_DEFAULT m
CRYPTO_PCOMP m
CRYPTO_PCOMP2 y
CRYPTO_AKCIPHER2 y
CRYPTO_MANAGER y
CRYPTO_MANAGER2 y
CRYPTO_USER y
CRYPTO_MANAGER_DISABLE_TESTS y
CRYPTO_GF128MUL y
CRYPTO_NULL m
CRYPTO_NULL2 y
CRYPTO_PCRYPT m
CRYPTO_WORKQUEUE y
CRYPTO_CRYPTD y
CRYPTO_AUTHENC m
CRYPTO_TEST m
CRYPTO_ABLK_HELPER y
CRYPTO_GLUE_HELPER_X86 y
CRYPTO_CCM m
CRYPTO_GCM m
CRYPTO_SEQIV m
CRYPTO_ECHAINIV m
CRYPTO_CBC y
CRYPTO_CTR m
CRYPTO_CTS m
CRYPTO_ECB m
CRYPTO_LRW y
CRYPTO_PCBC y
CRYPTO_XTS y
CRYPTO_CMAC m
CRYPTO_HMAC y
CRYPTO_XCBC m
CRYPTO_VMAC m
CRYPTO_CRC32C y
CRYPTO_CRC32C_INTEL m
CRYPTO_CRCT10DIF y
CRYPTO_GHASH m
CRYPTO_MD4 m
CRYPTO_MD5 y
CRYPTO_MICHAEL_MIC m
CRYPTO_RMD128 m
CRYPTO_RMD160 m
CRYPTO_RMD256 m
CRYPTO_RMD320 m
CRYPTO_SHA1 y
CRYPTO_SHA1_SSSE3 m
CRYPTO_SHA256 m
CRYPTO_SHA512 m
CRYPTO_TGR192 m
CRYPTO_WP512 m
CRYPTO_GHASH_CLMUL_NI_INTEL m
CRYPTO_AES y
CRYPTO_AES_X86_64 y
CRYPTO_AES_NI_INTEL y
CRYPTO_ANUBIS m
CRYPTO_ARC4 y
CRYPTO_BLOWFISH m
CRYPTO_BLOWFISH_COMMON m
CRYPTO_BLOWFISH_X86_64 m
CRYPTO_CAMELLIA m
CRYPTO_CAST_COMMON m
CRYPTO_CAST5 m
CRYPTO_CAST6 m
CRYPTO_DES y
CRYPTO_FCRYPT y
CRYPTO_KHAZAD m
CRYPTO_SALSA20 m
CRYPTO_SALSA20_X86_64 m
CRYPTO_SEED m
CRYPTO_SERPENT m
CRYPTO_TEA m
CRYPTO_TWOFISH m
CRYPTO_TWOFISH_COMMON y
CRYPTO_TWOFISH_X86_64 y
CRYPTO_TWOFISH_X86_64_3WAY m
CRYPTO_DEFLATE m
CRYPTO_ZLIB m
CRYPTO_LZO m
CRYPTO_ANSI_CPRNG m
CRYPTO_DRBG_MENU m
CRYPTO_DRBG_HMAC y
CRYPTO_DRBG m
CRYPTO_JITTERENTROPY m
CRYPTO_USER_API m
CRYPTO_USER_API_HASH m
CRYPTO_USER_API_SKCIPHER m
CRYPTO_HW y
HAVE_KVM y
KVM_COMPAT y
VIRTUALIZATION y
BINARY_PRINTF y
RAID6_PQ y
BITREVERSE y
RATIONAL y
GENERIC_STRNCPY_FROM_USER y
GENERIC_STRNLEN_USER y
GENERIC_NET_UTILS y
GENERIC_FIND_FIRST_BIT y
GENERIC_PCI_IOMAP y
GENERIC_IOMAP y
GENERIC_IO y
ARCH_USE_CMPXCHG_LOCKREF y
ARCH_HAS_FAST_MULTIPLIER y
CRC_CCITT m
CRC16 y
CRC_T10DIF y
CRC_ITU_T m
CRC32 y
CRC32_SLICEBY8 y
LIBCRC32C y
ZLIB_INFLATE y
ZLIB_DEFLATE y
LZO_COMPRESS y
LZO_DECOMPRESS y
LZ4_DECOMPRESS y
XZ_DEC y
XZ_DEC_X86 y
XZ_DEC_POWERPC y
XZ_DEC_IA64 y
XZ_DEC_ARM y
XZ_DEC_ARMTHUMB y
XZ_DEC_SPARC y
XZ_DEC_BCJ y
DECOMPRESS_GZIP y
DECOMPRESS_BZIP2 y
DECOMPRESS_LZMA y
DECOMPRESS_XZ y
DECOMPRESS_LZO y
DECOMPRESS_LZ4 y
GENERIC_ALLOCATOR y
TEXTSEARCH y
TEXTSEARCH_KMP m
TEXTSEARCH_BM m
TEXTSEARCH_FSM m
ASSOCIATIVE_ARRAY y
HAS_IOMEM y
HAS_IOPORT_MAP y
HAS_DMA y
CHECK_SIGNATURE y
CPU_RMAP y
DQL y
GLOB y
NLATTR y
ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE y
OID_REGISTRY y
UCS2_STRING y
ARCH_HAS_SG_CHAIN y
ARCH_HAS_PMEM_API y
ARCH_HAS_MMIO_FLUSH y
      '';
    };
  };
}
