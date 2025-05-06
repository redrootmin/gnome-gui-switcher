#!/usr/bin/env python3
#creator by RedRoot(Yaciyna Mikhail) for GAMER STATION [on linux] and Gaming Community OS Linux
# GPL-3.0 License 

import gi
import subprocess
import threading
import sys
import json
from pathlib import Path
from datetime import datetime

# ======================= НАСТРОЙКИ =======================
APP_NAME = "Script Launcher"
APP_ID = "com.example.scriptlauncher"
VERSION = "1.0"

BASE_DIR = Path(__file__).parent.resolve()
SCRIPTS_DIR = BASE_DIR / "scripts"
ICONS_DIR = BASE_DIR / "icons"
LAST_RUN_FILE = BASE_DIR / "last_script_run.json"
# =========================================================

gi.require_version("Gtk", "4.0")
from gi.repository import Gtk, GdkPixbuf, GLib, Gdk

class ScriptInfoDialog(Gtk.Window):
    def __init__(self, parent, script_name, script_path):
        super().__init__(transient_for=parent, title=f"Информация: {script_name}")
        self.set_default_size(500, 400)
        
        # Пути к файлам
        info_file = script_path.with_name(f"{script_path.stem}_info")
        big_icon = ICONS_DIR / f"{script_path.stem}_big.png"
        
        # Основной контейнер
        self.main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        self.main_box.set_margin_top(10)
        self.main_box.set_margin_bottom(10)
        self.main_box.set_margin_start(10)
        self.main_box.set_margin_end(10)
        self.set_child(self.main_box)
        
        # Большая иконка
        try:
            if big_icon.exists():
                pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_size(str(big_icon), 512, 512)
                self.icon = Gtk.Image.new_from_pixbuf(pixbuf)
            else:
                self.icon = Gtk.Image.new_from_icon_name("application-x-executable-symbolic")
                self.icon.set_pixel_size(256)
        except Exception as e:
            print(f"Ошибка загрузки иконки: {e}", file=sys.stderr)
            self.icon = Gtk.Image.new_from_icon_name("dialog-error-symbolic")
        
        # Текст информации
        self.info_text = Gtk.TextView()
        self.info_text.set_editable(False)
        self.info_text.set_wrap_mode(Gtk.WrapMode.WORD)
        
        if info_file.exists():
            try:
                with open(info_file, 'r', encoding='utf-8') as f:
                    self.info_text.get_buffer().set_text(f.read())
            except Exception as e:
                print(f"Ошибка чтения файла информации: {e}", file=sys.stderr)
                self.info_text.get_buffer().set_text("Ошибка загрузки информации")
        else:
            self.info_text.get_buffer().set_text("Файл информации не найден")
        
        # Кнопки действий
        btn_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        btn_box.set_halign(Gtk.Align.END)
        
        self.install_btn = Gtk.Button(label="Установить")
        self.install_btn.connect("clicked", self.on_install_clicked)
        
        cancel_btn = Gtk.Button(label="Закрыть")
        cancel_btn.connect("clicked", lambda btn: self.close())
        
        btn_box.append(cancel_btn)
        btn_box.append(self.install_btn)
        
        # Упаковка элементов
        scroll = Gtk.ScrolledWindow()
        scroll.set_child(self.info_text)
        
        self.main_box.append(self.icon)
        self.main_box.append(scroll)
        self.main_box.append(btn_box)
        
        self.script_path = script_path
    
    def on_install_clicked(self, button):
        ProgressWindow(self, self.script_path.stem, self.script_path)
        self.close()

