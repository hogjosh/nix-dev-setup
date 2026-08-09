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
  };
}
