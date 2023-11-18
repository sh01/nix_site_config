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
      # Tests borked as of 23.05
      python = prev.python3Packages.overrideScope' (pf: pp: {
        pygame-gui = pf.pygame-gui.overridePythonAttrs (old: { doCheck = false; });
      });
    })
  ];
}
