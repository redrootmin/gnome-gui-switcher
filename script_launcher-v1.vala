// Файл: script_launcher.vala
// Компиляция: valac --pkg gtk4 --pkg posix --pkg gio-2.0 script_launcher.vala -o script_launcher

using Gtk;

using GLib;

using Posix;

using Gio;  // Для работы с файлами и подпроцессами

public class ScriptLauncherApp : Gtk.Application {  // Явно указываем Gtk.Application
    // Конфигурационные параметры
    private const string INSTALLED_LABEL = "УСТАНОВЛЕНО";
    private const string ERROR_LABEL = "ОШИБКА";
    private const string LOG_BUTTON_LABEL = "Журнал";
    private const string LOG_FILE = "launcher.log";
    private const string THEME_FILE = "last_theme";
    private const int LOG_MAX_SIZE = 1 * 1024 * 1024; // 1 MB
    
    private string base_dir;
    private string script_dir;
    private string icon_dir;
    private string last_script_file;
    private string current_theme = "dark";
    private string last_executed_script = "";
    
    private Window main_window;
    private FlowBox flow_box;
    private Label status_label;
    private ProgressDialog progress_dialog;
    private Switch theme_switcher;
    private File log_file;
    
    public ScriptLauncherApp() {
        Object(
            application_id: "com.github.script_launcher",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }
    
    protected override void startup() {
        base.startup();
        
        // Определение базовой директории
        base_dir = Environment.get_current_dir();
        script_dir = Path.build_path(Path.DIR_SEPARATOR_S, base_dir, "scripts");
        icon_dir = Path.build_path(Path.DIR_SEPARATOR_S, base_dir, "icons");
        last_script_file = Path.build_path(Path.DIR_SEPARATOR_S, base_dir, "last_script");
        log_file = File.new_for_path(Path.build_path(Path.DIR_SEPARATOR_S, base_dir, LOG_FILE));
        
        // Создание необходимых директорий
        DirUtils.create(script_dir, 0755);
        DirUtils.create(icon_dir, 0755);
        
        // Загрузка сохраненных состояний
        load_last_script();
        load_theme_state();
        
        // Настройка темы
        var settings = Settings.get_default();
        settings.gtk_application_prefer_dark_theme = (current_theme == "dark");
        
        // Создание главного окна
        main_window = new Window();
        main_window.title = "Alt-ggs(alfa)";
        main_window.set_default_size(1280, 800);
        main_window.set_application(this);
        
        var main_box = new Box(Orientation.VERTICAL, 6);
        main_window.set_child(main_box);
        
        // Контейнер для скриптов с прокруткой
        var scrolled = new ScrolledWindow();
        scrolled.vexpand = true;
        main_box.append(scrolled);
        
        flow_box = new FlowBox();
        flow_box.selection_mode = SelectionMode.NONE;
        flow_box.max_children_per_line = 4;
        flow_box.homogeneous = true;
        scrolled.child = flow_box;
        
        // Нижняя панель управления
        var bottom_box = new Box(Orientation.HORIZONTAL, 12);
        bottom_box.margin_top = 10;
        bottom_box.margin_bottom = 10;
        bottom_box.halign = Align.CENTER;
        main_box.append(bottom_box);
        
        // Кнопка обновления
        var refresh_btn = new Button.with_label("Обновить");
        refresh_btn.clicked.connect(refresh_scripts);
        bottom_box.append(refresh_btn);
        
        // Переключатель темы
        var theme_box = new Box(Orientation.HORIZONTAL, 6);
        
        var sun_icon = new Image.from_icon_name("weather-clear-symbolic");
        sun_icon.pixel_size = 16;
        theme_box.append(sun_icon);
        
        theme_switcher = new Switch();
        theme_switcher.active = (current_theme == "dark");
        theme_switcher.state_set.connect(on_theme_toggled);
        theme_box.append(theme_switcher);
        
        var moon_icon = new Image.from_icon_name("weather-clear-night-symbolic");
        moon_icon.pixel_size = 16;
        theme_box.append(moon_icon);
        
        bottom_box.append(theme_box);
        
        // Кнопка журнала
        var log_btn = new Button.with_label(LOG_BUTTON_LABEL);
        log_btn.clicked.connect(show_log_window);
        bottom_box.append(log_btn);
        
        // Кнопка выхода
        var quit_btn = new Button.with_label("Выход");
        quit_btn.clicked.connect(() => { main_window.close(); });
        bottom_box.append(quit_btn);
        
        // Статусная строка
        status_label = new Label("");
        status_label.margin_top = 5;
        status_label.margin_bottom = 5;
        main_box.append(status_label);
        
        // Настройка CSS
        setup_styles();
        
        // Загрузка скриптов
        refresh_scripts();
        
        // Показ главного окна
        main_window.present();
    }
    
    private void setup_styles() {
        var provider = new CssProvider();
        
        string style = """
            .script-label {
                font-size: 24px;
                font-weight: bold;
                margin-top: 8px;
            }
            
            .installed-label {
                background-color: rgba(76, 175, 80, 0.8);
                color: white;
                font-weight: bold;
                padding: 4px 8px;
                border-radius: 4px;
            }
            
            .error-label {
                background-color: rgba(244, 67, 54, 0.8);
                color: white;
                font-weight: bold;
                padding: 4px 8px;
                border-radius: 4px;
            }
            
            progressbar {
                min-height: 32px;
            }
            
            progressbar trough {
                min-height: 32px;
                background-color: #e0e0e0;
            }
            
            progressbar progress {
                min-height: 32px;
                background-color: #2196F3;
            }
            
            .progress-text {
                font-size: 14px;
                font-weight: bold;
            }
            
            .script-button {
                padding: 0;
                margin: 0;
                border: none;
                background: none;
            }
            
            .script-button:hover {
                background-color: rgba(255, 255, 255, 0.1);
            }
            
            .log-window {
                padding: 10px;
            }
            
            .log-text {
                font-family: monospace;
                font-size: 12px;
            }
        """;
        
        provider.load_from_data(style.data);
        StyleContext.add_provider_for_display(
            Display.get_default(),
            provider,
            STYLE_PROVIDER_PRIORITY_APPLICATION
        );
    }
    
    private void load_last_script() {
        if (FileUtils.test(last_script_file, FileTest.EXISTS)) {
            try {
                string contents;
                FileUtils.get_contents(last_script_file, out contents);
                last_executed_script = contents.strip();
            } catch (Error e) {
                stderr.printf("Ошибка загрузки последнего скрипта: %s\n", e.message);
            }
        }
    }
    
    private void save_last_script(string script_name) {
        try {
            FileUtils.set_contents(last_script_file, script_name);
            last_executed_script = script_name;
        } catch (Error e) {
            stderr.printf("Ошибка сохранения скрипта: %s\n", e.message);
        }
    }
    
    private void load_theme_state() {
        string theme_file = Path.build_path(Path.DIR_SEPARATOR_S, base_dir, THEME_FILE);
        if (FileUtils.test(theme_file, FileTest.EXISTS)) {
            try {
                string contents;
                FileUtils.get_contents(theme_file, out contents);
                current_theme = contents.strip();
            } catch (Error e) {
                stderr.printf("Ошибка загрузки темы: %s\n", e.message);
            }
        }
    }
    
    private void save_theme_state() {
        string theme_file = Path.build_path(Path.DIR_SEPARATOR_S, base_dir, THEME_FILE);
        try {
            FileUtils.set_contents(theme_file, current_theme);
        } catch (Error e) {
            stderr.printf("Ошибка сохранения темы: %s\n", e.message);
        }
    }
    
    private bool on_theme_toggled(bool state) {
        var settings = Settings.get_default();
        settings.gtk_application_prefer_dark_theme = state;
        current_theme = state ? "dark" : "light";
        save_theme_state();
        return false;
    }
    
    private void refresh_scripts() {
        // Очистка текущего списка
        while (flow_box.get_first_child() != null) {
            flow_box.remove(flow_box.get_first_child());
        }
        
        // Проверка существования директории
        if (!FileUtils.test(script_dir, FileTest.IS_DIR)) {
            status_label.label = "Папка скриптов не найдена: " + script_dir;
            return;
        }
        
        try {
            var dir = Dir.open(script_dir);
            string? name;
            int count = 0;
            
            while ((name = dir.read_name()) != null) {
                if (name.has_suffix(".sh")) {
                    count++;
                    add_script_button(name);
                }
            }
            
            status_label.label = "Найдено скриптов: %d".printf(count);
        } catch (Error e) {
            status_label.label = "Ошибка чтения скриптов: " + e.message;
        }
    }
    
    private void add_script_button(string script_file) {
        string script_name = script_file[0:-3]; // Удаляем расширение .sh
        
        var button = new Button();
        button.add_css_class("script-button");
        button.clicked.connect(() => {
            execute_script(script_file);
        });
        
        var vbox = new Box(Orientation.VERTICAL, 0);
        button.child = vbox;
        
        var overlay = new Overlay();
        vbox.append(overlay);
        
        // Загрузка иконки
        string icon_path = Path.build_path(Path.DIR_SEPARATOR_S, icon_dir, script_name + ".png");
        Image icon;
        
        if (FileUtils.test(icon_path, FileTest.EXISTS)) {
            try {
                icon = new Image.from_file(icon_path);
            } catch (Error e) {
                icon = new Image.from_icon_name("application-x-executable-symbolic");
            }
        } else {
            icon = new Image.from_icon_name("application-x-executable-symbolic");
        }
        
        icon.pixel_size = 256;
        overlay.child = icon;
        
        // Добавление статуса установки
        if (script_name == last_executed_script) {
            var status_label = new Label(INSTALLED_LABEL);
            status_label.add_css_class("installed-label");
            
            var align = new Overlay();
            align.child = status_label;
            align.valign = Align.START;
            align.halign = Align.START;
            align.margin_start = 5;
            align.margin_top = 5;
            
            overlay.add_overlay(align);
        }
        
        // Название скрипта
        var label = new Label(script_name);
        label.add_css_class("script-label");
        label.hexpand = true;
        label.max_width_chars = 20;
        label.ellipsize = Pango.EllipsizeMode.END;
        vbox.append(label);
        
        flow_box.append(button);
    }
    
    private void execute_script(string script_file) {
        string script_path = Path.build_path(Path.DIR_SEPARATOR_S, script_dir, script_file);
        
        // Проверка существования файла
        if (!FileUtils.test(script_path, FileTest.EXISTS)) {
            show_error("Скрипт не найден: " + script_path);
            return;
        }
        
        // Проверка прав на выполнение
        if (FileUtils.test(script_path, FileTest.IS_EXECUTABLE)) {
            show_progress_dialog(script_file);
        } else {
            try {
                // Установка прав на выполнение
                FileUtils.chmod(script_path, 0755);
                show_progress_dialog(script_file);
            } catch (Error e) {
                show_error("Не удалось установить права на выполнение: " + e.message);
            }
        }
    }
    
    private void show_progress_dialog(string script_file) {
        progress_dialog = new ProgressDialog(main_window, script_file);
        progress_dialog.run_async.begin((obj, res) => {
            bool success = progress_dialog.run_async.end(res);
            if (success) {
                save_last_script(script_file[0:-3]);
                refresh_scripts();
            }
            progress_dialog.destroy();
        });
    }
    
    private void show_error(string message) {
        var dialog = new MessageDialog(
            main_window,
            DialogFlags.MODAL,
            MessageType.ERROR,
            ButtonsType.OK,
            message
        );
        
        dialog.response.connect((id) => {
            dialog.destroy();
        });
        
        dialog.present();
    }
    
    private void show_log_window() {
        var dialog = new Dialog();
        dialog.title = "Журнал программы";
        dialog.set_default_size(800, 600);
        dialog.set_transient_for(main_window);
        dialog.set_modal(true);
        
        var content = dialog.get_content_area();
        content.orientation = Orientation.VERTICAL;
        
        var scrolled = new ScrolledWindow();
        scrolled.vexpand = true;
        content.append(scrolled);
        
        var text_view = new TextView();
        text_view.editable = false;
        text_view.cursor_visible = false;
        text_view.wrap_mode = WrapMode.WORD_CHAR;
        text_view.add_css_class("log-text");
        scrolled.child = text_view;
        
        // Загрузка логов
        try {
            string log_content;
            FileUtils.get_contents(log_file.get_path(), out log_content);
            text_view.buffer.text = log_content;
        } catch (Error e) {
            text_view.buffer.text = "Ошибка загрузки журнала: " + e.message;
        }
        
        var close_btn = new Button.with_label("Закрыть");
        close_btn.clicked.connect(() => { dialog.destroy(); });
        content.append(close_btn);
        
        dialog.present();
    }
    
    private void log_message(string message) {
        try {
            // Ротация логов
            if (log_file.query_info("standard::size", 0).get_size() > LOG_MAX_SIZE) {
                var backup = File.new_for_path(log_file.get_path() + ".1");
                if (backup.query_exists()) backup.delete();
                log_file.move(backup, 0);
            }
            
            // Добавление записи
            var now = new DateTime.now_local();
            string timestamp = now.format("%Y-%m-%d %H:%M:%S");
            
            var output_stream = log_file.append_to(FileCreateFlags.NONE);
            var data_stream = new DataOutputStream(output_stream);
            data_stream.put_string("[%s] %s\n".printf(timestamp, message));
        } catch (Error e) {
            stderr.printf("Ошибка записи в лог: %s\n", e.message);
        }
    }
    
    public static int main(string[] args) {
        var app = new ScriptLauncherApp();
        return app.run(args);
    }
}

class ProgressDialog : Dialog {
    private ProgressBar progress_bar;
    private Label progress_label;
    private string script_file;
    private Thread<void> thread;
    private bool cancelled = false;
    
