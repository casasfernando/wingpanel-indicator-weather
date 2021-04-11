/*-
 * Copyright (c) 2020 Tudor Plugaru (https://github.com/PlugaruT/wingpanel-monitor)
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
    public class MainWindow : Gtk.Window {
        private GLib.Settings settings;
        private GWeather.Location location;
        private GWeather.Info weather_info;

        public MainWindow (Gtk.Application application) {
            Object (
                application: application,
                border_width: 1,
                icon_name: "com.github.casasfernando.wingpanel-indicator-weather",
                resizable: false, title: "Wingpanel Weather",
                window_position: Gtk.WindowPosition.CENTER,
                default_width: 300
                );
        }

        construct {
            settings = new GLib.Settings ("com.github.casasfernando.wingpanel-indicator-weather");
            var toggles = new TogglesWidget (settings);

            get_location.begin ();

            weather_info = new GWeather.Info (location);

            var refresh_btn = new Gtk.Button.from_icon_name ("view-refresh-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            refresh_btn.tooltip_text = "Refresh weather";
            refresh_btn.clicked.connect ( () => {
                weather_info.update ();
            });

            var layout = new Gtk.Grid ();
            layout.hexpand = true;
            layout.margin = 10;
            layout.column_spacing = 6;
            layout.row_spacing = 10;

            layout.attach (toggles, 0, 1, 1, 1);

            var header = new Gtk.HeaderBar ();
            header.show_close_button = true;
            header.pack_end (refresh_btn);

            var header_context = header.get_style_context ();
            header_context.add_class ("titlebar");
            header_context.add_class ("default-decoration");
            header_context.add_class (Gtk.STYLE_CLASS_FLAT);

            set_titlebar (header);
            add (layout);

            focus_in_event.connect (() => {
                weather_info.update ();
            });

            settings.changed["weather-refresh"].connect ( () =>{
                info ("Settings: Refreshing weather information");
                weather_info.update ();
            });

            weather_info.updated.connect ( () => {
                if (location == null) {
                    return;
                }
                info ("Winpanel Weather: weather information updated");
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

            });

        }

        public async void get_location () {
            try {
                var simple = yield new GClue.Simple (
                    "com.github.casasfernando.wingpanel-indicator-weather", GClue.AccuracyLevel.CITY, null
                    );

                simple.notify["location"].connect (() => {
                    on_location_updated (simple.location.latitude, simple.location.longitude);
                });

                on_location_updated (simple.location.latitude, simple.location.longitude);
            } catch (Error e) {
                warning ("Failed to connect to GeoClue2 service: %s", e.message);
                return;
            }
        }

        public void on_location_updated (double latitude, double longitude) {
            location = GWeather.Location.get_world ();
            location = location.find_nearest_city (latitude, longitude);
            if (location != null) {
                weather_info.location = location;
                weather_info.update ();
            }
        }

    }
}
