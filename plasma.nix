{
  programs.plasma = {
    enable = true;
    input.keyboard = {
      repeatDelay = 300;
      repeatRate = 25;
    };

    input.mice = [
      {
        name = "Logitech MX Ergo";
        vendorId = "046d";
        productId = "406f";
        acceleration = 0.40;
        accelerationProfile = "none";
      }
    ];

    # Keep the logged-in Plasma session available to KRDP. Manual locking still
    # works, but inactivity and sleep/resume do not automatically lock it.
    kscreenlocker = {
      autoLock = false;
      lockOnResume = false;
    };

    # Keep this remote-access workstation awake on AC power while allowing the
    # display to turn off after 15 idle minutes.
    powerdevil.AC = {
      autoSuspend.action = "nothing";
      turnOffDisplay.idleTimeout = 900;
      dimDisplay.enable = false;
    };
  };
}
