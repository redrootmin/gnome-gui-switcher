#!/usr/bin/env python3
#creator by RedRoot(Yaciyna Mikhail) for GAMER STATION [on linux] and Gaming Community OS Linux
# GPL-3.0 License 

import gi
gi.require_version("Gtk", "4.0")
from gi.repository import Gtk

def on_activate(app):
    win = Gtk.ApplicationWindow(application=app)
    win.set_title("Test Window")
    win.set_default_size(400, 300)
    win.present()

app = Gtk.Application(application_id='com.example.test')
app.connect('activate', on_activate)
app.run(None)