#!/usr/bin/env python3
#creator by RedRoot(Yaciyna Mikhail) for GAMER STATION [on linux] and Gaming Community OS Linux
# GPL-3.0 License 

import os
import sys
import gi
import subprocess
import threading

gi.require_version('Gtk', '4.0')
from gi.repository import Gtk, GLib, Pango

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
        self.current_theme = "dark"  # Текущая тема
        
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
        
        # CSS стили для приложения
        self.setup_styles()
        
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

    def setup_styles(self):
        css_provider = Gtk.CssProvider()
        css_provider.load_from_data(f"""
            .script-label {{
                font-size: 24px;
                font-weight: bold;
                margin-top: 8px;
            }}
            .success-check {{
                color: #4CAF50;
                -gtk-icon-shadow: 0 1px 2px rgba(0,0,0,0.5);
            }}
            .error-check {{
                color: #F44336;
                -gtk-icon-shadow: 0 1px 2px rgba(0,0,0,0.5);
            }}
            progressbar {{
                min-height: 32px;
            }}
            progressbar > trough {{
                min-height: 32px;
                background-color: #e0e0e0;
            }}
            progressbar > trough > progress {{
                min-height: 32px;
                background-color: #2196F3;
            }}
            .progress-text {{
                color: {'#000000' if self.current_theme == 'light' else '#FFFFFF'};
                font-size: 14px;
                font-weight: bold;
            }}
        """.encode())
        Gtk.StyleContext.add_provider_for_display(
            self.win.get_display(),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

    def on_theme_toggled(self, switch, state):
        settings = Gtk.Settings.get_default()
        settings.set_property("gtk-application-prefer-dark-theme", state)
        self.current_theme = "dark" if state else "light"
        self.setup_styles()  # Обновляем стили при смене темы

    def refresh_scripts(self, button=None):
        while True:
            child = self.flow_box.get_first_child()
            if child is None:
                break
            self.flow_box.remove(child)
        
        self.scripts = []
        self.load_last_script()
        
        if not os.path.exists(self.script_dir):
            self.status_label.set_label(f"Папка скриптов не найдена: {self.script_dir}")
            return
        
        try:
            script_files = [f for f in os.listdir(self.script_dir) if f.endswith('.sh')]
            if not script_files:
                self.status_label.set_label(f"В папке нет .sh скриптов: {self.script_dir}")
                return
            
            self.status_label.set_label(f"Найдено скриптов: {len(script_files)}")
            
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
            button.set_can_focus(False)
            button.connect("clicked", self.on_script_clicked, script)
            
            vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
            button.set_child(vbox)
            
            # Создаем Overlay для иконки и галочки
            overlay = Gtk.Overlay()
            icon_path = os.path.join(self.icon_dir, f"{script_name}.png")
            
            if os.path.exists(icon_path):
                try:
                    icon = Gtk.Image.new_from_file(icon_path)
                except Exception as e:
                    print(f"Ошибка загрузки иконки: {e}")
                    icon = Gtk.Image.new_from_icon_name("application-x-executable-symbolic")
            else:
                print(f"Иконка не найдена: {icon_path}")
                icon = Gtk.Image.new_from_icon_name("application-x-executable-symbolic")
            
            icon.set_pixel_size(256)
            overlay.set_child(icon)
            
            # Добавляем галочку если это последний выполненный скрипт
            if script_name == self.last_executed_script:
                check = Gtk.Image.new_from_icon_name("emblem-ok-symbolic")
                check.set_pixel_size(32)
                check.set_css_classes(["success-check"])
                
                # Позиционируем в левом верхнем углу
                align = Gtk.Overlay()
                align.set_child(check)
                align.set_valign(Gtk.Align.START)
                align.set_halign(Gtk.Align.START)
                align.set_margin_start(5)
                align.set_margin_top(5)
                
                overlay.add_overlay(align)
            
            vbox.append(overlay)
            
            # Название скрипта с увеличенным шрифтом
            label = Gtk.Label(label=script_name)
            label.set_css_classes(["script-label"])
            label.set_hexpand(True)
            label.set_max_width_chars(20)
            label.set_ellipsize(Pango.EllipsizeMode.END)
            label.set_size_request(256, -1)
            vbox.append(label)
            
            self.flow_box.insert(button, -1)

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
        self.progress_dialog = Gtk.Dialog(transient_for=self.win)
        self.progress_dialog.set_title("Выполнение скрипта")
        self.progress_dialog.set_default_size(500, 150)
        
        content = self.progress_dialog.get_content_area()
        content.set_orientation(Gtk.Orientation.VERTICAL)
        content.set_spacing(15)
        content.set_margin_top(25)
        content.set_margin_bottom(25)
        content.set_margin_start(25)
        content.set_margin_end(25)
        
        # Индикатор выполнения
        self.progress_bar = Gtk.ProgressBar()
        self.progress_bar.set_show_text(True)
        self.progress_bar.set_fraction(0.0)
        self.progress_bar.set_valign(Gtk.Align.CENTER)
        self.progress_bar.add_css_class("progress-text")
        content.append(self.progress_bar)
        
        self.progress_label = Gtk.Label(label="Запуск скрипта...")
        content.append(self.progress_label)
        
        self.progress_dialog.add_button("Отмена", Gtk.ResponseType.CANCEL)
        self.progress_dialog.connect("response", self.on_dialog_response)
        
        self.progress_dialog.show()
        
        thread = threading.Thread(target=self.run_script, args=(script_path,))
        thread.daemon = True
        thread.start()

    def run_script(self, script_path):
        script_name = os.path.splitext(os.path.basename(script_path))[0]
        
        def update_progress(percent, message, is_error=False):
            self.progress_bar.set_fraction(percent / 100)
            self.progress_bar.set_text(f"{percent}%")
            self.progress_label.set_label(message)
            
            if is_error:
                # Добавляем красную галочку при ошибке
                self.mark_script_as_completed(script_name, success=False)
        
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
                # Сохраняем последний выполненный скрипт
                with open(self.last_script_file, 'w') as f:
                    f.write(script_name)
                
                GLib.idle_add(self.script_completed, script_name)
            else:
                error = process.stderr.read()
                GLib.idle_add(update_progress, 100, f"Ошибка: {error or 'Неизвестная ошибка'}", True)
                
        except Exception as e:
            GLib.idle_add(update_progress, 100, f"Ошибка выполнения: {str(e)}", True)

    def mark_script_as_completed(self, script_name, success=True):
        self.last_executed_script = script_name if success else ""
        self.refresh_scripts()

    def script_completed(self, script_name):
        # Помечаем скрипт как успешно выполненный
        self.mark_script_as_completed(script_name)
        
        # Закрываем диалог
        self.progress_dialog.destroy()

    def on_dialog_response(self, dialog, response):
        if response == Gtk.ResponseType.CANCEL:
            dialog.destroy()

if __name__ == "__main__":
    app = ScriptLauncherApp()
    app.run(None)