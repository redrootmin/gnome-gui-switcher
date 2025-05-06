#!/usr/bin/env python3
#creator by RedRoot(Yaciyna Mikhail) for GAMER STATION [on linux] and Gaming Community OS Linux
# GPL-3.0 License 


import gi
import os
import subprocess
from pathlib import Path

gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, GdkPixbuf

class SmartScriptLauncher(Gtk.Window):
    def __init__(self):
        Gtk.Window.__init__(self, title="Умный запуск скриптов")
        self.set_border_width(20)
        self.set_default_size(800, 400)

        # Пути к папкам
        self.scripts_dir = os.path.join(os.path.dirname(__file__), "scripts")
        self.icons_dir = os.path.join(os.path.dirname(__file__), "icons")
        
        # Создаем папки если их нет
        os.makedirs(self.scripts_dir, exist_ok=True)
        os.makedirs(self.icons_dir, exist_ok=True)

        # Основной контейнер
        self.grid = Gtk.Grid()
        self.grid.set_column_spacing(15)
        self.grid.set_row_spacing(15)
        self.add(self.grid)

        self.load_scripts()

    def load_scripts(self):
        # Очищаем сетку перед обновлением
        for child in self.grid.get_children():
            self.grid.remove(child)

        # Получаем список скриптов
        scripts = []
        for file in Path(self.scripts_dir).glob("*.sh"):
            script_name = file.stem
            icon_path = os.path.join(self.icons_dir, f"{script_name}.png")
            scripts.append((script_name, file, icon_path))

        if not scripts:
            label = Gtk.Label(label="Не найдено скриптов в папке 'scripts'")
            self.grid.attach(label, 0, 0, 1, 1)
            return

        # Создаем кнопки для каждого скрипта
        for i, (name, script_path, icon_path) in enumerate(scripts):
            button = self.create_script_button(name, script_path, icon_path)
            self.grid.attach(button, i % 4, i // 4, 1, 1)

        # Кнопка обновления
        refresh_btn = Gtk.Button(label="Обновить список")
        refresh_btn.connect("clicked", self.on_refresh_clicked)
        self.grid.attach(refresh_btn, 0, (len(scripts) // 4) + 1, 4, 1)

        self.show_all()

    def create_script_button(self, name, script_path, icon_path):
        button = Gtk.Button(label=name.capitalize())
        button.set_tooltip_text(f"Запуск {name}.sh\n{script_path}")

        # Пытаемся загрузить иконку
        if os.path.exists(icon_path):
            try:
                pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_size(icon_path, 64, 64)
                image = Gtk.Image.new_from_pixbuf(pixbuf)
            except:
                image = Gtk.Image.new_from_icon_name("application-x-executable", Gtk.IconSize.DIALOG)
        else:
            image = Gtk.Image.new_from_icon_name("application-x-executable", Gtk.IconSize.DIALOG)
        
        button.set_image(image)
        button.set_always_show_image(True)
        button.set_image_position(Gtk.PositionType.TOP)
        button.connect("clicked", self.on_script_clicked, script_path)
        
        return button

    def on_script_clicked(self, button, script_path):
        try:
            result = subprocess.run(
                ["bash", str(script_path)],
                check=True,
                capture_output=True,
                text=True
            )
            
            output = result.stdout.strip() or "Скрипт выполнен успешно"
            self.show_dialog("Результат", output, Gtk.MessageType.INFO)
            
        except subprocess.CalledProcessError as e:
            error_msg = f"Ошибка в скрипте {script_path.name}:\n{e.stderr.strip() or str(e)}"
            self.show_dialog("Ошибка", error_msg, Gtk.MessageType.ERROR)

    def on_refresh_clicked(self, button):
        self.load_scripts()

    def show_dialog(self, title, message, message_type):
        dialog = Gtk.MessageDialog(
            parent=self,
            flags=0,
            message_type=message_type,
            buttons=Gtk.ButtonsType.OK,
            text=title
        )
        dialog.format_secondary_text(message)
        dialog.run()
        dialog.destroy()

win = SmartScriptLauncher()
win.connect("destroy", Gtk.main_quit)
win.show_all()
Gtk.main()