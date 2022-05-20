{
    enable = true;
    disabledCollectors = [
      "arp"
      "bcache"
      "btrfs"
      "bonding"
      "buddyinfo"
      "entropy"
      "filefd"
      "hwmon"
      "interrupts"
      "ipvs"
      "mdadm"
      "nfs"
      "nfsd"
      "textfile"
      "uname"
      "time"
      "xfs"
      "zfs"
    ];
    enabledCollectors = [];
    extraFlags = [
      "--collector.netstat.fields=Ip(6|Ext)_(InOctets|OutOctets)"
      "--collector.filesystem.ignored-fs-types=^(autofs|binfmt_misc|cgroup|configfs|debugfs|devpts|devtmpfs|fusectl|hugetlbfs|mqueue|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|sysfs|tracefs|ramfs|tmpfs)$"
    ];
}
