# Gamepad configuration
{...}: {
  services.udev.extraRules = ''
SUBSYSTEM=="usb", ACTION=="add", ATTR{product}=="Controller", GROUP="game_pad"
KERNEL=="uinput", GROUP="game_pad", MODE="660"
'';
}
