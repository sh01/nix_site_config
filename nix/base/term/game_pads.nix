# Gamepad configuration
{...}: {
  services.udev.extraRules = ''
SUBSYSTEM=="usb", ACTION=="add", ATTR{product}=="Controller", GROUP="game_pad"
SUBSYSTEM=="input", ATTRS{product}=="Controller", GROUP="input_game"
KERNEL=="uinput", GROUP="game_pad", MODE="660"
'';
}
