/*-
 * Copyright (c) 2020 Tudor Plugaru (https://github.com/PlugaruT/wingpanel-monitor)
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
    public class DisplayWidget : Gtk.Grid {
        private IndicatorWidget weather_info;
        public string conditions;
        public string prevcond;
        public string nbody;

        public unowned Settings settings { get; construct set; }

        public DisplayWidget (Settings settings) {
            Object (settings: settings);
        }

        construct {

            prevcond = "-";

            valign = Gtk.Align.CENTER;

            weather_info = new IndicatorWidget ("weather-clear-symbolic", 4);
            weather_info.tooltip_text = "%s in %s".printf (_("Clear sky"), settings.get_string ("weather-location"));

            add (weather_info);

            // Update weather information on load
            debug ("wingpanel-indicator-weather: weather information update requested by the indicator on startup (automatic)");
            WingpanelWeather.Weather.weather_data_update();

        }

        public void update_weather () {

            // Request weather data update if coming back from hibernation/suspend state
            if ((new DateTime.now_local ().to_unix() - settings.get_int64 ("weather-last-update-req")) > ((settings.get_int ("weather-update-rate") * 60) + 10)) {
                debug ("wingpanel-indicator-weather: weather information update requested by the indicator: resuming from hibernation/suspend state (automatic)");
                WingpanelWeather.Weather.weather_data_update();
            }

            weather_info.label_value = settings.get_string ("weather-temperature");
            weather_info.new_icon = settings.get_string ("weather-icon");
            weather_info.show_temp = settings.get_boolean ("display-temperature");
            conditions = settings.get_string ("weather-conditions");
            if (prevcond != conditions) {
                prevcond = conditions;
                if (conditions == "-") {
                    conditions = settings.get_string ("weather-sky");
                }
                if (settings.get_boolean ("display-notifications")) {
                    nbody = _("%s in %s\nTemperature: %s\nFeels like: %s\nWind: %s\nHumidity: %s").printf (conditions, settings.get_string ("weather-location"), settings.get_string ("weather-temperature"), settings.get_string ("weather-feel"), settings.get_string ("weather-wind"), settings.get_string ("weather-humidity"));
                    weather_conditions_change_notify (nbody);
                }
            } else if (conditions == "-") {
                conditions = settings.get_string ("weather-sky");
            }
            weather_info.tooltip_text = _("%s in %s").printf (conditions, settings.get_string ("weather-location"));
        }

        public void weather_conditions_change_notify (string body) {
            Notify.init ("com.github.casasfernando.wingpanel-indicator-weather");
            var notification = new Notify.Notification (_("Weather conditions update"), body, "com.github.casasfernando.wingpanel-indicator-weather");
            notification.set_app_name ("Wingpanel Weather");
            notification.set_hint ("desktop-entry", "com.github.casasfernando.wingpanel-indicator-weather");
            notification.set_urgency (Notify.Urgency.LOW);
            try {
                notification.show ();
            } catch (Error e) {
                error ("wingpanel-indicator-weather: %s", e.message);
            }
            return;
        }

    }
}
