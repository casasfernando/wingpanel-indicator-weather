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
        private Wingpanel.Widgets.Switch temp_indicator;
        private Wingpanel.Widgets.Switch location_auto;
        private GWeather.LocationEntry location_search;
        private SpinRow weather_refresh_spin;
        private PopoverWidgetRow current_location;
        private PopoverWidgetRow find_location;
        private PopoverWidgetRow units_selection;
        private ComboRow unit_temp;
        private ComboRow unit_press;
        private ComboRow unit_speed;
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
            temp_indicator = new Wingpanel.Widgets.Switch ("Show temperature", settings.get_boolean ("display-temperature"));
            settings.bind ("display-temperature", temp_indicator.get_switch (), "active", SettingsBindFlags.DEFAULT);

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
            weather_refresh_spin = new SpinRow ("Weather update rate (in mins)", 15, 1440);
            weather_refresh_spin.set_spin_value (settings.get_int ("weather-update-rate"));
            weather_refresh_spin.changed.connect ( () => {
                settings.set_int ("weather-update-rate", weather_refresh_spin.get_spin_value ());
            });

            // Units selection label
            units_selection = new PopoverWidgetRow ("Units:", "", 4);
            // Unit Temperature
            string[] unit_temp_val = { "Celsius (ºC)", "Fahrenheit (ºF)" };
            unit_temp = new ComboRow ("Temperature", unit_temp_val, settings.get_int ("unit-temperature"));
            unit_temp.changed.connect( () => {
                settings.set_int ("unit-temperature", unit_temp.get_combo_value ());
            });
            // Unit Pressure
            string[] unit_press_val = { "Hectopascal (hPa)", "Inches of mercury (inHg)", "Millibars (mbar)", "Millimeters of mercury (mmHg)" };
            unit_press = new ComboRow ("Pressure", unit_press_val, settings.get_int ("unit-pressure"));
            unit_press.changed.connect( () => {
                settings.set_int ("unit-pressure", unit_press.get_combo_value ());
            });
            // Unit speed
            string[] unit_speed_val = { "Beaufort (bft)", "Kilometers per hour (km/h)", "Knots (knots)", "Meters per second (m/s)", "Miles per hour (mph)" };
            unit_speed = new ComboRow ("Speed", unit_speed_val, settings.get_int ("unit-speed"));
            unit_speed.changed.connect( () => {
                settings.set_int ("unit-speed", unit_speed.get_combo_value ());
            });

            // Date Format
            string[] date_format_val = { "DD/MM/YYYY", "MM/DD/YYYY", "DD.MM.YYYY" };
            date_format = new ComboRow ("Date format", date_format_val, settings.get_int ("date-format"));
            date_format.changed.connect( () => {
                settings.set_int ("date-format", date_format.get_combo_value ());
            });
            // Time Format
            string[] time_format_val = { "12 hour (AM/PM)", "24 hour" };
            time_format = new ComboRow ("Time format", time_format_val, settings.get_int ("time-format"));
            time_format.changed.connect( () => {
                settings.set_int ("time-format", time_format.get_combo_value ());
            });

            add (indicator);
            add (temp_indicator);
            add (new Wingpanel.Widgets.Separator ());
            add (location_auto);
            add (current_location);
            add (find_location);
            add (location_search);
            add (new Wingpanel.Widgets.Separator ());
            add (weather_refresh_spin);
            add (new Wingpanel.Widgets.Separator ());
            add (units_selection);
            add (unit_temp);
            add (unit_press);
            add (unit_speed);
            add (new Wingpanel.Widgets.Separator ());
            add (date_format);
            add (time_format);
            add (new Wingpanel.Widgets.Separator ());

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
