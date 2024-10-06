{...}: {
  services.prometheus.exporters = {
    node = {
      enable = true;
      port = 9100;
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
    };
    smartctl = {
      port = 9101;
      enable = true;
      devices = ["/dev/nvme0n1" "/dev/nvme1n1"];
      maxInterval = "5m";
    };
  };
  l.ext_ports_t = ["9100-9101"];
}
