{ fetchurl, ... }: {
  nixpkgs.overlays = [
    (final: prev: {
      xmage = prev.xmage.overrideAttrs ( old: {
        src = fetchurl {
          url = "https://github.com/magefree/mage/releases/download/xmage_1.4.53V1/mage-full_1.4.53-dev_2024-08-16_15-45.zip";
          sha256 = "sha256-OJ7sPLOKLiD7w9JNOniTXSyTQ06SIBRBzzS8ff/dAgw=";
        };        
      });
    })
  ];
}
