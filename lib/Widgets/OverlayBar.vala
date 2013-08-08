/***
    Copyright (C) 2012 ammonkey <am.monkeyd@gmail.com>
    Copyright (C) 2013 Julián Unrrein <junrrein@gmail.com>

    This program or library is free software; you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 3 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General
    Public License along with this library; if not, write to the
    Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301 USA.
***/

/**
 * A floating status bar that displays a single line of text.
 *
 * This widget is intended to be used as an overlay for a {@link Gtk.Overlay} and is placed in its
 * bottom corners (bottom-right corner, initially).
 *
 * The Overlay Bar displays a single line of text that can be manipulated using the status label
 * (a standard {@link Gtk.Label}).
 *
 * This widget tries to avoid getting in front of the content being shown inside the {@link Gtk.Overlay}
 * by moving itself to the opposite corner from the current one when a mouse enter event is detected.
 *
 * ''Example'' <<BR>>
 *
 * public class OverlayBarExample : Gtk.Window {{{
 *
 *     private Gtk.Overlay overlay;
 *     private Granite.Widgets.OverlayBar overlaybar;
 *
 *     public OverlayBarExample () {{{
 *         this.title = "Overlay Bar Example";
 *  	   this.window_position = Gtk.WindowPosition.CENTER;
 *  	   this.set_default_size (400, 300);
 *
 *  	   this.overlay = new Gtk.Overlay ();
 *  	   overlay.set_events (Gdk.EventMask.ENTER_NOTIFY_MASK);
 *
 *         this.overlaybar = new Granite.Widgets.OverlayBar ();
 *         this.overlaybar.status.label = "Overlay Bar Example";
 *
 *         overlay.add (new Gtk.IconView ());
 *         overlay.add_overlay (overlaybar);
 *
 *         var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
 *         box.pack_start (overlay, true, true);
 *
 *         this.add (box);
 *     }}}
 *
 *     public static int main (string[] args) {{{
 *         Gtk.init (ref args);
 *
 *         var window = new OverlayBarExample ();
 *         window.destroy.connect (Gtk.main_quit);
 *         window.show_all ();
 *
 *         Gtk.main ();
 *         return 0;
 *     }}}
 * }}}
 *
 * valac --pkg gtk+-3.0 --pkg granite OverlayBarExample.vala
 *
 * @see Gtk.Overlay
 */
public class Granite.Widgets.OverlayBar : Gtk.EventBox {

    private const string FALLBACK_THEME = """
   .granite-overlay-bar {
       background-color: @bg_color;
       border-radius: 3px;
       padding: 3px 6px;
       margin: 3px;
       border-style: solid;
       border-width: 1px;
       border-color: darker (@bg_color);
   }""";

    public Gtk.Label status;

    public OverlayBar () {
        visible_window = false;

        status = new Gtk.Label (null);
        status.set_ellipsize (Pango.EllipsizeMode.END);
        add (status);
        status.show ();

        set_halign (Gtk.Align.END);
        set_valign (Gtk.Align.END);

        set_default_style ();

        var ctx = get_style_context ();
        ctx.changed.connect (update_spacing);
        ctx.changed.connect_after (queue_resize);

        update_spacing ();
    }

    public override void parent_set (Gtk.Widget? old_parent) {
        Gtk.Widget parent = get_parent ();

        if (old_parent != null)
            old_parent.enter_notify_event.disconnect (enter_notify_callback);
        if (parent != null)
            parent.enter_notify_event.connect (enter_notify_callback);
    }

    public override bool draw (Cairo.Context cr) {
        var ctx = get_style_context ();
        ctx.render_background (cr, 0, 0, get_allocated_width (), get_allocated_height ());
        ctx.render_frame (cr, 0, 0, get_allocated_width (), get_allocated_height ());
        return base.draw (cr);
    }

    public override Gtk.SizeRequestMode get_request_mode () {
        return Gtk.SizeRequestMode.HEIGHT_FOR_WIDTH;
    }

    public override void get_preferred_width (out int minimum_width, out int natural_width) {
        Gtk.Requisition label_min_size, label_natural_size;
        status.get_preferred_size (out label_min_size, out label_natural_size);

        var ctx = get_style_context ();
        var state = ctx.get_state ();
        var border = ctx.get_border (state);

        int extra_allocation = border.left + border.right;
        minimum_width = extra_allocation + label_min_size.width;
        natural_width = extra_allocation + label_natural_size.width;
    }

    public override void get_preferred_height_for_width (int width, out int minimum_height,
                                                         out int natural_height) {
        Gtk.Requisition label_min_size, label_natural_size;
        status.get_preferred_size (out label_min_size, out label_natural_size);

        var ctx = get_style_context ();
        var state = ctx.get_state ();
        var border = ctx.get_border (state);

        int extra_allocation = border.top + border.bottom;
        minimum_height = extra_allocation + label_min_size.height;
        natural_height = extra_allocation + label_natural_size.height;
    }

    private void update_spacing () {
        var ctx = get_style_context ();
        var state = ctx.get_state ();

        var padding = ctx.get_padding (state);
        status.margin_top = padding.top;
        status.margin_bottom = padding.bottom;
        status.margin_left = padding.left;
        status.margin_right = padding.right;

        var margin = ctx.get_margin (state);
        margin_top = margin.top;
        margin_bottom = margin.bottom;
        margin_left = margin.left;
        margin_right = margin.right;
    }

    private void set_default_style () {
        int priority = Gtk.STYLE_PROVIDER_PRIORITY_FALLBACK;
        Granite.Widgets.Utils.set_theming (this, FALLBACK_THEME, "granite-overlay-bar", priority);
    }

    private bool enter_notify_callback (Gdk.EventCrossing event) {
        if (get_halign () == Gtk.Align.START)
            set_halign (Gtk.Align.END);
        else
            set_halign (Gtk.Align.START);

        return false;
    }
}
