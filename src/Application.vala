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
    public class WingpanelWeather : Gtk.Application {
        public WingpanelWeather () {
            Object (application_id: "com.github.casasfernando.wingpanel-indicator-weather",
                    flags : ApplicationFlags.FLAGS_NONE);
        }

        private MainWindow app_window = null;

        protected override void activate () {
            if (app_window == null) {
                app_window = new MainWindow (this);
                app_window.set_application (this);
                app_window.show_all ();
            }

            app_window.present ();

            var quit_action = new SimpleAction ("quit", null);
            add_action (quit_action);
            set_accels_for_action ("app.quit", {"<Control>q", "Escape"});

            quit_action.activate.connect (() => {
                                                    if (app_window != null) {
                                                        app_window.destroy ();
                                                    }
                                                });
        }

        private static int main (string[] args) {
            return new WingpanelWeather ().run (args);
        }
    }
}
