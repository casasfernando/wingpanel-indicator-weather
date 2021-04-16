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
            weather_refresh_spin = new SpinRow ("Weather refresh rate (min)", 1, 60);
            weather_refresh_spin.set_spin_value (settings.get_int ("weather-refresh-rate"));
            weather_refresh_spin.changed.connect ( () => {
                settings.set_int ("weather-refresh-rate", weather_refresh_spin.get_spin_value ());
            });

            add (indicator);
            add (temp_indicator);
            add (new Wingpanel.Widgets.Separator ());
            add (location_auto);
            add (current_location);
            add (find_location);
            add (location_search);
            add (weather_refresh_spin);
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
