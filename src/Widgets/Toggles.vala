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
    public class TogglesWidget : Gtk.Grid {
        private Wingpanel.Widgets.Switch indicator;
        private Wingpanel.Widgets.Switch indicator_temp;
        private Wingpanel.Widgets.Switch indicator_notifications;
        private Wingpanel.Widgets.Switch weather_extended;
        private Wingpanel.Widgets.Switch weather_sun;
        private Wingpanel.Widgets.Switch weather_moon;
        private Wingpanel.Widgets.Switch location_auto;
        private GWeather.LocationEntry location_search;
        private SpinRow weather_refresh_spin;
        private PopoverWidgetRow current_location;
        private PopoverWidgetRow find_location;
        private ComboRow unit_dist;
        private ComboRow unit_press;
        private ComboRow unit_speed;
        private ComboRow unit_temp;
        private ComboRow date_format;
        private ComboRow time_format;

        public unowned Settings settings { get; construct set; }

        public TogglesWidget (Settings settings) {
            Object (settings: settings, hexpand: true);
        }

        construct {
            orientation = Gtk.Orientation.VERTICAL;

            // Enable indicator switch
            indicator = new Wingpanel.Widgets.Switch ("Show indicator", settings.get_boolean ("display-indicator"));
            settings.bind ("display-indicator", indicator.get_switch (), "active", SettingsBindFlags.DEFAULT);

            // Enable temperature displain in Wingpanel indicator switch
            indicator_temp = new Wingpanel.Widgets.Switch ("Show temperature in panel", settings.get_boolean ("display-temperature"));
            settings.bind ("display-temperature", indicator_temp.get_switch (), "active", SettingsBindFlags.DEFAULT);

            // Enable weather conditions change notifications
            indicator_notifications = new Wingpanel.Widgets.Switch ("Show notifications", settings.get_boolean ("display-notifications"));
            settings.bind ("display-notifications", indicator_notifications.get_switch (), "active", SettingsBindFlags.DEFAULT);

            // Location discovery switch
            location_auto = new Wingpanel.Widgets.Switch ("Location discovery", settings.get_boolean ("location-auto"));
            settings.bind ("location-auto", location_auto.get_switch (), "active", SettingsBindFlags.DEFAULT);

            // Current location label
            current_location = new PopoverWidgetRow ("Current location", settings.get_string ("weather-location"), 4);
            settings.changed["weather-location"].connect ( () =>{
                current_location.label_value = settings.get_string ("weather-location");
            });

            // Search your location label
            find_location = new PopoverWidgetRow ("Search your location:", "", 4);
            settings.bind ("location-auto", find_location, "visible", SettingsBindFlags.INVERT_BOOLEAN);

            // Search location search entry
            location_search = new GWeather.LocationEntry (GWeather.Location.get_world ());
            location_search.set_activates_default (true);
            location_search.changed.connect (location_selected);
            settings.bind ("location-auto", location_search, "visible", SettingsBindFlags.INVERT_BOOLEAN);

            // Weather information update refresh rate selector
            weather_refresh_spin = new SpinRow ("Update weather data (in mins)", 15, 1440);
            weather_refresh_spin.set_spin_value (settings.get_int ("weather-update-rate"));
            weather_refresh_spin.changed.connect ( () => {
                settings.set_int ("weather-update-rate", weather_refresh_spin.get_spin_value ());
            });

            // Show extended weather information
            weather_extended = new Wingpanel.Widgets.Switch ("Show weather extended information", settings.get_boolean ("display-weather-extended"));
            settings.bind ("display-weather-extended", weather_extended.get_switch (), "active", SettingsBindFlags.DEFAULT);
            // Show sunrise/sunset information
            weather_sun = new Wingpanel.Widgets.Switch ("Show sunrise/sunset time", settings.get_boolean ("display-weather-sun"));
            settings.bind ("display-weather-sun", weather_sun.get_switch (), "active", SettingsBindFlags.DEFAULT);
            // Show moon phase information
            weather_moon = new Wingpanel.Widgets.Switch ("Show moon phase information", settings.get_boolean ("display-weather-moon"));
            settings.bind ("display-weather-moon", weather_moon.get_switch (), "active", SettingsBindFlags.DEFAULT);

            // Unit Distance
            string[] unit_dist_val = { "Kilometer (km)", "Mile (mi)" };
            unit_dist = new ComboRow ("Distance", unit_dist_val, settings.get_int ("unit-distance"));
            unit_dist.changed.connect( () => {
                settings.set_int ("unit-distance", unit_dist.get_combo_value ());
            });
            // Unit Pressure
            string[] unit_press_val = { "Hectopascal (hPa)", "Inches of mercury (inHg)", "Millibars (mbar)", "Millimeters of mercury (mmHg)" };
            unit_press = new ComboRow ("Pressure", unit_press_val, settings.get_int ("unit-pressure"));
            unit_press.changed.connect( () => {
                settings.set_int ("unit-pressure", unit_press.get_combo_value ());
            });
            // Unit Speed
            string[] unit_speed_val = { "Beaufort (bft)", "Kilometers per hour (km/h)", "Knots (knots)", "Meters per second (m/s)", "Miles per hour (mph)" };
            unit_speed = new ComboRow ("Speed", unit_speed_val, settings.get_int ("unit-speed"));
            unit_speed.changed.connect( () => {
                settings.set_int ("unit-speed", unit_speed.get_combo_value ());
            });
            // Unit Temperature
            string[] unit_temp_val = { "Celsius (ºC)", "Fahrenheit (ºF)" };
            unit_temp = new ComboRow ("Temperature", unit_temp_val, settings.get_int ("unit-temperature"));
            unit_temp.changed.connect( () => {
                settings.set_int ("unit-temperature", unit_temp.get_combo_value ());
            });

            // Date Format
            string[] date_format_val = { "DD/MM/YYYY", "MM/DD/YYYY", "DD.MM.YYYY" };
            date_format = new ComboRow ("Date format", date_format_val, settings.get_int ("date-format"));
            date_format.changed.connect( () => {
                settings.set_int ("date-format", date_format.get_combo_value ());
            });
            // Time Format
            string[] time_format_val = { "AM/PM", "24-hour" };
            time_format = new ComboRow ("Time format", time_format_val, settings.get_int ("time-format"));
            time_format.changed.connect( () => {
                settings.set_int ("time-format", time_format.get_combo_value ());
            });

            add (indicator);
            add (indicator_temp);
            add (indicator_notifications);
            add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
            add (weather_extended);
            add (weather_sun);
            add (weather_moon);
            add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
            add (location_auto);
            add (current_location);
            add (find_location);
            add (location_search);
            add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
            add (weather_refresh_spin);
            add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
            add (unit_temp);
            add (unit_press);
            add (unit_speed);
            add (unit_dist);
            add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
            add (date_format);
            add (time_format);

        }

        private void location_selected () {

            GWeather.Location? location_manual = null;

            // Search for the new location selected by the user
            if (location_search.get_text () != "") {
                location_manual = location_search.get_location ();
            }

            // If a location is found
            if (location_manual != null) {
                // Check if the selected location has coordinates
                if (location_manual.has_coords()) {
                        // Save the user manually selected location to settings
                        settings.set_value ("location-manual", location_manual.serialize ());
                }
            }

        }

    }
}
