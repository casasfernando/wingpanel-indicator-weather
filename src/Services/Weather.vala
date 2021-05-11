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
                debug ("wingpanel-indicator-weather: discovering current location");
                get_location.begin ();
            // Otherwise use the manually user selected location
            } else {
                debug ("wingpanel-indicator-weather: using manual location setting");
                location = GWeather.Location.get_world ();
                location = location.deserialize (settings.get_value ("location-manual"));
            }
            // Set current location
            weather_info = new GWeather.Info (location);
            // Update weather data
            debug ("wingpanel-indicator-weather: weather information update requested");
            settings.set_int64 ("weather-last-update-req", new DateTime.now_local ().to_unix ());
            weather_info.update ();
            // Process updated weather data
            weather_info.updated.connect ( () => {
                if (location == null) {
                    return;
                }
                debug ("wingpanel-indicator-weather: weather information updated");
                // Weather information last update
                settings.set_int64 ("weather-last-update", new DateTime.now_local ().to_unix ());
                // Location
                settings.set_string ("weather-location", dgettext ("libgweather-locations", location.get_city_name ()));
                // Weather icon
                settings.set_string ("weather-icon", weather_info.get_symbolic_icon_name ());
                // Weather conditions
                settings.set_string ("weather-conditions", dgettext ("libgweather", weather_info.get_conditions ()));
                // Sky conditions
                settings.set_string ("weather-sky", dgettext ("libgweather", weather_info.get_sky ()));
                // Temperature
                GWeather.TemperatureUnit utemp;
                string utempsym;
                switch (settings.get_int ("unit-temperature")) {
                    case 0:
                        utemp = GWeather.TemperatureUnit.CENTIGRADE;
                        utempsym = "°C";
                        break;
                    case 1:
                        utemp = GWeather.TemperatureUnit.FAHRENHEIT;
                        utempsym = "°F";
                        break;
                    default:
                        utemp = GWeather.TemperatureUnit.CENTIGRADE;
                        utempsym = "°C";
                        break;
                }
                double temp;
                if (weather_info.get_value_temp (utemp, out temp)) {
                    int t = (int) temp;
                    settings.set_string ("weather-temperature", "%s".printf (t.to_string ()).concat (utempsym));
                } else {
                    settings.set_string ("weather-temperature", "N/A");
                }
                // Feels Like
                double feel;
                if (weather_info.get_value_apparent (utemp, out feel)) {
                    int f = (int) feel;
                    settings.set_string ("weather-feel", "%s".printf (f.to_string ()).concat (utempsym));
                } else {
                    settings.set_string ("weather-feel", "N/A");
                }
                // Wind
                GWeather.SpeedUnit uspeed;
                string uspeedsym;
                switch (settings.get_int ("unit-speed")) {
                    case 0:
                        uspeed = GWeather.SpeedUnit.BFT;
                        uspeedsym = "bft";
                        break;
                    case 1:
                        uspeed = GWeather.SpeedUnit.KPH;
                        uspeedsym = "km/h";
                        break;
                    case 2:
                        uspeed = GWeather.SpeedUnit.KNOTS;
                        uspeedsym = "knots";
                        break;
                    case 3:
                        uspeed = GWeather.SpeedUnit.MS;
                        uspeedsym = "m/s";
                        break;
                    case 4:
                        uspeed = GWeather.SpeedUnit.MPH;
                        uspeedsym = "mph";
                        break;
                    default:
                        uspeed = GWeather.SpeedUnit.KPH;
                        uspeedsym = "km/h";
                        break;
                }
                double wspd;
                GWeather.WindDirection wdir;
                if (weather_info.get_value_wind (uspeed, out wspd, out wdir)) {
                    int ws = (int) wspd;
                    string wdirstr;
                    switch (wdir) {
                        case E:
                            wdirstr = "E";
                            break;
                        case ENE:
                            wdirstr = "ENE";
                            break;
                        case ESE:
                            wdirstr = "ESE";
                            break;
                        case N:
                            wdirstr = "N";
                            break;
                        case NE:
                            wdirstr = "NE";
                            break;
                        case NNE:
                            wdirstr = "NNE";
                            break;
                        case NNW:
                            wdirstr = "NNW";
                            break;
                        case NW:
                            wdirstr = "NW";
                            break;
                        case S:
                            wdirstr = "S";
                            break;
                        case SE:
                            wdirstr = "SE";
                            break;
                        case SSE:
                            wdirstr = "SSE";
                            break;
                        case SSW:
                            wdirstr = "SSW";
                            break;
                        case SW:
                            wdirstr = "SW";
                            break;
                        case VARIABLE:
                            wdirstr = "Variable";
                            break;
                        case W:
                            wdirstr = "W";
                            break;
                        case WNW:
                            wdirstr = "WNW";
                            break;
                        case WSW:
                            wdirstr = "WSW";
                            break;
                        default:
                            wdirstr = "N/A";
                            break;
                    }
                    settings.set_string ("weather-wind", "%s".printf (wdirstr.concat (" ", ws.to_string (), " ", uspeedsym)));
                } else {
                    settings.set_string ("weather-wind", "N/A");
                }
                // Humidity
                settings.set_string ("weather-humidity", dgettext ("libgweather", weather_info.get_humidity ()));
                // Dew Point
                double dew;
                if (weather_info.get_value_dew (utemp, out dew)) {
                    int d = (int) dew;
                    settings.set_string ("weather-dew", "%s".printf (d.to_string ()).concat (utempsym));
                } else {
                    settings.set_string ("weather-dew", "N/A");
                }
                // Pressure
                GWeather.PressureUnit upress;
                string upresssym;
                switch (settings.get_int ("unit-pressure")) {
                    case 0:
                        upress = GWeather.PressureUnit.HPA;
                        upresssym = "hPa";
                        break;
                    case 1:
                        upress = GWeather.PressureUnit.INCH_HG;
                        upresssym = "inHg";
                        break;
                    case 2:
                        upress = GWeather.PressureUnit.MB;
                        upresssym = "mbar";
                        break;
                    case 3:
                        upress = GWeather.PressureUnit.MM_HG;
                        upresssym = "mmHg";
                        break;
                    default:
                        upress = GWeather.PressureUnit.MB;
                        upresssym = "mbar";
                        break;
                }
                double press;
                if (weather_info.get_value_pressure (upress, out press)) {
                    int p = (int) press;
                    settings.set_string ("weather-pressure", "%s".printf (p.to_string ()).concat(" ", upresssym));
                } else {
                    settings.set_string ("weather-pressure", "N/A");
                }
                // Visibility
                GWeather.DistanceUnit udist;
                string udistsym;
                switch (settings.get_int ("unit-distance")) {
                    case 0:
                        udist = GWeather.TemperatureUnit.KM;
                        udistsym = "km";
                        break;
                    case 1:
                        udist = GWeather.TemperatureUnit.MILES;
                        udistsym = "mi";
                        break;
                    default:
                        udist = GWeather.TemperatureUnit.KM;
                        udistsym = "km";
                        break;
                }
                double dist;
                if (weather_info.get_value_visibility (udist, out dist)) {
                    int di = (int) dist;
                    settings.set_string ("weather-visibility", "%s".printf (di.to_string ()).concat (" ", udistsym));
                } else {
                    settings.set_string ("weather-visibility", "N/A");
                }
                // Sunrise / Sunset
                string tformat;
                if (settings.get_int ("time-format") == 0) {
                    tformat = "%l:%M %p";
                } else {
                    tformat = "%R";
                }
                // Sunrise
                ulong srte;
                if (weather_info.get_value_sunrise(out srte)) {
                    var srtl = new DateTime.from_unix_local (srte);
                    settings.set_string ("weather-sunrise", "%s".printf (srtl.format (tformat)));
                } else {
                    settings.set_string ("weather-sunrise", "N/A");
                }
                // Sunset
                ulong sste;
                if (weather_info.get_value_sunset(out sste)) {
                    var sstl = new DateTime.from_unix_local (sste);
                    settings.set_string ("weather-sunset", "%s".printf (sstl.format (tformat)));
                } else {
                    settings.set_string ("weather-sunset", "N/A");
                }
                // Moon Phase
                double mp;
                double lat;
                if (weather_info.get_value_moonphase (out mp, out lat)) {
                    if (mp < 22.5 | mp > 337.5) { settings.set_string ("weather-moon-phase", "New moon"); settings.set_string ("weather-moon-phase-icon", "new-moon"); }
                    else if (mp > 22.5 & mp < 67.5) { settings.set_string ("weather-moon-phase", "Waxing crescent"); settings.set_string ("weather-moon-phase-icon", "waxing-crescent-moon"); }
                    else if (mp > 67.5 & mp < 112.5) { settings.set_string ("weather-moon-phase", "First quarter"); settings.set_string ("weather-moon-phase-icon", "first-quarter-moon"); }
                    else if (mp > 112.5 & mp < 157.5) { settings.set_string ("weather-moon-phase", "Waxing gibbous"); settings.set_string ("weather-moon-phase-icon", "waxing-gibbous-moon"); }
                    else if (mp > 157.5 & mp < 202.5) { settings.set_string ("weather-moon-phase", "Full moon"); settings.set_string ("weather-moon-phase-icon", "full-moon"); }
                    else if (mp > 202.5 & mp < 247.5) { settings.set_string ("weather-moon-phase", "Waning gibbous"); settings.set_string ("weather-moon-phase-icon", "waning-gibbous-moon"); }
                    else if (mp > 247.5 & mp < 292.5) { settings.set_string ("weather-moon-phase", "Third quarter"); settings.set_string ("weather-moon-phase-icon", "third-quarter-moon"); }
                    else if (mp > 292.5 & mp < 337.5) { settings.set_string ("weather-moon-phase", "Waning crescent"); settings.set_string ("weather-moon-phase-icon", "waning-crescent-moon"); }
                    else { settings.set_string ("weather-moon-phase", "N/A"); settings.set_string ("weather-moon-phase-icon", "full-moon"); }
                    //info("wingpanel-indicator-weather: current phase of the moon in degrees: ".concat ("%s".printf (mp.to_string ())));
                } else {
                    settings.set_string ("weather-moon-phase", "N/A");
                    settings.set_string ("weather-moon-phase-icon", "full-moon"); 
                }

            });

            return true;

        }

        public static async void get_location () {
            // Discover current location using GeoClue
            debug ("wingpanel-indicator-weather: location discovery started");
            try {
                var simple = yield new GClue.Simple (
                    "com.github.casasfernando.wingpanel-indicator-weather", GClue.AccuracyLevel.CITY, null
                    );

                simple.notify["location"].connect (() => {
                    debug ("wingpanel-indicator-weather: location discovery completed (notify)");
                    on_location_updated (simple.location.latitude, simple.location.longitude);
                });

                debug ("wingpanel-indicator-weather: location discovery completed");
                on_location_updated (simple.location.latitude, simple.location.longitude);

            } catch (Error e) {
                warning ("wingpanel-indicator-weather: failed to connect to GeoClue2 service: %s", e.message);
                return;
            }
        }

        public static void on_location_updated (double latitude, double longitude) {
            // Change current location to the discovered one
            debug ("wingpanel-indicator-weather: updating current location");
            location = GWeather.Location.get_world ();
            location = location.find_nearest_city (latitude, longitude);
            if (location != null) {
                weather_info.location = location;
                debug ("wingpanel-indicator-weather: weather information update requested on discovered location change (automatic)");
                weather_info.update ();
            }
        }

    }
}