    public ProgressDialog(Window parent, string script_file) {
        Object(
            transient_for: parent,
            title: "Выполнение скрипта",
            default_width: 500,
            default_height: 150
        );
        
        this.script_file = script_file;
        
        var content = get_content_area();
        content.orientation = Orientation.VERTICAL;
        content.spacing = 15;
        content.margin_top = 25;
        content.margin_bottom = 25;
        content.margin_start = 25;
        content.margin_end = 25;
        
        // Прогресс-бар
        progress_bar = new ProgressBar();
        progress_bar.show_text = true;
        progress_bar.fraction = 0.0;
        progress_bar.valign = Align.CENTER;
        progress_bar.add_css_class("progress-text");
        content.append(progress_bar);
        
        // Метка статуса
        progress_label = new Label("Запуск скрипта...");
        content.append(progress_label);
        
        // Кнопка отмены
        add_button("Отмена", ResponseType.CANCEL);
        response.connect(on_response);
    }
    
    private void on_response(int response_id) {
        if (response_id == ResponseType.CANCEL) {
            cancelled = true;
            if (thread != null) {
                thread.join();
            }
        }
    }
    
    public async bool run_async() {
        // Показ диалога
        present();
        
        // Запуск скрипта в отдельном потоке
        thread = new Thread<void>("script-thread", () => {
            run_script.begin();
        });
        
        // Ожидание завершения потока
        while (thread.is_alive()) {
            Timeout.add(100, () => {
                if (!thread.is_alive()) {
                    run_async.callback();
                }
                return thread.is_alive();
            });
            
            yield;
        }
        
        return !cancelled;
    }
    
