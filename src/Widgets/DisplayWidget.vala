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
    public class DisplayWidget : Gtk.Grid {
        private IndicatorWidget weather_info;

        public unowned Settings settings { get; construct set; }

        public DisplayWidget (Settings settings) {
            Object (settings: settings);
        }

        construct {

            // Update weather information on load
            info ("wingpanel-indicator-weather: weather information update requested by the indicator on startup (automatic)");
            WingpanelWeather.Weather.weather_data_update();

            valign = Gtk.Align.CENTER;

            weather_info = new IndicatorWidget ("weather-clear-symbolic", 4);
            weather_info.tooltip_text = "%s in %s".printf (
                settings.get_string ("weather-details"), settings.get_string ("weather-location")
                );

            add (weather_info);

        }

        public void update_weather () {
            weather_info.label_value = settings.get_string ("weather-temperature");
            weather_info.new_icon = settings.get_string ("weather-icon");
            weather_info.show_temp = settings.get_boolean ("display-temperature");
            string location = settings.get_string ("weather-location");
            string details = settings.get_string ("weather-details");
            weather_info.tooltip_text = "%s in %s".printf (details, location);
        }
    }
}
