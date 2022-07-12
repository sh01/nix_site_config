{pkgs, ...}:

# /etc/asound.conf for forwarding to pulseaudio.
# This is copied from modules.config.pulseaudio; we can't get that one without the full pulse package, which we don't need here.
let
  inherit (pkgs) alsaPlugins;
  alsaPlugins32 = pkgs.pkgsi686Linux.alsaPlugins;
  alsaConf = pkgs.writeText "asound.conf" ''
    pcm_type.pulse {
      libs.native = ${alsaPlugins}/lib/alsa-lib/libasound_module_pcm_pulse.so
      libs.32Bit = ${alsaPlugins32}/lib/alsa-lib/libasound_module_pcm_pulse.so
    }
    pcm.!default {
      type pulse
      hint.description "Default Audio Device (via PulseAudio)"
    }
    ctl_type.pulse {
      libs.native = ${alsaPlugins}/lib/alsa-lib/libasound_module_ctl_pulse.so
      libs.32Bit = ${alsaPlugins32}/lib/alsa-lib/libasound_module_ctl_pulse.so
    }
    ctl.!default {
      type pulse
    }
  '';
in {
  environment.etc = {
    "asound.conf" = {
      source = alsaConf;
    };
  };
}
