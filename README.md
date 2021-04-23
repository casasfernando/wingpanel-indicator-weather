<p align="center">
  <img src="data/icons/128/com.github.casasfernando.wingpanel-indicator-weather.svg" alt="Icon" />
</p>
<h1 align="center">Wingpanel Weather</h1>

### Indicator
![Screenshot](data/screenshot_1.png)
### Tooltip:
![Screenshot](data/screenshot_2.png)
### Popover (minimal view):
![Screenshot](data/screenshot_6.png)
### Popover (full view):
![Screenshot](data/screenshot_3.png)
![Screenshot](data/screenshot_4.png)
### Settings:
![Screenshot](data/screenshot_5.png)

## Building and Installation

You'll need the following dependencies:

```
libglib2.0-dev
libgranite-dev
libgtk-3-dev
libwingpanel-2.0-dev
libgeoclue-2-dev
libgweather-3-dev
libnotify-dev
meson
valac
```

You can install them running:

```
sudo apt install libgranite-dev libgtk-3-dev libwingpanel-2.0-dev meson valac libgeoclue-2-dev libgweather-3-dev libnotify-dev
```

Run `meson` to configure the build environment and then `ninja` to build

```
meson build --prefix=/usr
cd build
ninja
```

To install, use `ninja install`

```
sudo ninja install
com.github.casasfernando.wingpanel-indicator-weather
```

## Special thanks and credits
 - [Plugaru T.](https://github.com/PlugaruT/) for developing the [original project](https://github.com/PlugaruT/wingpanel-monitor).
 - Application [icon](http://iynque.deviantart.com/art/iOS-7-Icons-Updated-378969049) by [iynque (Andrew Williams)](https://www.deviantart.com/iynque)
