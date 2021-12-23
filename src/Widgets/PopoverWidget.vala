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
        private PopoverWidgetRow last_refresh;
        private PopoverWidgetRow cur_loc;
        private PopoverWidgetRowIconic cur_details;
        private PopoverWidgetRow cur_temp;
        private PopoverWidgetRow cur_feel;
        private PopoverWidgetRow cur_wind;
        private PopoverWidgetRow cur_hum;
        private PopoverWidgetRow cur_dew;
        private PopoverWidgetRow cur_press;
        private PopoverWidgetRow cur_vis;
        private Gtk.Separator sun_info;
        private PopoverWidgetRowIconic srise;
        private PopoverWidgetRowIconic sset;
        private Gtk.Separator moon_info;
        private PopoverWidgetRowIconic mphase;

        public unowned Settings settings { get; construct set; }

        public PopoverWidget (Settings settings) {
            Object (settings: settings);
        }

        construct {
            orientation = Gtk.Orientation.VERTICAL;
            column_spacing = 4;

            last_refresh = new PopoverWidgetRow (_("Last Update"), _("N/A"), 4);
            cur_loc = new PopoverWidgetRow (_("Location"), _("N/A"), 4);
            cur_details = new PopoverWidgetRowIconic ("", settings.get_string ("weather-icon"), _("N/A"), 4);
            cur_temp = new PopoverWidgetRow (_("Temperature"), _("N/A"), 4);
            cur_feel = new PopoverWidgetRow (_("Feels Like"), _("N/A"), 4);
            cur_wind = new PopoverWidgetRow (_("Wind"), _("N/A"), 4);
            cur_hum = new PopoverWidgetRow (_("Humidity"), _("N/A"), 4);
            cur_dew = new PopoverWidgetRow (_("Dew Point"), _("N/A"), 4);
            cur_press = new PopoverWidgetRow (_("Pressure"), _("N/A"), 4);
            cur_vis = new PopoverWidgetRow (_("Visibility"), _("N/A"), 4);
            sun_info = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            srise = new PopoverWidgetRowIconic (_("Sunrise"), "daytime-sunrise-symbolic", _("N/A"), 4);
            sset = new PopoverWidgetRowIconic (_("Sunset"), "daytime-sunset-symbolic", _("N/A"), 4);
            moon_info = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            mphase = new PopoverWidgetRowIconic (_("Moon Phase"), settings.get_string ("weather-moon-phase-icon"), _("N/A"), 4);

            var settings_button = new Gtk.ModelButton ();
            settings_button.text = _("Open Settings…");
            /*
            var settings_button = new Gtk.Button.from_icon_name ("preferences-system-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            settings_button.always_show_image = true;
            settings_button.label = "Open Settings…";
            settings_button.relief = Gtk.ReliefStyle.NONE;
            */
            settings_button.clicked.connect (open_settings);

            var refresh_button = new Gtk.ModelButton ();
            refresh_button.text = _("Update Weather Data");
            /*
            var refresh_button = new Gtk.Button.from_icon_name ("view-refresh-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            refresh_button.always_show_image = true;
            refresh_button.label = "Update weather…";
            refresh_button.relief = Gtk.ReliefStyle.NONE;
            */
            refresh_button.clicked.connect ( () => {
                debug ("Winpanel Weather: weather information update requested by user (manual)");
                WingpanelWeather.Weather.weather_data_update();
            });

            add (last_refresh);
            add (refresh_button);
            add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
            add (cur_loc);
            add (cur_details);
            add (cur_temp);
            add (cur_feel);
            add (cur_wind);
            add (cur_hum);

            add (cur_dew);
            add (cur_press);
            add (cur_vis);
            update_weather_extended ();

            add (sun_info);
            add (srise);
            add (sset);
            update_weather_sun ();

            add (moon_info);
            add (mphase);
            update_weather_moon ();

            add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
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

        public void set_widget_visible (Gtk.Widget widget, bool visible) {
            widget.no_show_all = !visible;
            widget.visible = visible;
        }

        public void update_weather_extended () {
            if (settings.get_boolean ("display-weather-extended")) {
                set_widget_visible (cur_dew, true);
                set_widget_visible (cur_press, true);
                set_widget_visible (cur_vis, true);
            } else {
                set_widget_visible (cur_dew, false);
                set_widget_visible (cur_press, false);
                set_widget_visible (cur_vis, false);
            }
        }

        public void update_weather_sun () {
            if (settings.get_boolean ("display-weather-sun")) {
                set_widget_visible (sun_info, true);
                set_widget_visible (srise, true);
                set_widget_visible (sset, true);
            } else {
                set_widget_visible (sun_info, false);
                set_widget_visible (srise, false);
                set_widget_visible (sset, false);
            }
        }

        public void update_weather_moon () {
            if (settings.get_boolean ("display-weather-moon")) {
                set_widget_visible (moon_info, true);
                set_widget_visible (mphase, true);
            } else {
                set_widget_visible (moon_info, false);
                set_widget_visible (mphase, false);
            }
        }

        public void update_last_refresh (string val) {
            last_refresh.label_value = val;
        }

        public void update_current_location (string val) {
            cur_loc.label_value = val;
        }

        public void update_current_details (string icn, string val) {
            cur_details.icon_value = icn;
            cur_details.label_value = val;
        }

        public void update_current_temperature (string val) {
            cur_temp.label_value = val;
        }

        public void update_current_feelslike (string val) {
            cur_feel.label_value = val;
        }

        public void update_current_wind (string val) {
            cur_wind.label_value = val;
        }

        public void update_current_humidity (string val) {
            cur_hum.label_value = val;
        }

        public void update_current_dewpoint (string val) {
            cur_dew.label_value = val;
        }

        public void update_current_pressure (string val) {
            cur_press.label_value = val;
        }

        public void update_current_visibility (string val) {
            cur_vis.label_value = val;
        }

        public void update_sunrise (string val, int cwval) {
            srise.label_value = val;
            srise.label_value_width = cwval;
        }

        public void update_sunset (string val, int cwval) {
            sset.label_value = val;
            sset.label_value_width = cwval;
        }

        public void update_moonphase (string icn, string val) {
            mphase.icon_value = icn;
            mphase.label_value = val;
        }

    }
}
