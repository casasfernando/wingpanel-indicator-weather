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
    public class IndicatorWidget : Gtk.Box {
        private Gtk.Label label;
        private Gtk.Image icon;
        private Gtk.Revealer widget_revealer;

        public string icon_name { get; construct; }
        public int char_width { get; construct; }

        public string label_value {
            set {label.label = value; }
        }

        public string new_icon {
            set {
                icon.set_from_icon_name (value, Gtk.IconSize.SMALL_TOOLBAR);
            }
        }

        public bool display {
            set { widget_revealer.reveal_child = value; }
            get { return widget_revealer.get_reveal_child () ; }
        }

        public bool show_temp {
            set { label.visible = value; }
        }

        public IndicatorWidget (string icon_name, int char_width) {
            Object (
                orientation: Gtk.Orientation.HORIZONTAL,
                icon_name: icon_name,
                char_width: char_width
            );
        }

        construct {
            icon = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.SMALL_TOOLBAR);

            var group = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

            label = new Gtk.Label ("N/A");
            label.set_width_chars (char_width);

            group.pack_start (icon);
            group.pack_start (label);

            widget_revealer = new Gtk.Revealer ();
            widget_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;
            widget_revealer.reveal_child = true;

            widget_revealer.add (group);

            pack_start (widget_revealer);
        }
    }
}
