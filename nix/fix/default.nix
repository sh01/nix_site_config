{ ... }:
let
  pyfix = {
    packageOverrides = pf: pp: {
      # Tests borked as of 23.05
      pygame-gui = pf.pygame-gui.overridePythonAttrs (old: { doCheck = false; });
    };
  };
in {
  nixpkgs.overlays = [
    (final: prev: {
      # Tests borked as of 24.05
      prometheus = prev.prometheus.overrideAttrs (old: { doCheck = false; });
    })
  ];
  nixpkgs.config.packageOverrides = super: {
    # Prometheus fixes
    #python27 = super.python27.override {
      #packageOverrides = python-self: python-super: {
        #pyopenssl = python-super.pyopenssl.overridePythonAttrs (old: { doCheck = false;} );
      #};
    #};
    prometheus_2 = super.prometheus_2.overrideAttrs (old: { doCheck = false; });
  };
}
