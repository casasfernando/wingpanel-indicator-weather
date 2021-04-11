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
    public class TogglesWidget : Gtk.Grid {
        private Wingpanel.Widgets.Switch weather_switch;
        private Wingpanel.Widgets.Switch indicator;
        private SpinRow weather_refresh_spin;
        public unowned Settings settings { get; construct set; }

        public TogglesWidget (Settings settings) {
            Object (settings: settings, hexpand: true);
        }

        construct {
            orientation = Gtk.Orientation.VERTICAL;

            indicator = new Wingpanel.Widgets.Switch ("ON/OFF", settings.get_boolean ("display-indicator"));

            settings.bind ("display-indicator", indicator.get_switch (), "active", SettingsBindFlags.DEFAULT);

            weather_refresh_spin = new SpinRow ("Weather refresh rate (min)", 1, 60);
            weather_refresh_spin.set_spin_value (settings.get_int ("weather-refresh-rate"));
            weather_refresh_spin.changed.connect ( () => {
                settings.set_int ("weather-refresh-rate", weather_refresh_spin.get_spin_value ());
            });

            add (indicator);
            add (new Wingpanel.Widgets.Separator ());
            add (weather_refresh_spin);
            add (new Wingpanel.Widgets.Separator ());
        }
    }
}
