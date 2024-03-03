let
  optDef = r: [
    {name = "routers"; data = "10.17." + r + ".1";}
    {name = "domain-name-servers"; data = "10.17." + r + ".1";}
  ];
  optSearch = [
    {name = "domain-search"; data = "x.s., s.";}
  ];
  R = hw: ip: hn: {"hostname" = hn; "hw-address" = hw; "ip-address" = ip;};
  Re = h: i: (R ("06:ff:ff:80:00:" + h) ("10.17.8." + i) ("snode-" + i));
in {
    "renew-timer" = 3600;
    "valid-lifetime" = 4194304;
    "control-socket" = {
      "socket-name" = "/run/kea/ctrl.sock";
      "socket-type" = "unix";
    };
    "interfaces-config" = {
      "dhcp-socket-type" = "raw";
      "interfaces" = [ "eth_l_wired/10.17.1.1" "eth_l_wifi" "eth_l_wifi_g" ];
    };
    "lease-database" = {
      type = "memfile";
      persist = true;
      name = "/var/lib/kea/dhcp4.leases";
      "lfc-interval" = 8192;
    };
    "shared-networks" = [
      {
        name = "lan0";
        interface = "eth_l_wired";

        subnet4 = [
          {
            id = 1;
            subnet = "10.17.1.0/24";
            interface = "eth_l_wired";
            pools = [{"pool" = "10.17.1.128-10.17.1.254";}];
            "option-data" = (optDef "1") ++ optSearch;
            reservations = [
              (R "3c:ec:ef:42:b4:05" "10.17.1.4"  "sh_uiharu")
              (R "48:2a:e3:92:f8:81" "10.17.1.32" "sh_allison")
              (R "88:ae:dd:0d:0a:17" "10.17.1.67" "ilzo_aeonium")
              
              (R "3c:2a:f4:db:57:a5" "10.17.1.64" "misc_print0")
              (R "dc:a6:32:5c:44:b1" "10.17.1.66" "misc_3dprint0")
            ];
          } {
            id = 2;
            subnet = "10.17.8.0/24";
            interface = "eth_l_wired";
            pools = [{pool = "10.17.8.0-10.17.8.254";}];
            reservations = [
              (Re "01" "1")
              (Re "02" "2")
              (Re "03" "3")
              (Re "04" "4")
              (Re "05" "5")
              (Re "06" "6")
              (Re "07" "7")
            ];
          }
        ];
      }
    ];
    
    subnet4 = [
      {
        id = 3;
        subnet = "10.17.2.0/24";
        interface = "eth_l_wifi";
        pools = [{pool = "10.17.2.16-10.17.2.254";}];
        "option-data" = (optDef "2") ++ optSearch;
        reservations = [
          (R "68:54:5a:96:24:d1" "10.17.2.65" "ilzo_euphorbia")
          (R "ec:63:d7:aa:74:c2" "10.17.2.66" "sl_wingsofthought")
          
          (R "28:3a:4d:50:1a:67" "10.17.2.13" "misc_print1")
          (R "8c:0e:60:03:0f:00" "10.17.2.3"  "ap_1")

          # 74:f9:ca:ed:c1:33 switch
          # 88:54:1f:34:de:f8 sh-an
          # f4:f5:e8:5a:09:64 ccast
        ];
      } {
        id = 4;
        subnet = "10.17.3.0/24";
        interface = "eth_l_wifi_g";
        pools = [{pool = "10.17.3.16-10.17.3.254";}];
        "option-data" = (optDef "3");
	    }
  ];
}