    private async void run_script() {
        string script_path = Path.build_path(
            Path.DIR_SEPARATOR_S, 
            ((ScriptLauncherApp) application).script_dir, 
            script_file
        );
        
        try {
            var process = new Subprocess(
                SubprocessFlags.STDOUT_PIPE | SubprocessFlags.STDERR_PIPE,
                "bash", script_path
            );
            
            var stdout = new DataInputStream(process.get_stdout_pipe());
            string? line;
            
            while ((line = yield stdout.read_line_async()) != null) {
                if (cancelled) {
                    process.send_signal(Posix.Signal.INT);
                    break;
                }
                
                int percent = 0;
                if (int.try_parse(line, out percent)) {
                    Idle.add(() => {
                        progress_bar.fraction = percent / 100.0;
                        progress_bar.text = "%d%%".printf(percent);
                        progress_label.label = "Выполнение: %d%%".printf(percent);
                        return false;
                    });
                }
            }
            
            // Ожидание завершения процесса
            yield process.wait_async();
            
            if (process.get_exit_status() == 0) {
                Idle.add(() => {
                    progress_label.label = "Скрипт успешно выполнен!";
                    return false;
                });
            } else {
                var stderr = new DataInputStream(process.get_stderr_pipe());
                string error = yield stderr.read_until_async("\0", -1);
                
                Idle.add(() => {
                    progress_bar.text = "Ошибка";
                    progress_label.label = error ?? "Неизвестная ошибка";
                    return false;
                });
            }
        } catch (Error e) {
            Idle.add(() => {
                progress_bar.text = "Ошибка";
                progress_label.label = e.message;
                return false;
            });
        }
    }
}