class ProgressWindow(Gtk.Window):
    def __init__(self, parent, script_name, script_path):
        super().__init__(transient_for=parent, title=f"Установка: {script_name}")
        self.set_default_size(400, 120)
        
        self.script_path = script_path
        self.script_name = script_name
        
        self.progress = Gtk.ProgressBar()
        self.progress.set_show_text(True)
        self.progress.set_fraction(0.0)
        
        self.status_label = Gtk.Label()
        self.status_label.set_margin_top(10)
        
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        box.set_margin_top(20)
        box.set_margin_bottom(20)
        box.set_margin_start(20)
        box.set_margin_end(20)
        box.append(self.progress)
        box.append(self.status_label)
        
        self.set_child(box)
        self.present()
        
        # Запуск скрипта в отдельном потоке
        self.thread = threading.Thread(
            target=self.execute_script,
            daemon=True
        )
        self.thread.start()

    def execute_script(self):
        try:
            process = subprocess.Popen(
                ["bash", str(self.script_path)],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                bufsize=1,
                encoding='utf-8'
            )

            while True:
                output = process.stdout.readline()
                if output == '' and process.poll() is not None:
                    break
                if output:
                    try:
                        percent = int(output.strip())
                        GLib.idle_add(self.update_progress, percent, "")
                    except ValueError:
                        GLib.idle_add(self.update_status, output.strip())

            process.wait()
            GLib.idle_add(self.script_finished, process.returncode)
        except Exception as e:
            GLib.idle_add(self.update_status, f"Ошибка: {str(e)}")

    def update_progress(self, percent, message):
        fraction = percent / 100.0
        self.progress.set_fraction(fraction)
        self.progress.set_text(f"{percent}%")
        if message:
            self.status_label.set_text(message)

    def update_status(self, message):
        self.status_label.set_text(message)

    def script_finished(self, returncode):
        if returncode == 0:
            self.update_status("Установка завершена успешно!")
            self.progress.set_fraction(1.0)
            self.save_last_run()
        else:
            self.update_status("Ошибка установки!")
        GLib.timeout_add_seconds(3, self.close)

    def save_last_run(self):
        data = {
            "script": self.script_path.name,
            "timestamp": datetime.now().isoformat(),
            "name": self.script_name
        }
        try:
            with open(LAST_RUN_FILE, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
        except Exception as e:
            print(f"Ошибка сохранения истории: {e}", file=sys.stderr)

class ScriptLauncher(Gtk.Application):
    def __init__(self):
        super().__init__(application_id=APP_ID)
        self.last_run_script = None
        SCRIPTS_DIR.mkdir(exist_ok=True)
        ICONS_DIR.mkdir(exist_ok=True)
        self.load_last_run()

    def load_last_run(self):
        if LAST_RUN_FILE.exists():
            try:
                with open(LAST_RUN_FILE, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    self.last_run_script = data.get("script")
            except Exception as e:
                print(f"Ошибка чтения файла истории: {e}", file=sys.stderr)
                self.last_run_script = None

    def do_activate(self):  # Исправленная версия без параметра app
        self.win = Gtk.ApplicationWindow(application=self)
        self.win.set_title(APP_NAME)
        self.win.set_default_size(800, 600)

        # Главный контейнер
        self.main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self.win.set_child(self.main_box)

        # HeaderBar
        self.header = Gtk.HeaderBar()
        self.main_box.append(self.header)

        # Кнопка обновления
        self.refresh_btn = Gtk.Button()
        self.refresh_btn.set_icon_name("view-refresh-symbolic")
        self.refresh_btn.set_tooltip_text("Обновить список скриптов")
        self.refresh_btn.connect("clicked", self.reload_scripts)
        self.header.pack_start(self.refresh_btn)

        # ScrolledWindow
        self.scrolled = Gtk.ScrolledWindow()
        self.scrolled.set_hexpand(True)
        self.scrolled.set_vexpand(True)
        self.main_box.append(self.scrolled)

        # FlowBox для кнопок скриптов
        self.flowbox = Gtk.FlowBox()
        self.flowbox.set_selection_mode(Gtk.SelectionMode.NONE)
        self.flowbox.set_max_children_per_line(3)
        self.flowbox.set_column_spacing(20)
        self.flowbox.set_row_spacing(20)
        self.flowbox.set_margin_top(20)
        self.flowbox.set_margin_bottom(20)
        self.flowbox.set_margin_start(20)
        self.flowbox.set_margin_end(20)
        self.scrolled.set_child(self.flowbox)

        self.load_scripts()
        self.win.present()

    def load_scripts(self):
        while child := self.flowbox.get_first_child():
            self.flowbox.remove(child)

        scripts = list(SCRIPTS_DIR.glob("*.sh"))
        
        if not scripts:
            label = Gtk.Label(label=f"Добавьте скрипты в папку:\n{SCRIPTS_DIR}")
            label.set_wrap(True)
            self.flowbox.append(label)
            return

        scripts_sorted = sorted(scripts, key=lambda x: 0 if x.name == self.last_run_script else 1)

        for script in scripts_sorted:
            icon = ICONS_DIR / f"{script.stem}.png"
            btn = self.create_script_button(script.stem, script, icon)
            self.flowbox.append(btn)

    def create_script_button(self, name, script_path, icon_path):
        btn = Gtk.Button()
        btn.set_size_request(200, 250)
        btn.set_css_classes(["flat", "circular"])
        
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        
        icon_box = Gtk.Overlay()
        icon_box.set_size_request(256, 256)
        
        try:
            if icon_path.exists():
                pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_size(str(icon_path), 256, 256)
                img = Gtk.Image.new_from_pixbuf(pixbuf)
            else:
                img = Gtk.Image.new_from_icon_name("application-x-executable-symbolic")
                img.set_pixel_size(256)
        except Exception as e:
            print(f"Ошибка загрузки иконки: {e}", file=sys.stderr)
            img = Gtk.Image.new_from_icon_name("dialog-error-symbolic")
        
        icon_box.set_child(img)
        
        if script_path.name == self.last_run_script:
            check_icon = Gtk.Image.new_from_icon_name("emblem-ok-symbolic")
            check_icon.set_pixel_size(48)
            check_icon.set_css_classes(["success-badge"])
            check_icon.set_halign(Gtk.Align.END)
            check_icon.set_valign(Gtk.Align.END)
            check_icon.set_margin_end(10)
            check_icon.set_margin_bottom(10)
            icon_box.add_overlay(check_icon)
        
        label = Gtk.Label(label=name)
        label.set_max_width_chars(15)
        label.set_ellipsize(3)
        label.set_margin_top(10)
        
        main_box.append(icon_box)
        main_box.append(label)
        btn.set_child(main_box)
        btn.set_tooltip_text(f"Просмотр информации: {script_path.name}")
        btn.connect("clicked", self.show_script_info, script_path)
        
        return btn

    def show_script_info(self, btn, script_path):
        dialog = ScriptInfoDialog(self.win, script_path.stem, script_path)
        dialog.present()

    def reload_scripts(self, btn):
        self.load_scripts()

if __name__ == "__main__":
    # CSS стили
    css = """
    .success-badge {
        color: white;
        background-color: rgba(46, 194, 126, 0.8);
        border-radius: 24px;
        padding: 6px;
    }
    """
    
    # Создаем и запускаем приложение
    app = ScriptLauncher()
    
    # Применяем CSS
    provider = Gtk.CssProvider()
    provider.load_from_data(css.encode())
    Gtk.StyleContext.add_provider_for_display(
        Gdk.Display.get_default(),
        provider,
        Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
    )
    
    app.run(sys.argv)