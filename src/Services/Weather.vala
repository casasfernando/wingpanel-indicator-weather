/*-
 * Copyright (c) 2018 Tudor Plugaru (https://github.com/PlugaruT/wingpanel-indicator-sys-monitor)
 * Copyright (c) 2021 Fernando Casas Schössow (https://github.com/casasfernando/wingpanel-indicator-weather)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA.
 *
 * Authored by: Tudor Plugaru <plugaru.tudor@gmail.com>
 *              Fernando Casas Schössow <casasfernando@outlook.com>
 */

namespace WingpanelWeather {
    public class Weather : GLib.Object {
        private static GLib.Settings settings;
        private static GWeather.Location location;
        private static GWeather.Info weather_info;

        public static bool weather_data_update () {
            settings = new GLib.Settings ("com.github.casasfernando.wingpanel-indicator-weather");

            // Discover current location if location discovery is enabled
            if (settings.get_boolean ("location-auto")) {
                info ("wingpanel-indicator-weather: discovering current location");
                get_location.begin ();
            // Otherwise use the manually user selected location
            } else {
                info ("wingpanel-indicator-weather: using manual location setting");
                location = GWeather.Location.get_world ();
                location = location.deserialize (settings.get_value ("location-manual"));
            }
            // Set current location
            weather_info = new GWeather.Info (location);
            // Update weather data
            info ("wingpanel-indicator-weather: weather information update requested");
            weather_info.update ();
            // Process updated weather data
            weather_info.updated.connect ( () => {
                if (location == null) {
                    return;
                }
                info ("wingpanel-indicator-weather: weather information updated");
                // Weather icon
                settings.set_string ("weather-icon", weather_info.get_symbolic_icon_name ());
                // Location
                settings.set_string ("weather-location", dgettext ("libgweather-locations", location.get_city_name ()));
                // Temperature
                double temp;
                weather_info.get_value_temp (GWeather.TemperatureUnit.DEFAULT, out temp);
                int t = (int) temp;
                settings.set_string ("weather-temperature", "%s°".printf (t.to_string ()));
                // Pressure
                /*
                double press;
                weather_info.get_value_pressure (GWeather.PressureUnit.MB, out press);
                int p = (int) press;
                settings.set_string ("weather-pressure", "%s".printf (p.to_string ()));
                */
                settings.set_string ("weather-pressure", dgettext ("libgweather", weather_info.get_pressure ()));
                // Humidity
                settings.set_string ("weather-humidity", dgettext ("libgweather", weather_info.get_humidity ()));
                // Feels Like
                double feel;
                weather_info.get_value_apparent (GWeather.TemperatureUnit.DEFAULT, out feel);
                int f = (int) feel;
                settings.set_string ("weather-feel", "%s°".printf (f.to_string ()));
                // Dew Point
                double dew;
                weather_info.get_value_dew (GWeather.TemperatureUnit.DEFAULT, out dew);
                int d = (int) dew;
                settings.set_string ("weather-dew", "%s°".printf (d.to_string ()));
                // Wind
                settings.set_string ("weather-wind", dgettext ("libgweather", weather_info.get_wind ()));
                // Details
                settings.set_string ("weather-details", dgettext ("libgweather", weather_info.get_sky ()));
                // Sunrise
                settings.set_string ("weather-sunrise", dgettext ("libgweather", weather_info.get_sunrise ()));
                // Sunset
                settings.set_string ("weather-sunset", dgettext ("libgweather", weather_info.get_sunset ()));
                // Moon Phase
                double mp;
                double lat;
                weather_info.get_value_moonphase (out mp, out lat);
                if (mp < 22.5 | mp > 337.5) { settings.set_string ("weather-moon-phase", "New Moon"); settings.set_string ("weather-moon-phase-icon", "new-moon"); }
                else if (mp > 22.5 & mp < 67.5) { settings.set_string ("weather-moon-phase", "Waxing Crescent"); settings.set_string ("weather-moon-phase-icon", "waxing-crescent-moon"); }
                else if (mp > 67.5 & mp < 112.5) { settings.set_string ("weather-moon-phase", "1st Quarter"); settings.set_string ("weather-moon-phase-icon", "first-quarter-moon"); }
                else if (mp > 112.5 & mp < 157.5) { settings.set_string ("weather-moon-phase", "Waxing Gibbous"); settings.set_string ("weather-moon-phase-icon", "waxing-gibbous-moon"); }
                else if (mp > 157.5 & mp < 202.5) { settings.set_string ("weather-moon-phase", "Full Moon"); settings.set_string ("weather-moon-phase-icon", "full-moon"); }
                else if (mp > 202.5 & mp < 247.5) { settings.set_string ("weather-moon-phase", "Waning Gibbous"); settings.set_string ("weather-moon-phase-icon", "waning-gibbous-moon"); }
                else if (mp > 247.5 & mp < 292.5) { settings.set_string ("weather-moon-phase", "3rd Quarter"); settings.set_string ("weather-moon-phase-icon", "third-quarter-moon"); }
                else if (mp > 292.5 & mp < 337.5) { settings.set_string ("weather-moon-phase", "Waning Crescent"); settings.set_string ("weather-moon-phase-icon", "waning-crescent-moon"); }
                else { settings.set_string ("weather-moon-phase", "N/A"); settings.set_string ("weather-moon-phase-icon", "full-moon"); }
                //info("wingpanel-indicator-weather: current phase of the moon in degrees: ".concat ("%s".printf (mp.to_string ())));
                // Weather information last update
                var lupd = new DateTime.now_local ();
                settings.set_string ("weather-last-update", "%s".printf (lupd.format ("%Y-%m-%d %R")));

            });

            return true;

        }

        public static async void get_location () {
            // Discover current location using GeoClue
            info ("wingpanel-indicator-weather: location discovery started");
            try {
                var simple = yield new GClue.Simple (
                    "com.github.casasfernando.wingpanel-indicator-weather", GClue.AccuracyLevel.CITY, null
                    );

                simple.notify["location"].connect (() => {
                    info ("wingpanel-indicator-weather: location discovery completed (notify)");
                    on_location_updated (simple.location.latitude, simple.location.longitude);
                });

                info ("wingpanel-indicator-weather: location discovery completed");
                on_location_updated (simple.location.latitude, simple.location.longitude);

            } catch (Error e) {
                warning ("wingpanel-indicator-weather: failed to connect to GeoClue2 service: %s", e.message);
                return;
            }
        }

        public static void on_location_updated (double latitude, double longitude) {
            // Change current location to the discovered one
            info ("wingpanel-indicator-weather: updating current location");
            location = GWeather.Location.get_world ();
            location = location.find_nearest_city (latitude, longitude);
            if (location != null) {
                weather_info.location = location;
                info ("wingpanel-indicator-weather: weather information update requested on discovered location change (automatic)");
                weather_info.update ();
            }
        }

    }
}
