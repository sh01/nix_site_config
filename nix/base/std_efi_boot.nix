{pkgs, structuredExtraConfig, ...}: {
  boot = {
    kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ./default_kernel.nix {inherit structuredExtraConfig;});
    blacklistedKernelModules = ["snd" "rfkill" "fjes" "8250_fintek" "eeepc_wmi" "autofs4" "psmouse"] ++ ["firewire_ohci" "firewire_core" "firewire_sbp2"];
    initrd = {
      luks.devices = {
        "root" = {
          preLVM = true;
          fallbackToPassword = true;
          allowDiscards = true;
          keyFileSize = 64;
        };
      };
      preFailCommands = ''${pkgs.bash}/bin/bash'';
      supportedFilesystems = ["btrfs"];
    };

    loader.efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };

    loader.grub = {
      enable = true;
      copyKernels = true;
      device = "nodev";
      # memtest86.enable = true;
      splashImage = null;

      efiSupport = true;
      #efiInstallAsRemovable = true;
    };
  };

  fileSystems."/" = {
    label = "root";
    fsType = "btrfs";
    options = ["noatime" "nodiratime" "space_cache" "autodefrag"];
  };
}
