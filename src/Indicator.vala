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
    public class Indicator : Wingpanel.Indicator {
        const string APPNAME = "wingpanel-indicator-weather";

        private DisplayWidget display_widget;
        private PopoverWidget popover_widget;

        private static GLib.Settings settings;

        public Indicator (Wingpanel.IndicatorManager.ServerType server_type) {
            Object (
                code_name: APPNAME,
                display_name: "Wingpanel Weather",
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
                    return GLib.Source.CONTINUE;
                });
            }
        }

        private void update_popover_widget_data () {
            if (popover_widget == null) return;
            string tformat;
            string dformat;
            switch (settings.get_int ("date-format")) {
                case 0:
                    dformat = "%d/%m/%Y";
                    break;
                case 1:
                    dformat = "%m/%d/%Y";
                    break;
                case 2:
                    dformat = "%d.%m.%Y";
                    break;
                default:
                    dformat = "%d/%m/%Y";
                    break;
            }
            if (settings.get_int ("time-format") == 0) {
                tformat = "%l:%M %p";
            } else {
                tformat = "%R";
            }
            var lupd = new DateTime.from_unix_local (settings.get_int64 ("weather-last-update"));
            popover_widget.update_last_refresh (lupd.format (dformat.concat (" ", tformat)));
            popover_widget.update_current_location (settings.get_string ("weather-location"));
            string conditions = settings.get_string ("weather-conditions");
            if (conditions == "-") {
                conditions = settings.get_string ("weather-sky");
            }
            popover_widget.update_current_details (settings.get_string ("weather-icon"), conditions);
            popover_widget.update_current_temperature (settings.get_string ("weather-temperature"));
            popover_widget.update_current_feelslike (settings.get_string ("weather-feel"));
            popover_widget.update_current_wind (settings.get_string ("weather-wind"));
            popover_widget.update_current_humidity (settings.get_string ("weather-humidity"));
            popover_widget.update_current_pressure (settings.get_string ("weather-pressure"));
            popover_widget.update_current_dewpoint (settings.get_string ("weather-dew"));
            popover_widget.update_current_visibility (settings.get_string ("weather-visibility"));

            int stlvw;
            if (settings.get_int ("time-format") == 0) {
                stlvw = 8;
            } else {
                stlvw = 5;
            }
            popover_widget.update_sunrise (settings.get_string ("weather-sunrise"), stlvw);
            popover_widget.update_sunset (settings.get_string ("weather-sunset"), stlvw);

            popover_widget.update_moonphase (settings.get_string ("weather-moon-phase-icon"), settings.get_string ("weather-moon-phase"));

            settings.changed["display-weather-extended"].connect ( () =>{
                popover_widget.update_weather_extended ();
            });

            settings.changed["display-weather-sun"].connect ( () =>{
                popover_widget.update_weather_sun ();
            });

            settings.changed["display-weather-moon"].connect ( () =>{
                popover_widget.update_weather_moon ();
            });

        }

        private void enable_weather_update () {
            // Set the timer to request weather data updates automatically
            var refresh_timeout = Timeout.add_seconds (settings.get_int ("weather-update-rate") * 60, update_weather);

            // Request weather data update on application settings change
            settings.changed["date-format"].connect ( () =>{
                debug ("wingpanel-indicator-weather: weather information update requested by the indicator: date format change (automatic)");
                WingpanelWeather.Weather.weather_data_update();
            });

            settings.changed["location-manual"].connect ( () =>{
                debug ("wingpanel-indicator-weather: weather information update requested by the indicator: manual location change (automatic)");
                WingpanelWeather.Weather.weather_data_update();
            });

            settings.changed["location-auto"].connect ( () =>{
                if (settings.get_boolean ("location-auto")) {
                    debug ("wingpanel-indicator-weather: weather information update requested by the indicator: location discovery enabled (automatic)");
                    WingpanelWeather.Weather.weather_data_update();
                }
            });

            settings.changed["time-format"].connect ( () =>{
                debug ("wingpanel-indicator-weather: weather information update requested by the indicator: time format change (automatic)");
                WingpanelWeather.Weather.weather_data_update();
            });

            settings.changed["unit-distance"].connect ( () =>{
                debug ("wingpanel-indicator-weather: weather information update requested by the indicator: distance unit change (automatic)");
                WingpanelWeather.Weather.weather_data_update();
            });

            settings.changed["unit-pressure"].connect ( () =>{
                debug ("wingpanel-indicator-weather: weather information update requested by the indicator: pressure unit change (automatic)");
                WingpanelWeather.Weather.weather_data_update();
            });

            settings.changed["unit-speed"].connect ( () =>{
                debug ("wingpanel-indicator-weather: weather information update requested by the indicator: speed unit change (automatic)");
                WingpanelWeather.Weather.weather_data_update();
            });

            settings.changed["unit-temperature"].connect ( () =>{
                debug ("wingpanel-indicator-weather: weather information update requested by the indicator: temperature unit change (automatic)");
                WingpanelWeather.Weather.weather_data_update();
            });

            settings.changed["weather-update-rate"].connect ( () =>{
                GLib.Source.remove (refresh_timeout);
                refresh_timeout = Timeout.add_seconds (settings.get_int ("weather-update-rate") * 60, update_weather);
            });
        }

        private bool update_weather () {
            debug ("wingpanel-indicator-weather: weather information update requested by the indicator: refresh (automatic)");
            WingpanelWeather.Weather.weather_data_update();
            return GLib.Source.CONTINUE;
        }
    }
}
public Wingpanel.Indicator ? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    debug ("wingpanel-indicator-weather: loading weather indicator");

    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        debug ("wingpanel-indicator-weather: Wingpanel is not in session, not loading wingpanel-indicator-weather indicator");
        return null;
    }

    var indicator = new WingpanelWeather.Indicator (server_type);

    return indicator;
}
