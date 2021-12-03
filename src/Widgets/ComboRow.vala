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

namespace WingpanelWeather {
    public class ComboRow : Gtk.Grid {
        private Gtk.Label text_label;
        private Gtk.ComboBoxText unit_combo;

        public new signal void changed ();

        public ComboRow (string text, string[] values, int setval) {
            text_label = new Gtk.Label (text);
            text_label.halign = Gtk.Align.START;
            text_label.hexpand = true;
            text_label.margin_start = 4;

            unit_combo = new Gtk.ComboBoxText ();
            int setidx = 0;
            foreach (string val in values) {
                unit_combo.append_text(val);
                if (setval == setidx) {
                    unit_combo.set_active(setval);
                }
                setidx++;
            }

            add (text_label);
            add (unit_combo);

            unit_combo.changed.connect (() => {
                changed ();
            });

        }

        public int get_combo_value () {
            return unit_combo.get_active ();
        }

    }
}
