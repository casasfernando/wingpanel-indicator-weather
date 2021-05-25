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
    public class SpinRow : Gtk.Grid {
        public new signal void changed ();

        public string caption { owned get; set; }
        public int min { get; set; }
        public int max { get; set; }

        private Gtk.Label button_label;
        private Gtk.SpinButton button_spin;

        public SpinRow (string caption, int min, int max) {
            Object (caption: caption, min: min, max: max);
            button_spin.set_increments (1, 0);
            button_spin.set_range (min, max);
            button_label.set_text_with_mnemonic (caption);
            button_label.set_mnemonic_widget (this);
        }

        construct {
            var style_context = this.get_style_context ();
            style_context.add_class (Gtk.STYLE_CLASS_MENUITEM);

            button_spin = new Gtk.SpinButton.with_range (min, max, 1);
            button_spin.halign = Gtk.Align.END;
            button_spin.margin_end = 6;
            button_spin.hexpand = true;
            button_spin.valign = Gtk.Align.CENTER;

            button_label = new Gtk.Label (null);
            button_label.halign = Gtk.Align.START;
            button_label.margin_start = 6;
            button_label.margin_end = 10;

            attach (button_label, 0, 0, 1, 1);
            attach (button_spin, 1, 0, 1, 1);

            button_spin.value_changed.connect (() => {
                changed ();
            });
        }

        public new Gtk.Label get_label () {
            return button_label;
        }

        public Gtk.SpinButton get_spin () {
            return button_spin;
        }

        public int get_spin_value () {
            return button_spin.get_value_as_int ();
        }

        public void set_spin_value (int val) {
            button_spin.set_value ((double) val);
        }
    }
}
