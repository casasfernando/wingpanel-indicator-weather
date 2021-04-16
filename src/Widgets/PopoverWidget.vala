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
    public class PopoverWidget : Gtk.Grid {
        private PopoverWidgetRow cur_loc;
        private PopoverWidgetRow cur_temp;
        private PopoverWidgetRow cur_press;
        private PopoverWidgetRow cur_hum;
        private PopoverWidgetRow cur_feel;
        private PopoverWidgetRow cur_dew;
        private PopoverWidgetRow cur_wind;
        private PopoverWidgetRowIconic cur_details;
        private PopoverWidgetRowIconic srise;
        private PopoverWidgetRowIconic sset;
        private PopoverWidgetRowIconic mphase;
        private PopoverWidgetRow last_refresh;

        public unowned Settings settings { get; construct set; }

        public PopoverWidget (Settings settings) {
            Object (settings: settings);
        }

        construct {
            orientation = Gtk.Orientation.VERTICAL;
            column_spacing = 4;

            cur_loc = new PopoverWidgetRow ("Location", "N/A", 4);
            cur_temp = new PopoverWidgetRow ("Temperature", "N/A", 4);
            cur_press = new PopoverWidgetRow ("Pressure", "N/A", 4);
            cur_hum = new PopoverWidgetRow ("Humidity", "N/A", 4);
            cur_feel = new PopoverWidgetRow ("Feels Like", "N/A", 4);
            cur_dew = new PopoverWidgetRow ("Dew Point", "N/A", 4);
            cur_wind = new PopoverWidgetRow ("Wind", "N/A", 4);
            cur_details = new PopoverWidgetRowIconic ("Sky Condition", settings.get_string ("weather-icon"), "N/A", 4);
            srise = new PopoverWidgetRowIconic ("Sunrise", "daytime-sunrise-symbolic", "N/A", 4);
            sset = new PopoverWidgetRowIconic ("Sunset", "daytime-sunset-symbolic", "N/A", 4);
            mphase = new PopoverWidgetRowIconic ("Moon Phase", settings.get_string ("weather-moon-phase-icon"), "N/A", 4);
            last_refresh = new PopoverWidgetRow ("Last Update", "N/A", 4);

            var settings_button = new Gtk.ModelButton ();
            settings_button.text = _ ("Open Settings...");
            /*
            var settings_button = new Gtk.Button.from_icon_name ("preferences-system-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            settings_button.always_show_image = true;
            settings_button.label = "Open Settings...";
            settings_button.relief = Gtk.ReliefStyle.NONE;
            */
            settings_button.clicked.connect (open_settings);

            var refresh_button = new Gtk.ModelButton ();
            refresh_button.text = _ ("Update Weather");
            /*
            var refresh_button = new Gtk.Button.from_icon_name ("view-refresh-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            refresh_button.always_show_image = true;
            refresh_button.label = "Update weather...";
            refresh_button.relief = Gtk.ReliefStyle.NONE;
            */
            refresh_button.clicked.connect ( () => {
                info ("Winpanel Weather: weather information update requested by user (manual)");
                WingpanelWeather.Weather.weather_data_update();
            });

            var title_label = new Gtk.Label ("Wingpanel Weather");
            title_label.halign = Gtk.Align.CENTER;
            title_label.hexpand = true;
            title_label.margin_start = 9;
            title_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);


            add (title_label);
            add (new Wingpanel.Widgets.Separator ());
            add (last_refresh);
            add (refresh_button);
            add (new Wingpanel.Widgets.Separator ());
            add (cur_loc);
            add (cur_temp);
            add (cur_press);
            add (cur_hum);
            add (cur_feel);
            add (cur_dew);
            add (cur_wind);
            add (cur_details);
            add (new Wingpanel.Widgets.Separator ());
            add (srise);
            add (sset);
            add (new Wingpanel.Widgets.Separator ());
            add (mphase);
            add (new Wingpanel.Widgets.Separator ());
            add (settings_button);
        }

        private void open_settings () {
            try {
                var appinfo = AppInfo.create_from_commandline (
                    "com.github.casasfernando.wingpanel-indicator-weather", null, AppInfoCreateFlags.NONE
                    );
                appinfo.launch (null, null);
            } catch (Error e) {
                warning ("%s\n", e.message);
            }
        }

        public void update_current_location (string val) {
            cur_loc.label_value = val;
        }

        public void update_current_temperature (string val) {
            cur_temp.label_value = val;
        }

        public void update_current_humidity (string val) {
            cur_hum.label_value = val;
        }

        public void update_current_pressure (string val) {
            cur_press.label_value = val;
        }

        public void update_current_feelslike (string val) {
            cur_feel.label_value = val;
        }

        public void update_current_dewpoint (string val) {
            cur_dew.label_value = val;
        }

        public void update_current_wind (string val) {
            cur_wind.label_value = val;
        }

        public void update_current_details (string icn, string val) {
            cur_details.icon_value = icn;
            cur_details.label_value = val;
        }

        public void update_sunrise (string val) {
            srise.label_value = val;
        }

        public void update_sunset (string val) {
            sset.label_value = val;
        }

        public void update_moonphase (string icn, string val) {
            mphase.icon_value = icn;
            mphase.label_value = val;
        }

        public void update_last_refresh (string val) {
            last_refresh.label_value = val;
        }

    }
}
