{...}: {
  services.xserver.videoDrivers = ["nvidia"];

  hardware = {
    graphics.enable = true;
    nvidia.modesetting.enable = true;
    nvidia.open = true;
    nvidia.nvidiaSettings = true;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    GBM_BACKEND = "nvidia_drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    OZONE_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
  };

  # Fix NVIDIA VRAM memory leak in niri
  # https://github.com/niri-wm/niri/wiki/Nvidia
  environment.etc."nvidia/nvidia-application-profiles-rc.d/50-niri-vram-fix.json".text = ''
    {
      "rules": [
        {
          "pattern": {
            "feature": "procname",
            "matches": "niri"
          },
          "profile": "Limit Free Buffer Pool On Wayland Compositors"
        }
      ],
      "profiles": [
        {
          "name": "Limit Free Buffer Pool On Wayland Compositors",
          "settings": [
            {
              "key": "GLVidHeapReuseRatio",
              "value": 0
            }
          ]
        }
      ]
    }
  '';
}
