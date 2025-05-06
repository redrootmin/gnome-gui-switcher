#!/usr/bin/env python3
#creator by RedRoot(Yaciyna Mikhail) for GAMER STATION [on linux] and Gaming Community OS Linux
# GPL-3.0 License 

import os
import sys
import gi
import subprocess
import threading

gi.require_version('Gtk', '4.0')
from gi.repository import Gtk, GLib

class ScriptLauncherApp(Gtk.Application):
    def __init__(self):
        super().__init__(application_id='com.example.ScriptLauncher')
        
        # Получаем абсолютный путь к папке программы
        if getattr(sys, 'frozen', False):
            self.base_dir = os.path.dirname(sys.executable)
        else:
            self.base_dir = os.path.dirname(os.path.abspath(__file__))
        
        self.script_dir = os.path.join(self.base_dir, "scripts")
        self.icon_dir = os.path.join(self.base_dir, "icons")
        self.last_script_file = os.path.join(self.base_dir, "last_script")
        self.scripts = []
        self.last_executed_script = ""
        
        os.makedirs(self.script_dir, exist_ok=True)
        os.makedirs(self.icon_dir, exist_ok=True)
        self.load_last_script()

    def load_last_script(self):
        if os.path.exists(self.last_script_file):
            with open(self.last_script_file, 'r') as f:
                self.last_executed_script = f.read().strip()

    def do_activate(self):
        self.win = Gtk.ApplicationWindow(application=self, title="Alt-GGS-Alfa")
        self.win.set_default_size(1280, 480)
        ###self.win.set_decorated(False)
        
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        self.win.set_child(main_box)
        
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_vexpand(True)
        main_box.append(scrolled)
        
        self.flow_box = Gtk.FlowBox()
        self.flow_box.set_selection_mode(Gtk.SelectionMode.NONE)
        self.flow_box.set_max_children_per_line(4)
        self.flow_box.set_homogeneous(True)
        scrolled.set_child(self.flow_box)
        
        bottom_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
        bottom_box.set_margin_top(10)
        bottom_box.set_margin_bottom(10)
        bottom_box.set_halign(Gtk.Align.CENTER)
        main_box.append(bottom_box)
        
        refresh_btn = Gtk.Button.new_with_label("Обновить")
        refresh_btn.connect("clicked", self.refresh_scripts)
        bottom_box.append(refresh_btn)
        
        self.theme_switcher = Gtk.Switch()
        self.theme_switcher.set_active(False)
        self.theme_switcher.connect("state-set", self.on_theme_toggled)
        bottom_box.append(self.theme_switcher)
        
        quit_btn = Gtk.Button.new_with_label("Выход")
        quit_btn.connect("clicked", lambda _: self.quit())
        bottom_box.append(quit_btn)
        
        self.status_label = Gtk.Label()
        self.status_label.set_margin_top(5)
        self.status_label.set_margin_bottom(5)
        main_box.append(self.status_label)
        
        self.refresh_scripts()
        self.win.present()

    def on_theme_toggled(self, switch, state):
        settings = Gtk.Settings.get_default()
        settings.set_property("gtk-application-prefer-dark-theme", state)

    def refresh_scripts(self, button=None):
        # Очищаем FlowBox правильным способом для GTK4
        while True:
            child = self.flow_box.get_first_child()
            if child is None:
                break
            self.flow_box.remove(child)
        
        self.scripts = []
        self.load_last_script()
        
        print(f"Поиск скриптов в: {self.script_dir}")
        print(f"Поиск иконок в: {self.icon_dir}")
        
        if not os.path.exists(self.script_dir):
            self.status_label.set_label(f"Папка скриптов не найдена: {self.script_dir}")
            return
        
        try:
            script_files = [f for f in os.listdir(self.script_dir) if f.endswith('.sh')]
            if not script_files:
                self.status_label.set_label(f"В папке нет .sh скриптов: {self.script_dir}")
                return
            
            self.status_label.set_label(f"Найдено скриптов: {len(script_files)}")
            print(f"Найденные скрипты: {script_files}")
            
        except Exception as e:
            self.status_label.set_label(f"Ошибка чтения скриптов: {str(e)}")
            return
        
        if not os.path.exists(self.icon_dir):
            self.status_label.set_label(f"{self.status_label.get_text()} | Папка иконок не найдена: {self.icon_dir}")
        
        for script in script_files:
            script_name = os.path.splitext(script)[0]
            self.scripts.append(script_name)
            
            button = Gtk.Button()
            button.set_has_frame(False)
            button.connect("clicked", self.on_script_clicked, script)
            
            vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
            button.set_child(vbox)
            
            icon_path = os.path.join(self.icon_dir, f"{script_name}.png")
            if os.path.exists(icon_path):
                try:
                    icon = Gtk.Image.new_from_file(icon_path)
                    print(f"Загружена иконка: {icon_path}")
                except Exception as e:
                    print(f"Ошибка загрузки иконки: {e}")
                    icon = Gtk.Image.new_from_icon_name("application-x-executable-symbolic")
            else:
                print(f"Иконка не найдена: {icon_path}")
                icon = Gtk.Image.new_from_icon_name("application-x-executable-symbolic")
            
            icon.set_pixel_size(256)
            vbox.append(icon)
            
            label = Gtk.Label(label=script_name)
            vbox.append(label)
            
            if script_name == self.last_executed_script:
                check = Gtk.Image.new_from_icon_name("emblem-ok-symbolic")
                check.set_pixel_size(16)
                overlay = Gtk.Overlay()
                overlay.set_child(icon)
                overlay.add_overlay(check)
                vbox.remove(icon)
                vbox.prepend(overlay)
            
            # Правильное добавление в FlowBox для GTK4
            self.flow_box.insert(button, -1)  # Используем insert вместо append

    def on_script_clicked(self, button, script):
        script_path = os.path.join(self.script_dir, script)
        if not os.path.exists(script_path):
            self.show_error(f"Скрипт не найден: {script_path}")
            return
        
        if not os.access(script_path, os.X_OK):
            self.show_error(f"Скрипт не исполняемый: {script_path}")
            return
            
        self.show_progress_dialog(script_path)

    def show_error(self, message):
        dialog = Gtk.MessageDialog(
            transient_for=self.win,
            message_type=Gtk.MessageType.ERROR,
            buttons=Gtk.ButtonsType.OK,
            text=message
        )
        dialog.connect("response", lambda d, r: d.destroy())
        dialog.show()

    def show_progress_dialog(self, script_path):
        dialog = Gtk.Dialog(transient_for=self.win)
        dialog.set_title("Выполнение скрипта")
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
        
        status_label = Gtk.Label(label="Запуск скрипта...")
        content.append(status_label)
        
        dialog.add_button("Отмена", Gtk.ResponseType.CANCEL)
        dialog.connect("response", self.on_dialog_response)
        
        dialog.progress = progress
        dialog.status_label = status_label
        dialog.script_path = script_path
        
        dialog.show()
        
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
                        GLib.idle_add(update_progress, percent, f"Выполнение: {percent}%")
                    except ValueError:
                        pass
            
            return_code = process.wait()
            
            if return_code == 0:
                GLib.idle_add(self.script_completed, dialog, script_name)
            else:
                error = process.stderr.read()
                GLib.idle_add(
                    update_progress, 
                    100, 
                    f"Ошибка: {error or 'Неизвестная ошибка'}"
                )
                
        except Exception as e:
            GLib.idle_add(
                update_progress, 
                100, 
                f"Ошибка выполнения: {str(e)}"
            )

    def script_completed(self, dialog, script_name):
        dialog.progress.set_fraction(1.0)
        dialog.status_label.set_label("Скрипт успешно выполнен!")
        
        for child in dialog.get_header_bar().get_children():
            if isinstance(child, Gtk.Button):
                child.set_visible(False)
        
        close_btn = dialog.add_button("Закрыть", Gtk.ResponseType.CLOSE)
        close_btn.grab_focus()
        
        with open(self.last_script_file, 'w') as f:
            f.write(script_name)
        
        self.load_last_script()
        GLib.idle_add(self.refresh_scripts)

    def on_dialog_response(self, dialog, response):
        if response == Gtk.ResponseType.CANCEL:
            pass
        dialog.destroy()

if __name__ == "__main__":
    app = ScriptLauncherApp()
    app.run(None)