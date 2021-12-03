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
    public class SettingsDialog : Gtk.Dialog {
       
        public unowned Settings settings { get; construct set; }

        public SettingsDialog (Settings settings) {
            Object (
                settings: settings,
                icon_name: "com.github.casasfernando.wingpanel-indicator-weather",
                resizable: false,
                title: "Wingpanel Weather Settings",
                window_position: Gtk.WindowPosition.CENTER,
                default_width: 300
            );
        }

        construct {
            var content_area = this.get_content_area ();

            var toggles = new TogglesWidget (settings);

            var body = new Gtk.Grid ();
            body.hexpand = true;
            body.margin = 10;
            body.column_spacing = 6;
            body.row_spacing = 10;
            body.attach (toggles, 0, 0);

            content_area.add (body);
        }
    }
}
