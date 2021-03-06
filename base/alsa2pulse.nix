{pkgs, pkgs_i686, ...}:

# /etc/asound.conf for forwarding to pulseaudio.
# This is copied from modules.config.pulseaudio; we can't get that one without the full pulse package, which we don't need here.
let
  inherit (pkgs) alsaPlugins;
  alsaPlugins32 = pkgs_i686.alsaPlugins;
  alsaConf = pkgs.writeText "asound.conf" ''
    pcm_type.pulse {
      lib ${alsaPlugins}/lib/alsa-lib/libasound_module_pcm_pulse.so
      lib ${alsaPlugins32}/lib/alsa-lib/libasound_module_pcm_pulse.so
    }
    pcm.!default {
      type pulse
      hint.description "Default Audio Device (via PulseAudio)"
    }
    ctl_type.pulse {
      lib ${alsaPlugins}/lib/alsa-lib/libasound_module_ctl_pulse.so
      lib ${alsaPlugins32}/lib/alsa-lib/libasound_module_ctl_pulse.so
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
