/*-
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
 * Authored by: Fernando Casas Schössow <casasfernando@outlook.com>
 */

/*
 * Drop-in replacement for GWeather.LocationEntry, which was removed from
 * libgweather 4.0. Provides a Gtk.Entry with an auto-completion backed by
 * the GWeather location database, exposing get_location () so callers can
 * retrieve the GWeather.Location the user picked.
 */
namespace WingpanelWeather {
    public class LocationEntry : Gtk.Entry {
        private enum Column {
            DISPLAY_NAME,
            LOCATION,
            N_COLUMNS
        }

        private Gtk.ListStore store;
        private GWeather.Location? selected_location = null;
        private string selected_name = "";

        public LocationEntry (GWeather.Location? top) {
            Object ();

            store = new Gtk.ListStore (Column.N_COLUMNS, typeof (string), typeof (GWeather.Location));
            populate (top ?? GWeather.Location.get_world ());

            var completion = new Gtk.EntryCompletion ();
            completion.model = store;
            completion.text_column = Column.DISPLAY_NAME;
            completion.set_match_func (match_func);
            completion.match_selected.connect (on_match_selected);
            set_completion (completion);
        }

        // Recursively collect every city with coordinates from the location tree.
        private void populate (GWeather.Location? location) {
            if (location == null) {
                return;
            }

            GWeather.Location? child = null;
            while ((child = location.next_child (child)) != null) {
                if (child.get_level () == GWeather.LocationLevel.CITY) {
                    if (child.has_coords ()) {
                        string city = child.get_city_name () ?? child.get_name () ?? "";
                        string? country = child.get_country_name ();
                        string display = (country != null && country != "")
                            ? "%s, %s".printf (city, country)
                            : city;

                        Gtk.TreeIter iter;
                        store.append (out iter);
                        store.set (iter, Column.DISPLAY_NAME, display, Column.LOCATION, child);
                    }
                } else {
                    populate (child);
                }
            }
        }

        // Case-insensitive substring match on the displayed location name.
        private bool match_func (Gtk.EntryCompletion completion, string key, Gtk.TreeIter iter) {
            Value val;
            store.get_value (iter, Column.DISPLAY_NAME, out val);
            unowned string? name = val.get_string ();
            if (name == null) {
                return false;
            }
            return name.casefold ().contains (key.casefold ());
        }

        private bool on_match_selected (Gtk.TreeModel model, Gtk.TreeIter iter) {
            Value name_val;
            Value loc_val;
            model.get_value (iter, Column.DISPLAY_NAME, out name_val);
            model.get_value (iter, Column.LOCATION, out loc_val);

            selected_name = name_val.get_string ();
            selected_location = (GWeather.Location) loc_val.get_object ();

            set_text (selected_name);
            set_position (-1);
            return true;
        }

        // Returns the location the user selected, or null if the current text
        // no longer matches a picked location.
        public GWeather.Location? get_location () {
            if (selected_location != null && get_text () == selected_name) {
                return selected_location;
            }
            return null;
        }
    }
}
