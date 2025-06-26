#!/usr/bin/env python3
#creator by RedRoot(Yaciyna Mikhail) for GAMER STATION [on linux] and Gaming Community OS Linux
# GPL-3.0 License 

import os
import gi
import subprocess
import threading

gi.require_version('Gtk', '4.0')
from gi.repository import Gtk, Gio, GLib

class ScriptLauncherApp(Gtk.Application):
    def __init__(self):
        super().__init__(application_id='com.example.ScriptLauncher')
        self.script_dir = "scripts"
        self.icon_dir = "icons"
        self.last_script_file = "last_script"
        self.scripts = []
        self.last_executed_script = ""
        
        # Create directories if they don't exist
        os.makedirs(self.script_dir, exist_ok=True)
        os.makedirs(self.icon_dir, exist_ok=True)
        
        # Load last executed script
        self.load_last_script()

    def load_last_script(self):
        if os.path.exists(self.last_script_file):
            with open(self.last_script_file, 'r') as f:
                self.last_executed_script = f.read().strip()

    def do_activate(self):
        self.win = Gtk.ApplicationWindow(application=self, title="Script Launcher")
        self.win.set_default_size(800, 600)
        
        # Main vertical box
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        self.win.set_child(main_box)
        
        # Header bar
        header = Gtk.HeaderBar()
        main_box.append(header)
        
        # Refresh button
        refresh_btn = Gtk.Button.new_from_icon_name("view-refresh-symbolic")
        refresh_btn.set_tooltip_text("Refresh")
        refresh_btn.connect("clicked", self.refresh_scripts)
        header.pack_start(refresh_btn)
        
        # Theme switcher
        self.theme_switcher = Gtk.Switch()
        self.theme_switcher.set_active(False)
        self.theme_switcher.connect("state-set", self.on_theme_toggled)
        
        theme_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        theme_box.append(Gtk.Label(label="Dark Mode"))
        theme_box.append(self.theme_switcher)
        header.pack_end(theme_box)
        
        # Quit button
        quit_btn = Gtk.Button.new_from_icon_name("application-exit-symbolic")
        quit_btn.set_tooltip_text("Quit")
        quit_btn.connect("clicked", lambda _: self.quit())
        header.pack_end(quit_btn)
        
        # Scrolled window for the grid
        scrolled = Gtk.ScrolledWindow()
        main_box.append(scrolled)
        
        # Grid for scripts
        self.flow_box = Gtk.FlowBox()
        self.flow_box.set_selection_mode(Gtk.SelectionMode.NONE)
        self.flow_box.set_max_children_per_line(4)
        self.flow_box.set_homogeneous(True)
        scrolled.set_child(self.flow_box)
        
        self.refresh_scripts()
        self.win.present()

    def on_theme_toggled(self, switch, state):
        # GTK4 theme switching without Adwaita
        settings = Gtk.Settings.get_default()
        settings.set_property("gtk-application-prefer-dark-theme", state)

    def refresh_scripts(self, button=None):
        # Clear existing children
        while self.flow_box.get_first_child():
            self.flow_box.remove(self.flow_box.get_first_child())
        
        self.scripts = []
        self.load_last_script()
        
        # Get all .sh files from scripts directory
        try:
            script_files = [f for f in os.listdir(self.script_dir) if f.endswith('.sh')]
        except FileNotFoundError:
            script_files = []
        
        for script in script_files:
            script_name = os.path.splitext(script)[0]
            self.scripts.append(script_name)
            
            # Create a button for each script
            button = Gtk.Button()
            button.set_has_frame(False)
            button.connect("clicked", self.on_script_clicked, script)
            
            # Vertical box for icon and label
            vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
            button.set_child(vbox)
            
            # Icon
            icon_path = os.path.join(self.icon_dir, f"{script_name}.png")
            if os.path.exists(icon_path):
                icon = Gtk.Image.new_from_file(icon_path)
            else:
                icon = Gtk.Image.new_from_icon_name("application-x-executable-symbolic")
            icon.set_pixel_size(64)
            vbox.append(icon)
            
            # Label
            label = Gtk.Label(label=script_name)
            vbox.append(label)
            
            # Add checkmark if this was the last executed script
            if script_name == self.last_executed_script:
                check = Gtk.Image.new_from_icon_name("emblem-ok-symbolic")
                check.set_pixel_size(16)
                overlay = Gtk.Overlay()
                overlay.set_child(icon)
                overlay.add_overlay(check)
                vbox.remove(icon)
                vbox.prepend(overlay)
            
            self.flow_box.append(button)

    def on_script_clicked(self, button, script):
        script_path = os.path.join(self.script_dir, script)
        self.show_progress_dialog(script_path)

    def show_progress_dialog(self, script_path):
        dialog = Gtk.Dialog(title="Running Script", transient_for=self.win, modal=True)
        dialog.set_default_size(300, 100)
        
        content = dialog.get_content_area()
        content.set_orientation(Gtk.Orientation.VERTICAL)
        content.set_spacing(6)
        content.set_margin_top(12)
        content.set_margin_bottom(12)
        content.set_margin_start(12)
        content.set_margin_end(12)
        
        progress = Gtk.ProgressBar()
        content.append(progress)
        
        status_label = Gtk.Label(label="Starting script...")
        content.append(status_label)
        
        dialog.add_button("Cancel", Gtk.ResponseType.CANCEL)
        dialog.connect("response", self.on_dialog_response)
        
        # Store references
        dialog.progress = progress
        dialog.status_label = status_label
        dialog.script_path = script_path
        
        dialog.show()
        
        # Run script in a separate thread
        thread = threading.Thread(target=self.run_script, args=(dialog,))
        thread.daemon = True
        thread.start()

    def run_script(self, dialog):
        script_path = dialog.script_path
        script_name = os.path.splitext(os.path.basename(script_path))[0]
        
        def update_progress(percent, message):
            dialog.progress.set_fraction(percent / 100)
            dialog.status_label.set_label(message)
        
        try:
            process = subprocess.Popen(
                [script_path],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                shell=True,
                text=True
            )
            
            while True:
                output = process.stdout.readline()
                if output == '' and process.poll() is not None:
                    break
                if output:
                    try:
                        percent = int(output.strip())
                        GLib.idle_add(update_progress, percent, f"Running: {percent}%")
                    except ValueError:
                        pass
            
            return_code = process.wait()
            
            if return_code == 0:
                # Script completed successfully
                GLib.idle_add(self.script_completed, dialog, script_name)
            else:
                error = process.stderr.read()
                GLib.idle_add(
                    update_progress, 
                    100, 
                    f"Error: {error or 'Unknown error'}"
                )
                
        except Exception as e:
            GLib.idle_add(
                update_progress, 
                100, 
                f"Failed to execute script: {str(e)}"
            )

    def script_completed(self, dialog, script_name):
        dialog.progress.set_fraction(1.0)
        dialog.status_label.set_label("Script completed successfully!")
        
        # Remove cancel button
        for child in dialog.get_header_bar().get_children():
            if isinstance(child, Gtk.Button):
                child.set_visible(False)
        
        # Add close button
        close_btn = dialog.add_button("Close", Gtk.ResponseType.CLOSE)
        close_btn.grab_focus()
        
        # Save last script
        with open(self.last_script_file, 'w') as f:
            f.write(script_name)
        
        # Update UI
        self.load_last_script()
        GLib.idle_add(self.refresh_scripts)

    def on_dialog_response(self, dialog, response):
        if response == Gtk.ResponseType.CANCEL:
            # TODO: Implement script cancellation if needed
            pass
        dialog.destroy()

if __name__ == "__main__":
    app = ScriptLauncherApp()
    app.run(None)