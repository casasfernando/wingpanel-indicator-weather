/*-
 * Copyright (c) 2018 Tudor Plugaru (https://github.com/PlugaruT/wingpanel-indicator-sys-monitor)
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
                double press;
                weather_info.get_value_pressure (GWeather.PressureUnit.MB, out press);
                int p = (int) press;
                settings.set_string ("weather-pressure", "%s".printf (p.to_string ()));
                //settings.set_string ("weather-pressure", dgettext ("libgweather", weather_info.get_pressure ()));
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
                int m = (int) mp;
                if (m < 45) { settings.set_string ("weather-moonphase", "New Moon"); }
                else if (m < 90) { settings.set_string ("weather-moonphase", "Waxing Crescent"); }
                else if (m < 135) { settings.set_string ("weather-moonphase", "1st Quarter Moon"); }
                else if (m < 180) { settings.set_string ("weather-moonphase", "Waxing Gibbous"); }
                else if (m < 225) { settings.set_string ("weather-moonphase", "Full Moon"); }
                else if (m < 270) { settings.set_string ("weather-moonphase", "Waning Gibbous"); }
                else if (m < 315) { settings.set_string ("weather-moonphase", "3rd Quarter"); }
                else if (m < 360) { settings.set_string ("weather-moonphase", "Waning Crescent"); }
                else { settings.set_string ("weather-moonphase", "N/A"); }
                //settings.set_string ("weather-moonphase", "%s°".printf (m.to_string ()));
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
