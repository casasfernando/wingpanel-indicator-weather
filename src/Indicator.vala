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
    public class Indicator : Wingpanel.Indicator {
        const string APPNAME = "wingpanel-indicator-weather";

        private DisplayWidget display_widget;
        private PopoverWidget popover_widget;

        private static GLib.Settings settings;

        public Indicator (Wingpanel.IndicatorManager.ServerType server_type) {
            Object (
                code_name: APPNAME,
                display_name: "Wingpanel-Weather",
                description: "Weather indicator for Wingpanel"
                );
        }

        construct {
            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("/com/github/casasfernando/wingpanel-indicator-weather/icons/Application.css");
            Gtk.StyleContext.add_provider_for_screen (
                Gdk.Screen.get_default (),
                provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );

            Gtk.IconTheme.get_default ().add_resource_path ("/com/github/casasfernando/wingpanel-indicator-weather/icons");

            settings = new GLib.Settings ("com.github.casasfernando.wingpanel-indicator-weather");

            visible = settings.get_boolean ("display-indicator");

            settings.bind ("display-indicator", this, "visible", SettingsBindFlags.DEFAULT);
        }

        public override Gtk.Widget get_display_widget () {
            if (display_widget == null) {
                display_widget = new DisplayWidget (settings);
                update_display_widget_data ();
                enable_weather_update ();
            }
            return display_widget;
        }

        public override Gtk.Widget ? get_widget () {
            if (popover_widget == null) {
                popover_widget = new PopoverWidget (settings);
            }

            return popover_widget;
        }

        public override void opened () {
        }

        public override void closed () {
        }

        private void update_display_widget_data () {
            if (display_widget != null) {
                Timeout.add_seconds (1, () => {
                    display_widget.update_weather ();
                    update_popover_widget_data ();
                    return true;
                });
            }
        }

        private void update_popover_widget_data () {
            if (popover_widget == null) return;

        }

        private void enable_weather_update () {
            var refresh_timeout = Timeout.add_seconds (settings.get_int ("weather-refresh-rate") * 60, update_weather);

            settings.changed["weather-refresh-rate"].connect ( () =>{
                GLib.Source.remove (refresh_timeout);
                refresh_timeout = Timeout.add_seconds (settings.get_int ("weather-refresh-rate") * 60, update_weather);
            });
        }

        private bool update_weather () {
            info ("Indicator: Request weather refresh");
            settings.set_boolean ("weather-refresh", true);
            return true;
        }
    }
}
public Wingpanel.Indicator ? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    debug ("Loading weather indicator");

    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        debug ("Wingpanel is not in session, not loading wingpanel-indicator-weather indicator");
        return null;
    }

    var indicator = new WingpanelWeather.Indicator (server_type);

    return indicator;
}
