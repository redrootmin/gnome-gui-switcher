#!/usr/bin/env python3
#creator by RedRoot(Yaciyna Mikhail) for GAMER STATION [on linux] and Gaming Community OS Linux
# GPL-3.0 License 

import os
import sys
import gi
import subprocess
import threading
import logging
from logging.handlers import RotatingFileHandler

gi.require_version('Gtk', '4.0')
from gi.repository import Gtk, GLib, Pango

class ScriptLauncherApp(Gtk.Application):
    def __init__(self):
        super().__init__(application_id='com.example.ScriptLauncher')
        
        # Конфигурационные переменные
        self.INSTALLED_LABEL = "УСТАНОВЛЕНО"  # Текст метки установленного скрипта
        self.ERROR_LABEL = "ОШИБКА"          # Текст метки ошибки
        self.LOG_BUTTON_LABEL = "Журнал"     # Текст кнопки журнала
        self.LOG_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "launcher.log")
        self.THEME_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "last_theme")
        self.LOG_MAX_SIZE = 1 * 1024 * 1024  # 1 MB
        
        # Настройка системы логов
        self.setup_logging()
        
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
        self.current_theme = "dark"  # По умолчанию темная тема
        
        os.makedirs(self.script_dir, exist_ok=True)
        os.makedirs(self.icon_dir, exist_ok=True)
        self.load_last_script()
        self.load_theme_state()  # Загружаем сохраненную тему
        
        logging.info("Приложение инициализировано")

    def setup_logging(self):
        """Настройка системы логирования с ротацией логов"""
        logging.basicConfig(
            handlers=[
                RotatingFileHandler(
                    self.LOG_FILE,
                    maxBytes=self.LOG_MAX_SIZE,
                    backupCount=1,
                    encoding='utf-8'
                )
            ],
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
        logging.info("Логирование настроено")

    def load_last_script(self):
        if os.path.exists(self.last_script_file):
            with open(self.last_script_file, 'r') as f:
                self.last_executed_script = f.read().strip()
            logging.info(f"Загружен последний выполненный скрипт: {self.last_executed_script}")

    def load_theme_state(self):
        """Загрузка сохраненного состояния темы"""
        if os.path.exists(self.THEME_FILE):
            try:
                with open(self.THEME_FILE, 'r') as f:
                    self.current_theme = f.read().strip()
                    logging.info(f"Загружена тема: {self.current_theme}")
            except Exception as e:
                logging.error(f"Ошибка загрузки темы: {str(e)}")
                self.current_theme = "dark"

    def save_theme_state(self):
        """Сохранение текущего состояния темы"""
        try:
            with open(self.THEME_FILE, 'w') as f:
                f.write(self.current_theme)
            logging.info(f"Тема сохранена: {self.current_theme}")
        except Exception as e:
            logging.error(f"Ошибка сохранения темы: {str(e)}")

    def do_activate(self):
        self.win = Gtk.ApplicationWindow(application=self, title="Alt-GGS-Alfa")
        self.win.set_default_size(1280, 480)
        
        # Применяем сохраненную тему
        settings = Gtk.Settings.get_default()
        settings.set_property("gtk-application-prefer-dark-theme", self.current_theme == "dark")
        
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
        
        # Нижняя панель управления
        bottom_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
        bottom_box.set_margin_top(10)
        bottom_box.set_margin_bottom(10)
        bottom_box.set_halign(Gtk.Align.CENTER)
        main_box.append(bottom_box)
        
        # Кнопка обновления
        refresh_btn = Gtk.Button.new_with_label("Обновить")
        refresh_btn.connect("clicked", self.refresh_scripts)
        bottom_box.append(refresh_btn)
        
        # Создаем переключатель темы с иконками
        theme_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        
        # Иконка солнца (светлая тема)
        sun_icon = Gtk.Image.new_from_icon_name("weather-clear-symbolic")
        sun_icon.set_pixel_size(16)
        theme_box.append(sun_icon)
        
        # Сам переключатель
        self.theme_switcher = Gtk.Switch()
        self.theme_switcher.set_active(self.current_theme == "dark")  # Устанавливаем сохраненное состояние
        self.theme_switcher.connect("state-set", self.on_theme_toggled)
        theme_box.append(self.theme_switcher)
        
        # Иконка луны (темная тема)
        moon_icon = Gtk.Image.new_from_icon_name("weather-clear-night-symbolic")
        moon_icon.set_pixel_size(16)
        theme_box.append(moon_icon)
        
        bottom_box.append(theme_box)
        
        # Кнопка журнала (в правом углу)
        log_btn = Gtk.Button.new_with_label(self.LOG_BUTTON_LABEL)
        log_btn.connect("clicked", self.show_log_window)
        bottom_box.append(log_btn)
        
        # Кнопка выхода
        quit_btn = Gtk.Button.new_with_label("Выход")
        quit_btn.connect("clicked", lambda _: self.quit())
        bottom_box.append(quit_btn)
        
        self.status_label = Gtk.Label()
        self.status_label.set_margin_top(5)
        self.status_label.set_margin_bottom(5)
        main_box.append(self.status_label)
        
        self.refresh_scripts()
        self.win.present()
        logging.info("Главное окно отображено")

    def setup_styles(self):
        css_provider = Gtk.CssProvider()
        css_provider.load_from_data(f"""
            .script-label {{
                font-size: 24px;
                font-weight: bold;
                margin-top: 8px;
            }}
            .installed-label {{
                background-color: rgba(76, 175, 80, 0.8);
                color: white;
                font-weight: bold;
                padding: 4px 8px;
                border-radius: 4px;
            }}
            .error-label {{
                background-color: rgba(244, 67, 54, 0.8);
                color: white;
                font-weight: bold;
                padding: 4px 8px;
                border-radius: 4px;
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
            .script-button {{
                padding: 0;
                margin: 0;
                border: none;
                background: none;
            }}
            .script-button:hover {{
                background-color: rgba(255, 255, 255, 0.1);
            }}
            .log-window {{
                padding: 10px;
            }}
            .log-text {{
                font-family: monospace;
                font-size: 12px;
            }}
        """.encode())
        Gtk.StyleContext.add_provider_for_display(
            self.win.get_display(),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )
        logging.info("Стили применены")

    def on_theme_toggled(self, switch, state):
        settings = Gtk.Settings.get_default()
        settings.set_property("gtk-application-prefer-dark-theme", state)
        self.current_theme = "dark" if state else "light"
        self.setup_styles()  # Обновляем стили при смене темы
        self.save_theme_state()  # Сохраняем состояние темы
        logging.info(f"Тема изменена на {'темную' if state else 'светлую'}")

    def show_log_window(self, button):
        """Отображение окна с логами"""
        logging.info("Открытие окна журнала")
        
        log_window = Gtk.Window(title="Журнал программы")
        log_window.set_default_size(800, 600)
        log_window.set_transient_for(self.win)
        log_window.set_modal(True)
        
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        log_window.set_child(main_box)
        
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_vexpand(True)
        main_box.append(scrolled)
        
        log_text = Gtk.TextView()
        log_text.set_editable(False)
        log_text.set_cursor_visible(False)
        log_text.set_wrap_mode(Gtk.WrapMode.WORD_CHAR)
        log_text.add_css_class("log-text")
        scrolled.set_child(log_text)
        
        # Чтение лог-файла
        try:
            with open(self.LOG_FILE, 'r', encoding='utf-8') as f:
                log_content = f.read()
                buffer = log_text.get_buffer()
                buffer.set_text(log_content)
                
                # Прокрутка в конец
                end_iter = buffer.get_end_iter()
                mark = buffer.create_mark("end", end_iter, False)
                log_text.scroll_to_mark(mark, 0.0, True, 0.0, 1.0)
                
            logging.info("Журнал загружен")
        except Exception as e:
            logging.error(f"Ошибка чтения журнала: {str(e)}")
            buffer = log_text.get_buffer()
            buffer.set_text(f"Ошибка загрузки журнала: {str(e)}")
        
        # Кнопка закрытия
        close_btn = Gtk.Button.new_with_label("Закрыть")
        close_btn.connect("clicked", lambda _: log_window.destroy())
        main_box.append(close_btn)
        
        log_window.present()

    def refresh_scripts(self, button=None):
        logging.info("Обновление списка скриптов")
        while True:
            child = self.flow_box.get_first_child()
            if child is None:
                break
            self.flow_box.remove(child)
        
        self.scripts = []
        self.load_last_script()
        
        if not os.path.exists(self.script_dir):
            self.status_label.set_label(f"Папка скриптов не найдена: {self.script_dir}")
            logging.error(f"Папка скриптов не найдена: {self.script_dir}")
            return
        
        try:
            script_files = [f for f in os.listdir(self.script_dir) if f.endswith('.sh')]
            if not script_files:
                self.status_label.set_label(f"В папке нет .sh скриптов: {self.script_dir}")
                logging.warning(f"В папке нет .sh скриптов: {self.script_dir}")
                return
            
            self.status_label.set_label(f"Найдено скриптов: {len(script_files)}")
            logging.info(f"Найдено {len(script_files)} скриптов")
            
        except Exception as e:
            self.status_label.set_label(f"Ошибка чтения скриптов: {str(e)}")
            logging.error(f"Ошибка чтения скриптов: {str(e)}")
            return
        
        if not os.path.exists(self.icon_dir):
            self.status_label.set_label(f"{self.status_label.get_text()} | Папка иконок не найдена: {self.icon_dir}")
            logging.warning(f"Папка иконок не найдена: {self.icon_dir}")
        
        for script in script_files:
            script_name = os.path.splitext(script)[0]
            self.scripts.append(script_name)
            
            # Создаем кнопку с ограниченной областью клика
            button = Gtk.Button()
            button.set_has_frame(False)
            button.set_can_focus(False)
            button.add_css_class("script-button")
            button.connect("clicked", self.on_script_clicked, script)
            
            # Основной контейнер (картинка + название)
            vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
            button.set_child(vbox)
            
            # Контейнер для картинки с возможностью наложения метки
            overlay = Gtk.Overlay()
            
            # Загружаем иконку
            icon_path = os.path.join(self.icon_dir, f"{script_name}.png")
            if os.path.exists(icon_path):
                try:
                    icon = Gtk.Image.new_from_file(icon_path)
                    logging.debug(f"Загружена иконка: {icon_path}")
                except Exception as e:
                    logging.error(f"Ошибка загрузки иконки: {e}")
                    icon = Gtk.Image.new_from_icon_name("application-x-executable-symbolic")
            else:
                logging.warning(f"Иконка не найдена: {icon_path}")
                icon = Gtk.Image.new_from_icon_name("application-x-executable-symbolic")
            
            icon.set_pixel_size(256)
            overlay.set_child(icon)
            
            # Добавляем метку статуса если это последний выполненный скрипт
            if script_name == self.last_executed_script:
                status_label = Gtk.Label(label=self.INSTALLED_LABEL)
                status_label.add_css_class("installed-label")
                
                # Позиционируем в левом верхнем углу
                align = Gtk.Overlay()
                align.set_child(status_label)
                align.set_valign(Gtk.Align.START)
                align.set_halign(Gtk.Align.START)
                align.set_margin_start(5)
                align.set_margin_top(5)
                
                overlay.add_overlay(align)
                logging.debug(f"Добавлена метка статуса для скрипта: {script_name}")
            
            vbox.append(overlay)
            
            # Название скрипта
            label = Gtk.Label(label=script_name)
            label.add_css_class("script-label")
            label.set_hexpand(True)
            label.set_max_width_chars(20)
            label.set_ellipsize(Pango.EllipsizeMode.END)
            label.set_size_request(256, -1)
            vbox.append(label)
            
            self.flow_box.insert(button, -1)
        
        logging.info("Список скриптов успешно обновлен")

    def on_script_clicked(self, button, script):
        script_path = os.path.join(self.script_dir, script)
        logging.info(f"Попытка выполнения скрипта: {script}")
        
        if not os.path.exists(script_path):
            error_msg = f"Скрипт не найден: {script_path}"
            logging.error(error_msg)
            self.show_error(error_msg)
            return
        
        if not os.access(script_path, os.X_OK):
            error_msg = f"Скрипт не исполняемый: {script_path}"
            logging.error(error_msg)
            self.show_error(error_msg)
            return
            
        self.show_progress_dialog(script_path)

    def show_error(self, message):
        logging.error(f"Отображение ошибки: {message}")
        dialog = Gtk.MessageDialog(
            transient_for=self.win,
            message_type=Gtk.MessageType.ERROR,
            buttons=Gtk.ButtonsType.OK,
            text=message
        )
        dialog.connect("response", lambda d, r: d.destroy())
        dialog.show()

    def show_progress_dialog(self, script_path):
        logging.info(f"Отображение диалога прогресса для: {script_path}")
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
        logging.info("Запущен поток выполнения скрипта")

    def run_script(self, script_path):
        script_name = os.path.splitext(os.path.basename(script_path))[0]
        logging.info(f"Начато выполнение скрипта: {script_name}")
        
        def update_progress(percent, message, is_error=False):
            self.progress_bar.set_fraction(percent / 100)
            self.progress_bar.set_text(f"{percent}%")
            self.progress_label.set_label(message)
            
            if is_error:
                logging.error(f"Ошибка выполнения: {message}")
                self.mark_script_as_completed(script_name, success=False)
            else:
                logging.debug(f"Прогресс: {percent}% - {message}")
        
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
                        logging.warning(f"Некорректный вывод прогресса: {output.strip()}")
                        pass
            
            return_code = process.wait()
            
            if return_code == 0:
                logging.info(f"Скрипт выполнен успешно: {script_name}")
                # Сохраняем последний выполненный скрипт
                with open(self.last_script_file, 'w') as f:
                    f.write(script_name)
                
                GLib.idle_add(self.script_completed, script_name)
            else:
                error = process.stderr.read()
                GLib.idle_add(update_progress, 100, f"Ошибка: {error or 'Неизвестная ошибка'}", True)
                
        except Exception as e:
            logging.error(f"Исключение при выполнении скрипта: {str(e)}")
            GLib.idle_add(update_progress, 100, f"Ошибка выполнения: {str(e)}", True)

    def mark_script_as_completed(self, script_name, success=True):
        if success:
            self.last_executed_script = script_name
            logging.info(f"Скрипт помечен как установленный: {script_name}")
        else:
            self.last_executed_script = ""
            logging.error(f"Скрипт завершился с ошибкой: {script_name}")
        self.refresh_scripts()

    def script_completed(self, script_name):
        logging.info(f"Завершение обработки скрипта: {script_name}")
        # Помечаем скрипт как успешно выполненный
        self.mark_script_as_completed(script_name)
        
        # Закрываем диалог
        self.progress_dialog.destroy()
        logging.info("Диалог прогресса закрыт")

    def on_dialog_response(self, dialog, response):
        if response == Gtk.ResponseType.CANCEL:
            logging.info("Выполнение скрипта отменено пользователем")
            dialog.destroy()

if __name__ == "__main__":
    app = ScriptLauncherApp()
    app.run(None)