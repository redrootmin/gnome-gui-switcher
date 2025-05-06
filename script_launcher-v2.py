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
        Gtk.Window.__init__(self, title="alt-ggs")
        self.set_border_width(20)
        self.set_default_size(1008, 800)

        # Пути к папкам
        self.scripts_dir = os.path.join(os.path.dirname(__file__), "scripts")
        self.icons_dir = os.path.join(os.path.dirname(__file__), "icons")
       
        # Создаем папки если их нет
        os.makedirs(self.scripts_dir, exist_ok=True)
        os.makedirs(self.icons_dir, exist_ok=True)

        # Главный контейнер
        self.main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=20)
        self.add(self.main_box)

        # Сетка для кнопок скриптов
        self.grid = Gtk.Grid()
        self.grid.set_column_spacing(30)
        self.grid.set_row_spacing(30)
        self.grid.set_margin_top(20)
       
        # Scrollable area
        scrolled = Gtk.ScrolledWindow()
        scrolled.add(self.grid)
        self.main_box.pack_start(scrolled, True, True, 0)

        # Нижняя панель
        self.bottom_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=20)
        self.bottom_box.set_halign(Gtk.Align.CENTER)
        self.bottom_box.set_margin_bottom(20)
       
        # Кнопка обновления
        refresh_btn = Gtk.Button(label=" Обновить список ")
        refresh_img = Gtk.Image.new_from_icon_name("view-refresh", Gtk.IconSize.BUTTON)
        refresh_btn.set_image(refresh_img)
        refresh_btn.connect("clicked", self.on_refresh_clicked)
       
        # Кнопка выхода
        exit_btn = Gtk.Button(label=" Выход ")
        exit_img = Gtk.Image.new_from_icon_name("application-exit", Gtk.IconSize.BUTTON)
        exit_btn.set_image(exit_img)
        exit_btn.connect("clicked", Gtk.main_quit)
       
        self.bottom_box.pack_start(refresh_btn, False, False, 0)
        self.bottom_box.pack_start(exit_btn, False, False, 0)
        self.main_box.pack_end(self.bottom_box, False, False, 0)

        self.load_scripts()

    def load_scripts(self):
        # Очищаем сетку
        for child in self.grid.get_children():
            self.grid.remove(child)

        # Загружаем скрипты
        scripts = []
        for f in Path(self.scripts_dir).glob("*.sh"):
            icon_path = os.path.join(self.icons_dir, f"{f.stem}.png")
            scripts.append((f.stem, str(f), icon_path))

        if not scripts:
            label = Gtk.Label(label="Не найдено скриптов в папке 'scripts'")
            self.grid.attach(label, 0, 0, 1, 1)
            return

        for i, (name, script_path, icon_path) in enumerate(scripts):
            button = self.create_script_button(name, script_path, icon_path)
            self.grid.attach(button, i % 3, i // 3, 1, 1)

    def create_script_button(self, name, script_path, icon_path):
        button = Gtk.Button(label=name.capitalize())
        button.set_tooltip_text(f"Запуск {script_path}")
       
        # Загрузка увеличенной иконки (256x256)
        if os.path.exists(icon_path):
            try:
                pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_size(icon_path, 256, 256)
                image = Gtk.Image.new_from_pixbuf(pixbuf)
            except Exception as e:
                print(f"Ошибка загрузки иконки: {e}")
                image = Gtk.Image.new_from_icon_name("dialog-error", Gtk.IconSize.DIALOG)
        else:
            image = Gtk.Image.new_from_icon_name("application-x-executable", Gtk.IconSize.DIALOG)
       
        button.set_image(image)
        button.set_always_show_image(True)
        button.set_image_position(Gtk.PositionType.TOP)
        button.connect("clicked", self.on_script_clicked, script_path)
       
        # Устанавливаем минимальный размер
        button.set_size_request(300, 300)
        return button

    def on_script_clicked(self, button, script_path):
        try:
            result = subprocess.run(
                ["bash", script_path],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                encoding="utf-8"
            )
            output = result.stdout.strip() or "Скрипт выполнен успешно!"
            self.show_message("Результат", output, Gtk.MessageType.INFO)
        except subprocess.CalledProcessError as e:
            error_msg = f"Ошибка в {os.path.basename(script_path)}:\n{e.stderr.strip()}"
            self.show_message("Ошибка", error_msg, Gtk.MessageType.ERROR)

    def on_refresh_clicked(self, button):
        self.load_scripts()

    def show_message(self, title, text, message_type):
        dialog = Gtk.MessageDialog(
            parent=self,
            flags=0,
            message_type=message_type,
            buttons=Gtk.ButtonsType.OK,
            text=title
        )
        dialog.format_secondary_text(text)
        dialog.run()
        dialog.destroy()

if __name__ == "__main__":
    win = SmartScriptLauncher()
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    Gtk.main()