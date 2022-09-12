#!/bin/bash
#creator by RedRoot(Yacyna Mehail) for GAMER STATION [on linux] and Gaming Community OS Linux
# GPL-3.0 License 
# app: [GGS]gnome-gui-switcher

#определяем какая система запустила ggs
linuxos_version=`cat "/etc/os-release" | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/"//g'`
linuxos_gnome="true"

if [ ! -e /usr/bin/gnome-shell ];then linuxos_gnome="false";fi

#проверяем что система совместима с ggs
if echo "${linuxos_version}" | grep -ow "ROSA Fresh Desktop 12.2" > /dev/null && echo "${linuxos_gnome}" | grep -ow "true" > /dev/null;then
tput setaf 2;echo "Операциооная система: ${linuxos_version} [GNOME] совместима с [GGS]gnome-gui-switcher"
tput sgr 0
linuxos_run0="rosa"
export linuxos_run=$linuxos_run0
linux_os_conf0="$linuxos_run-config"
export linux_os_conf=$linux_os_conf0

else 
tput setaf 1;echo "Операциооная система: ${linuxos_version} не совместима с [GGS]gnome-gui-switcher!"
tput sgr 0
exit 1
fi

#проверяем что скрипт установки не запущен от пользователя root
if [ "$UID" -eq 0 ];then
tput setaf 1; echo "Этот скрипт не нужно запускать из под root!";tput sgr0;exit 1
else
tput setaf 2; echo "все хорошо этот скрипт не запущен из под root!"
fi

#Определение переменныех утилит и скриптов
export time_sleep="2"
pass_user0="$1"
gsettings set org.gnome.shell disable-extension-version-validation false
script_dir0=$(dirname $(readlink -f "$0"))
utils_dir0="${script_dir0}/core-utils"
version0=`cat "${script_dir0}/config/name_version"`
export utils_dir=${utils_dir0}
export version="Gnome-Gui-Switcher[${version0}]"
export script_dir=${script_dir0}
installing_status=`cat "${script_dir}/config/install-status"`
gnome_version0=`gnome-shell --version | grep -wo "42"` || gnome_version="41"
echo "${gnome_version}" > "${script_dir}/config/gnome-version"
echo "Gnome Shell ${gnome_version}"
icon1="$script_dir/icons/gnome-ext-pack48.png"
image1="$script_dir/images/ggs-logo-v1.png"
image2="$script_dir/images/ggs-in-development.png"
YAD0="${utils_dir}/yad"
zenity0="${utils_dir}/zenity"
export YAD=${YAD0}
export zenity=${zenity0}
export gnome_41_dir="${script_dir}/config/rosa-gnome41-config"
export gnome_42_dir="${script_dir}/config/rosa-gnome42-config"
export gnome_version=$gnome_version0

#определяем какая версия скрипта запущена (стабильная/тестовая)
name_script0=`basename "$0"`
name_script=`echo ${name_script0} | sed 's/\.sh\>//g'`
echo "$name_script" > "${script_dir}/config/run-script"
echo "запущен скрипт: $name_script"
#проверяем какой тип сессии (вайланд/Хорг)
if echo $XDG_SESSION_TYPE | grep -ow "x11" > /dev/null
then
# запрос пароля супер пользователя (если его не передал модуль обнавления), который дальше будет поставляться где требуется в качестве глобальной переменной, до конца работы скрипта

if [[ "${pass_user0}" == "" ]];then
pass_user0=$(GTK_THEME="Adwaita-dark" ${zenity} --entry --width=128 --height=128 --title="Запрос пароля" --text="Для работы скрипта ${version} требуется Ваш пароль superuser(root):" --hide-text)
fi

if [[ "${pass_user0}" == "" ]]
then
GTK_THEME="Adwaita-dark" ${zenity} --error --text="Пароль не введён"
exit 0
else 
export pass_user=${pass_user0}
fi
else
GTK_THEME="Adwaita-dark" ${YAD} --title="скрипт запущен в Wayland!" --image-on-top --picture --size=fit --filename="${script_dir}/images/xorg-wayland.png" --width=450 --height=327 --center --inc=256  --text-align=center --text="Данный скрипт работает только в сессии X.org" --timeout=10 --timeout-indicator=bottom
exit 0
fi

#функция для проверки пакетов на установку, если нужно установлевает
function install_package {
dpkg -s $1 | grep installed > /dev/null || echo "no installing $1 :(" | echo "$2" | sudo -S apt install -f -y $1
package_status=`dpkg -s $1 | grep -oh "installed"`
tput setaf 3;echo -n "$1:";tput setaf 2;echo "$package_status";tput sgr 0
}

installing_status=`cat "${script_dir}/config/install-status"`
if [[ "$installing_status" == "true" ]]
then
tput setaf 2
echo "Основные пакеты для ${version} уже установлены!"
tput sgr 0

else
# Проверка что существует папка bzu-gmb-temp, если нет, создаем ее
 if [ ! -d "/home/${USER}/bzu-gmb-temp" ]
 then
mkdir -p "/home/${USER}/bzu-gmb-temp"
 fi
# Проверка что существует папка autostart, если нет, создаем ее
 if [ ! -d "/home/${USER}/.config/autostart" ]
 then
mkdir -p "/home/${USER}/.config/autostart"
else
 if [ -e /home/${USER}/.config/autostart/gnome-desktop-icons-touch.desktop ] || [ -e /home/${USER}/.config/autostart/gnome-desktop-icons.desktop ];then
 rm -f /home/${USER}/.config/autostart/gnome-desktop-icons-touch.desktop
 rm -f /home/${USER}/.config/autostart/gnome-desktop-icons.desktop
 fi
fi
# Проверка что существует папка bzu-gmb-utils, если нет, создаем ее
 if [ ! -d "/home/${USER}/.local/share/bzu-gmb-utils" ]
 then
mkdir -p "/home/${USER}/.local/share/bzu-gmb-utils"
ln -s /home/$USER/.local/share/bzu-gmb-utils /home/$USER/bzu-gmb-utils
 else
   if [ ! -d "/home/$USER/bzu-gmb-utils" ];then
ln -s /home/$USER/.local/share/bzu-gmb-utils /home/$USER/bzu-gmb-utils
echo "ярлыка небыло, создаем его"
  fi
 fi
# Проверка что существует папка bzu-gmb-apps, если нет, создаем ее
 if [ ! -d "/home/${USER}/.local/share/bzu-gmb-apps" ]
 then
mkdir -p "/home/${USER}/.local/share/bzu-gmb-apps"
ln -s /home/$USER/.local/share/bzu-gmb-apps /home/$USER/bzu-gmb-apps
 else
   if [ ! -d "/home/$USER/bzu-gmb-apps" ];then
ln -s /home/$USER/.local/share/bzu-gmb-apps /home/$USER/bzu-gmb-apps
echo "ярлыка небыло, создаем его"
  fi
 fi
 
## установка темы/иконок/обои для GNOME
 if [ -e /usr/bin/gnome-shell ];then
# Проверка что существует папка c темой Adwaita-dark , если нет, создаем ее
  if [ ! -d "/usr/share/themes/Adwaita-dark/gnome-shell" ]
  then
echo "${pass_user}" | sudo -S rm -rf "/usr/share/themes/Adwaita-dark"
cd "/home/$USER/bzu-gmb-temp"
wget "https://github.com/redrootmin/bzu-gmb-modules/releases/download/v1/Adwaita-dark.tar.xz"
cd "/usr/share/themes"
echo "${pass_user}" | sudo -S tar -xpJf "/home/$USER/bzu-gmb-temp/Adwaita-dark.tar.xz"
  fi

# Проверка что существует папка c иконки numix-icons , если нет, создаем ее
  if [ ! -d "/usr/share/icons/Numix" ]
  then
#echo "${pass_user}" | sudo -S rm -rf "/usr/share/themes/Adwaita-dark"
cd "/home/$USER/bzu-gmb-temp"
wget "https://github.com/redrootmin/bzu-gmb-modules/releases/download/v1/rosa-numix-icons.tar.xz"
cd "/usr/share/icons"
echo "${pass_user}" | sudo -S tar -xpJf "/home/$USER/bzu-gmb-temp/rosa-numix-icons.tar.xz"
  fi

# Проверка что существует папки c обоями redroot wallpapers , если нет, создаем ее
  if [ ! -d "/usr/share/backgrounds" ]
  then
#echo "${pass_user}" | sudo -S rm -rf "/usr/share/themes/Adwaita-dark"
cd "/home/$USER/bzu-gmb-temp"
wget "https://github.com/redrootmin/bzu-gmb-modules/releases/download/v1/rosa-gnome-wallpapers-v1.tar.xz"
cd "/usr/share"
echo "${pass_user}" | sudo -S tar -xpJf "/home/$USER/bzu-gmb-temp/rosa-gnome-wallpapers-v1.tar.xz"
  fi

fi

##################################################################################
# установка  обновление системы
echo "${pass_user}" | sudo -S dnf --refresh distrosync -y
echo "${pass_user}" | sudo -S dnf update -y
 if [ -e /usr/bin/gnome-shell ];then
echo "${pass_user}" | sudo -S dnf remove -y gnome-robots four-in-a-row gnuchess aislerior gnome-chess gnome-mahjongg gnome-sudoku gnome-tetravex iagno lightsoff tail five-or-more gnome-klotski kmahjongg kmines klines kpat
 fi
echo "${pass_user}" | sudo -S dnf install -y inxi xow libusb-compat0.1_4 paprefs pavucontrol ananicy p7zip python3 zenity yad grub-customizer libfuse2-devel libfuse3-devel libssl1.1 neofetch git meson ninja gcc gcc-c++ cmake.i686 cmake glibc-devel dbus-devel glslang vulkan.x86_64 vulkan.i686 lib64vulkan-devel.x86_64 lib64vulkan-intel-devel.x86_64 lib64vulkan1.x86_64 libvulkan-devel.i686 libvulkan-intel-devel.i686 libvulkan1.i686
echo "${pass_user}" | sudo -S dnf autoremove -y
echo "${pass_user}" | sudo -S dnf clean packages
##################################################################################

echo "true" > "${script_dir}/config/install-status"
fi

#Проверка что существует папка extensions c доплнениями, если нет
#копируем распоковываем архив с дополнениями в папку пользователя и ребутим гном сшелл
#что бы система их увидела
if [ -d "/home/${USER}/.local/share/gnome-shell/extensions/redroot-pack" ] || [ -d "/home/${USER}/.local/share/gnome-shell/extensions/rosa-gnome42" ]
then
tput setaf 2;echo "комплект дополнений необходимый для [GGS]gnome-gui-switcher уже установлен :)"
tput sgr 0
else
#ЗАБИКАПИТЬ ДЕФОЛТНЫЕ ДОПОЛНЕНИЯ!
cd "/home/${USER}/.local/share/gnome-shell/"
tar cf - extensions | xz -z - > "extensions_old.tar.xz"
##################
if [[ ${gnome_version} == "41" ]]
then
tput setaf 1;echo "ВНИМАНИЕ: начинается установка комплекта дополнений необходимых для [GGS]gnome-gui-switcher-rosa-gnome41"
tput sgr 0
#установка дополнений необходимых для [GGS]gnome-gui-switcher gnome 41
rm -fr "/home/${USER}/.local/share/gnome-shell/extensions" || true
tar -xpJf "$script_dir/data/extensions-ggs-rosa-v1.tar.xz" -C "/home/${USER}/.local/share/gnome-shell/"
gnome_rebooting
sleep 10
else
tput setaf 1;echo "ВНИМАНИЕ: начинается установка комплекта дополнений необходимых для [GGS]gnome-gui-switcher-rosa-gnome42"
tput sgr 0
#установка дополнений необходимых для [GGS]gnome-gui-switcher gnome 42
rm -fr "/home/${USER}/.local/share/gnome-shell/extensions" || true
tar -xpJf "$script_dir/data/extensions-ggs-rosa-g42.tar.xz" -C "/home/${USER}/.local/share/gnome-shell/"
gnome_rebooting
sleep 10
fi
#################
fi

# функция перезагрузки гнома
function gnome_rebooting () {
killall -SIGQUIT gnome-shell
#killall -3 gnome-shell
}

# функция рекомендации перезагрузки системы
function ggs_rebooting () {
GTK_THEME="Adwaita-dark" ${YAD} --title="$version" --image-on-top --picture --size=fit --filename="${script_dir}/icons/gnome-ext-pack.png" --width=327 --height=327 --center --inc=256  --text-align=center --text="ТРЕБУЕТСЯ ПЕРЕАГРУЗКА GNOME, для этого нажмите alt+f2, далее введите r и нажмите inter!" --timeout=5 --timeout-indicator=bottom 
}

# функция интеграции списка избранных программ на панели
function favorite_apps () {
style_run_func="$1"
dconf write /org/gnome/shell/favorite-apps "['org.gnome.Nautilus.desktop', 'virt-manager.desktop', 'rosa-virtualbox.desktop', 'vmware-player.desktop', 'VSCodium.desktop', 'bzu-gmb.desktop', 'org.gnome.Settings.desktop', 'org.gnome.tweaks.desktop', 'pavucontrol-gtk.desktop', 'org.corectrl.corectrl.desktop', 'org.gnome.Extensions.desktop', 'org.gnome.DiskUtility.desktop', 'org.gnome.Terminal.desktop', 'gnome-system-monitor.desktop', 'org.gnome.gedit.desktop', 'org.gnome.Calculator.desktop', 'org.gnome.Screenshot.desktop', 'kde5-org.kde.krita.desktop', 'org.inkscape.Inkscape.desktop', 'nemo.desktop', 'audacious-gtk.desktop', 'audacity.desktop', 'org.shotcut.Shotcut.desktop', 'org.kde.kdenlive.desktop', 'com.obsproject.Studio.desktop', 'org.qbittorrent.qBittorrent.desktop', 'firefox.desktop', 'telegramdesktop.desktop', 'PortProton.desktop', 'protonup-qt.desktop', 'steam.desktop']"
echo "true" > "$gnome_42_dir/$style_run_func/installing"
}

# функция отключения всех дополнений
function gnome_ext_configure () {
style_run_func="$1" 
(
# отключаем все дополнения гнома и делаем паузу перед и после отключения, что бы гном успел прогрузиться
echo "отключаем все дополнения гнома и делаем паузу перед и после отключения, что бы гном успел прогрузиться"
sleep 2
readarray -t ge_list < "$gnome_42_dir/gnome-extensions-list-all";for (( i=0; i <= (${#ge_list[*]}-1); i=i+1 ));do gnome-extensions disable "${ge_list[$i]}";done
sleep 4

#сбрасываем все настройки дополнений гнома и загружем которые сохранены для выбраного стиля
echo "сбрасываем все настройки дополнений гнома и загружем которые сохранены для выбраного стиля"
dconf reset -f /org/gnome/shell/extensions/
dconf load /org/gnome/shell/extensions/ < "$gnome_42_dir/$style_run_func/extensions.conf"

# включем дополнения для выбраного стиля
echo "включем дополнения для выбраного стиля"
readarray -t ge_list < "$gnome_42_dir/$style_run_func/gnome-extensions-list-enable";for (( i=0; i <= (${#ge_list[*]}-1); i=i+1 ));do gnome-extensions enable "${ge_list[$i]}";done
sleep 2
# мягкая перезагрузка гнома и пауза что бы он смог перезагрузиться
echo "мягкая перезагрузка гнома и пауза что бы он смог перезагрузиться"
gnome_rebooting
sleep 10
#zenity --progress --title="настройка Gnome" --text="идет настройка стиля ubuntu gnome 42" --percentage=0 --no-cancel
echo "все команды для настройки стиля: $style_run_func выполнены!"
) | ${zenity} --progress --title="НАСТРОЙКА GNOME $gnome_version" --text="идет настройка стиля $style_run_func в GNOME $gnome_version, ожидайте." --percentage=0 --no-cancel --auto-close --pulsate
}

# функция включения дополнений из списка стиля/темы
#function gnome_ext_enable () {
#
#}

# функция с меню программы
function gui_app_generator () {
KEY_GUI=`echo $RANDOM`
# tabs1
GTK_THEME="Adwaita-dark" ${YAD} --plug="$KEY_GUI" --tabnum=1 --list --radiolist \
--separator=" " --search-column=4 --print-column=2 \
--column=выбор --column=Style:TEXT --column=лого:IMG \
FALSE "rosa" "$script_dir/images/$linuxos_run/rosa.png" \
FALSE "redroot" "$script_dir/images/$linuxos_run/redroot.png" \
FALSE "macos" "$script_dir/images/$linuxos_run/macos.png" \
FALSE "mint" "$script_dir/images/$linuxos_run/mint.png" \
FALSE "ubuntu" "$script_dir/images/$linuxos_run/ubuntu.png" > "$script_dir/config/style_select"&

# tabs2
GTK_THEME="Adwaita-dark" ${YAD} --plug="$KEY_GUI" --tabnum=2 --form \
--columns=2 --align-buttons --keep-icon-size --scroll \
--image="$image2" > "$script_dir/config/theme_colors"&

# tabs3
GTK_THEME="Adwaita-dark" ${YAD} --plug="$KEY_GUI" --tabnum=3 --form \
--image="$image2" > "$script_dir/config/conf_temp_gui"&

# run core-gui-app
GTK_THEME="Adwaita-dark" ${YAD} --notebook --key="$KEY_GUI" --tab="Style GUI" --tab="Theme+Colors" --tab="Config" --title="${version}-${linuxos_version}"  --window-icon="$icon1" --image="$image1" --image-on-top --width=490 --height=900 --button="Update:0" --button="Exit:1" --button="Apply:2"

select_button0="$?"
export select_button=$select_button0

style_select0=`cat "$script_dir/config/style_select"`
export style_select=$style_select0
rm -f "$script_dir/config/style_select"
theme_colors0=`cat "$script_dir/config/theme_colors"`
export theme_colors="$theme_colors0"
rm -f "$script_dir/config/theme_colors"
conf_temp_gui0=`cat "$script_dir/config/conf_temp_gui"`
export conf_temp_gui="$conf_temp_gui0"
rm -f "$script_dir/config/theme_colors"
}

# бесконечный чикл для формы программы
while true;do
gui_app_generator 

echo "select_button $select_button"
echo "style_select[$style_select]"
#exit 0
#style_case=`echo "$style_select" | sed '/^$/d'`

# включение обнавления
if [[ ${select_button} == "0" ]];then
bash "$script_dir/manual_update.sh" $pass_user $name_script
fi

#проверка на выход из программы
if [[ $style_select == "" ]] || [[ ${select_button} == "1" ]];then
exit 0
fi

if [[ ! $style_select == "" ]] && [[ ${select_button} == "2" ]];then

style_run=`echo ${style_select} | sed 's/\ \>//g'`

case "$style_run" in

"ubuntu")

if [[ "${gnome_version}" == "41" ]]
then
echo "$style_run Style RUN!"
gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,maximize,close"
gsettings set org.gnome.mutter attach-modal-dialogs false
gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark
gsettings set org.gnome.desktop.wm.preferences theme Adwaita
gsettings set org.gnome.gedit.preferences.editor scheme oblivion
gsettings set  org.gnome.desktop.interface cursor-theme elementary
gsettings set org.gnome.desktop.interface icon-theme Numix-Circle
dconf write /org/gnome/shell/favorite-apps "['bzu-gmb.desktop', 'gnome-control-center.desktop', 'org.gnome.tweaks.desktop', 'org.gnome.Extensions.desktop', 'org.gnome.DiskUtility.desktop', 'org.gnome.Terminal.desktop', 'gnome-system-monitor.desktop', 'org.gnome.gedit.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Calculator.desktop', 'org.gnome.Screenshot.desktop', 'kde5-org.kde.krita.desktop', 'org.inkscape.Inkscape.desktop', 'audacious-gtk.desktop', 'audacity.desktop', 'org.shotcut.Shotcut.desktop', 'VSCodium.desktop', 'firefox.desktop', 'telegramdesktop.desktop']"
if [ ! -f "/usr/share/backgrounds/blobs-d.svg" ]; then
echo "${pass_user}" | sudo -S cp -f "$gnome_41_dir/$style_run/blobs-d.svg" /usr/share/backgrounds/
echo "картинка добавлена в папку /usr/share/backgrounds"
else
echo "картинка есть в папке /usr/share/backgrounds"
fi
#gsettings set org.gnome.desktop.background picture-uri-dark file:////usr/share/backgrounds/canvas_by_roytanck.jpg
gsettings set org.gnome.desktop.background picture-uri file:////usr/share/backgrounds/blobs-d.svg

readarray -t ge_list < "$gnome_41_dir/gnome-extensions-list-all";for (( i=0; i <= (${#ge_list[*]}-1); i=i+1 ));do gnome-extensions disable "${ge_list[$i]}";done
sleep "$time_sleep"

dconf reset -f /org/gnome/shell/extensions/
dconf load /org/gnome/shell/extensions/ < "$gnome_41_dir/$style_run/extensions.conf"

readarray -t ge_list < "$gnome_41_dir/$style_run/gnome-extensions-list-enable";for (( i=0; i <= (${#ge_list[*]}-1); i=i+1 ));do gnome-extensions enable "${ge_list[$i]}";done
#gsettings set org.gnome.shell disable-extension-version-validation false
gnome_rebooting
sleep "$time_sleep"
else

echo "$style_run Style gnome 42 установка!"
gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,maximize,close"
gsettings set org.gnome.mutter attach-modal-dialogs false
gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark
gsettings set org.gnome.desktop.wm.preferences theme Adwaita
gsettings set org.gnome.gedit.preferences.editor scheme oblivion
gsettings set  org.gnome.desktop.interface cursor-theme elementary
gsettings set org.gnome.desktop.interface icon-theme Numix-Circle

if  echo "$gnome_42_dir/$style_run/installing" | grep -ow "false" > /dev/null
then
favorite_apps $style_run
if [ ! -f "/usr/share/backgrounds/blobs-d.svg" ]; then
echo "${pass_user}" | sudo -S cp -f "$gnome_42_dir/$style_run/blobs-d.svg" /usr/share/backgrounds/
echo "картинка добавлена в папку /usr/share/backgrounds"
else
echo "картинка есть в папке /usr/share/backgrounds"
fi
gsettings set org.gnome.desktop.background picture-uri-dark file:////usr/share/backgrounds/blobs-d.svg
gsettings set org.gnome.desktop.background picture-uri file:////usr/share/backgrounds/blobs-d.svg
fi
gnome_ext_configure $style_run
fi
;;

"macos")

if [[ "${gnome_version}" == "41" ]]
then
echo "$style_run style RUN!"
gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,maximize,close"
gsettings set org.gnome.mutter attach-modal-dialogs false
gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark
gsettings set org.gnome.desktop.wm.preferences theme Adwaita
gsettings set org.gnome.gedit.preferences.editor scheme oblivion
gsettings set  org.gnome.desktop.interface cursor-theme elementary
gsettings set org.gnome.desktop.interface icon-theme Numix-Circle
dconf write /org/gnome/shell/favorite-apps "['bzu-gmb.desktop', 'gnome-control-center.desktop', 'org.gnome.tweaks.desktop', 'org.gnome.Extensions.desktop', 'org.gnome.DiskUtility.desktop', 'org.gnome.Terminal.desktop', 'gnome-system-monitor.desktop', 'org.gnome.gedit.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Calculator.desktop', 'org.gnome.Screenshot.desktop', 'kde5-org.kde.krita.desktop', 'org.inkscape.Inkscape.desktop', 'audacious-gtk.desktop', 'audacity.desktop', 'org.shotcut.Shotcut.desktop', 'VSCodium.desktop', 'firefox.desktop', 'telegramdesktop.desktop']"
if [ ! -f "/usr/share/backgrounds/macos-12-dark.jpg" ]; then
echo "${pass_user}" | sudo -S cp -f "$gnome_41_dir/macos/macos-12-dark.jpg" /usr/share/backgrounds/
echo "картинка добавлена в папку /usr/share/backgrounds"
else
echo "картинка есть в папке /usr/share/backgrounds"
fi
#gsettings set org.gnome.desktop.background picture-uri-dark file:////usr/share/backgrounds/canvas_by_roytanck.jpg
gsettings set org.gnome.desktop.background picture-uri file:////usr/share/backgrounds/macos-12-dark.jpg

readarray -t ge_list < "$gnome_41_dir/gnome-extensions-list-all";for (( i=0; i <= (${#ge_list[*]}-1); i=i+1 ));do gnome-extensions disable "${ge_list[$i]}";done
sleep "$time_sleep"

dconf reset -f /org/gnome/shell/extensions/
dconf load /org/gnome/shell/extensions/ < "$gnome_41_dir/$style_run/extensions.conf"

readarray -t ge_list < "$gnome_41_dir/$style_run/gnome-extensions-list-enable";for (( i=0; i <= (${#ge_list[*]}-1); i=i+1 ));do gnome-extensions enable "${ge_list[$i]}";done
#gsettings set org.gnome.shell disable-extension-version-validation false
gnome_rebooting
sleep "$time_sleep"
else

echo "$style_run Style gnome 42 установка!"

gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,maximize,close"
gsettings set org.gnome.mutter attach-modal-dialogs false
gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark
gsettings set org.gnome.desktop.wm.preferences theme Adwaita
gsettings set org.gnome.gedit.preferences.editor scheme oblivion
gsettings set  org.gnome.desktop.interface cursor-theme elementary
gsettings set org.gnome.desktop.interface icon-theme Numix-Circle

if  echo "$gnome_42_dir/$style_run/installing" | grep -ow "false" > /dev/null
then
dconf write /org/gnome/shell/favorite-apps "['bzu-gmb.desktop', 'gnome-control-center.desktop', 'org.gnome.tweaks.desktop', 'org.gnome.Extensions.desktop', 'org.gnome.DiskUtility.desktop', 'org.gnome.Terminal.desktop', 'gnome-system-monitor.desktop', 'org.gnome.gedit.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Calculator.desktop', 'org.gnome.Screenshot.desktop', 'kde5-org.kde.krita.desktop', 'org.inkscape.Inkscape.desktop', 'audacious-gtk.desktop', 'audacity.desktop', 'org.shotcut.Shotcut.desktop', 'VSCodium.desktop', 'firefox.desktop', 'telegramdesktop.desktop']"
echo "true" > "$gnome_42_dir/$style_run/installing"

if [ ! -f "/usr/share/backgrounds/macos-12-dark.jpg" ]; then
echo "${pass_user}" | sudo -S cp -f "$gnome_42_dir/$style_run/macos-12-dark.jpg" /usr/share/backgrounds/
echo "картинка добавлена в папку /usr/share/backgrounds"
else
echo "картинка есть в папке /usr/share/backgrounds"
fi
gsettings set org.gnome.desktop.background picture-uri-dark file:////usr/share/backgrounds/macos-12-dark.jpg
gsettings set org.gnome.desktop.background picture-uri file:////usr/share/backgrounds/macos-12-dark.jpg

fi

gnome_ext_configure $style_run
fi
;;

"mint")

if [[ "${gnome_version}" == "41" ]]
then
echo "Linux Mint style RUN!"
gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,maximize,close"
gsettings set org.gnome.mutter attach-modal-dialogs false
gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark
gsettings set org.gnome.desktop.wm.preferences theme Adwaita
gsettings set org.gnome.gedit.preferences.editor scheme oblivion
gsettings set  org.gnome.desktop.interface cursor-theme elementary
gsettings set org.gnome.desktop.interface icon-theme Numix-Circle
dconf write /org/gnome/shell/favorite-apps "['bzu-gmb.desktop', 'gnome-control-center.desktop', 'org.gnome.tweaks.desktop', 'org.gnome.Extensions.desktop', 'org.gnome.DiskUtility.desktop', 'org.gnome.Terminal.desktop', 'gnome-system-monitor.desktop', 'org.gnome.gedit.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Calculator.desktop', 'org.gnome.Screenshot.desktop', 'kde5-org.kde.krita.desktop', 'org.inkscape.Inkscape.desktop', 'audacious-gtk.desktop', 'audacity.desktop', 'org.shotcut.Shotcut.desktop', 'VSCodium.desktop', 'firefox.desktop', 'telegramdesktop.desktop']"
if [ ! -f "/usr/share/backgrounds/libadwaita-d.jpg" ]; then
echo "${pass_user}" | sudo -S cp -f "$gnome_41_dir/$style_run/libadwaita-d.jpg" /usr/share/backgrounds/
echo "картинка добавлена в папку /usr/share/backgrounds"
else
echo "картинка есть в папке /usr/share/backgrounds"
fi
#gsettings set org.gnome.desktop.background picture-uri-dark file:////usr/share/backgrounds/canvas_by_roytanck.jpg
gsettings set org.gnome.desktop.background picture-uri file:////usr/share/backgrounds/libadwaita-d.jpg

readarray -t ge_list < "$gnome_41_dir/gnome-extensions-list-all";for (( i=0; i <= (${#ge_list[*]}-1); i=i+1 ));do gnome-extensions disable "${ge_list[$i]}";done
sleep "$time_sleep"

dconf reset -f /org/gnome/shell/extensions/
dconf load /org/gnome/shell/extensions/ < "$gnome_41_dir/$style_run/extensions.conf"

readarray -t ge_list < "$gnome_41_dir/$style_run/gnome-extensions-list-enable";for (( i=0; i <= (${#ge_list[*]}-1); i=i+1 ));do gnome-extensions enable "${ge_list[$i]}";done
#gsettings set org.gnome.shell disable-extension-version-validation false
gnome_rebooting
sleep "$time_sleep"
else

echo "Linux Mint Style gnome 42 установка!"

gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,maximize,close"
gsettings set org.gnome.mutter attach-modal-dialogs false
gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark
gsettings set org.gnome.desktop.wm.preferences theme Adwaita
gsettings set org.gnome.gedit.preferences.editor scheme oblivion
gsettings set  org.gnome.desktop.interface cursor-theme elementary
gsettings set org.gnome.desktop.interface icon-theme Numix-Circle

if  echo "$gnome_42_dir/$style_run/installing" | grep -ow "false" > /dev/null
then
dconf write /org/gnome/shell/favorite-apps "['bzu-gmb.desktop', 'gnome-control-center.desktop', 'org.gnome.tweaks.desktop', 'org.gnome.Extensions.desktop', 'org.gnome.DiskUtility.desktop', 'org.gnome.Terminal.desktop', 'gnome-system-monitor.desktop', 'org.gnome.gedit.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Calculator.desktop', 'org.gnome.Screenshot.desktop', 'kde5-org.kde.krita.desktop', 'org.inkscape.Inkscape.desktop', 'audacious-gtk.desktop', 'audacity.desktop', 'org.shotcut.Shotcut.desktop', 'VSCodium.desktop', 'firefox.desktop', 'telegramdesktop.desktop']"
echo "true" > "$gnome_42_dir/$style_run/installing"

if [ ! -f "/usr/share/backgrounds/libadwaita-d.jpg" ]; then
echo "${pass_user}" | sudo -S cp -f "$gnome_42_dir/$style_run/libadwaita-d.jpg" /usr/share/backgrounds/
echo "картинка добавлена в папку /usr/share/backgrounds"
else
echo "картинка есть в папке /usr/share/backgrounds"
fi
gsettings set org.gnome.desktop.background picture-uri-dark file:////usr/share/backgrounds/libadwaita-d.jpg
gsettings set org.gnome.desktop.background picture-uri file:////usr/share/backgrounds/libadwaita-d.jpg
fi

gnome_ext_configure $style_run
fi
;;

"rosa")

if [[ "${gnome_version}" == "41" ]]
then
echo "$style_run style RUN!"
gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,maximize,close"
gsettings set org.gnome.mutter attach-modal-dialogs false
gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark
gsettings set org.gnome.desktop.wm.preferences theme Adwaita
gsettings set org.gnome.gedit.preferences.editor scheme oblivion
gsettings set  org.gnome.desktop.interface cursor-theme elementary
gsettings set org.gnome.desktop.interface icon-theme Numix-Circle
dconf write /org/gnome/shell/favorite-apps "['bzu-gmb.desktop', 'gnome-control-center.desktop', 'org.gnome.tweaks.desktop', 'org.gnome.Extensions.desktop', 'org.gnome.DiskUtility.desktop', 'org.gnome.Terminal.desktop', 'gnome-system-monitor.desktop', 'org.gnome.gedit.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Calculator.desktop', 'org.gnome.Screenshot.desktop', 'kde5-org.kde.krita.desktop', 'org.inkscape.Inkscape.desktop', 'audacious-gtk.desktop', 'audacity.desktop', 'org.shotcut.Shotcut.desktop', 'VSCodium.desktop', 'firefox.desktop', 'telegramdesktop.desktop']"
if [ ! -f "/usr/share/wallpapers/ROSA-light-default.svg" ]; then
echo "${pass_user}" | sudo -S cp -f "$gnome_41_dir/$style_run/ROSA-light-default.svg" "/usr/share/wallpapers/"
echo "картинка добавлена в папку /usr/share/wallpapers"
else
echo "картинка есть в папке /usr/share/wallpapers"
fi
#gsettings set org.gnome.desktop.background picture-uri-dark file:////usr/share/wallpapers/ROSA-light-default.svg
gsettings set org.gnome.desktop.background picture-uri file:////usr/share/wallpapers/ROSA-light-default.svg

readarray -t ge_list < "$gnome_41_dir/gnome-extensions-list-all";for (( i=0; i <= (${#ge_list[*]}-1); i=i+1 ));do gnome-extensions disable "${ge_list[$i]}";done
sleep "$time_sleep"

dconf reset -f /org/gnome/shell/extensions/
dconf load /org/gnome/shell/extensions/ < "$gnome_41_dir/$style_run/extensions.conf"

readarray -t ge_list < "$gnome_41_dir/$style_run/gnome-extensions-list-enable";for (( i=0; i <= (${#ge_list[*]}-1); i=i+1 ));do gnome-extensions enable "${ge_list[$i]}";done
#gsettings set org.gnome.shell disable-extension-version-validation false
gnome_rebooting
sleep "$time_sleep"
else

echo "$style_run Style gnome 42 установка!"

gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,maximize,close"
gsettings set org.gnome.mutter attach-modal-dialogs false
gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark
gsettings set org.gnome.desktop.wm.preferences theme Adwaita
gsettings set org.gnome.gedit.preferences.editor scheme oblivion
gsettings set  org.gnome.desktop.interface cursor-theme elementary
gsettings set org.gnome.desktop.interface icon-theme Numix-Circle

if  echo "$gnome_42_dir/$style_run/installing" | grep -ow "false" > /dev/null
then
dconf write /org/gnome/shell/favorite-apps "['bzu-gmb.desktop', 'gnome-control-center.desktop', 'org.gnome.tweaks.desktop', 'org.gnome.Extensions.desktop', 'org.gnome.DiskUtility.desktop', 'org.gnome.Terminal.desktop', 'gnome-system-monitor.desktop', 'org.gnome.gedit.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Calculator.desktop', 'org.gnome.Screenshot.desktop', 'kde5-org.kde.krita.desktop', 'org.inkscape.Inkscape.desktop', 'audacious-gtk.desktop', 'audacity.desktop', 'org.shotcut.Shotcut.desktop', 'VSCodium.desktop', 'firefox.desktop', 'telegramdesktop.desktop']"
echo "true" > "$gnome_42_dir/$style_run/installing"

if [ ! -f "/usr/share/wallpapers/ROSA-light-default.svg" ]; then
echo "${pass_user}" | sudo -S cp -f "$gnome_42_dir/$style_run/ROSA-light-default.svg" "/usr/share/wallpapers/"
echo "картинка добавлена в папку /usr/share/wallpapers"
else
echo "картинка есть в папке /usr/share/wallpapers"
fi
gsettings set org.gnome.desktop.background picture-uri-dark file:////usr/share/wallpapers/ROSA-light-default.svg
gsettings set org.gnome.desktop.background picture-uri file:////usr/share/wallpapers/ROSA-light-default.svg

fi

gnome_ext_configure $style_run
fi
;;

"redroot")

if [[ "${gnome_version}" == "41" ]]
then
echo "$style_run Style RUN!"
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 4
gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,maximize,close"
gsettings set org.gnome.mutter attach-modal-dialogs false
gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark
gsettings set org.gnome.desktop.wm.preferences theme Adwaita
gsettings set org.gnome.gedit.preferences.editor scheme oblivion
gsettings set  org.gnome.desktop.interface cursor-theme elementary
gsettings set org.gnome.desktop.interface icon-theme Numix-Circle
dconf write /org/gnome/shell/favorite-apps "['bzu-gmb.desktop', 'gnome-control-center.desktop', 'org.gnome.tweaks.desktop', 'org.gnome.Extensions.desktop', 'org.gnome.DiskUtility.desktop', 'org.gnome.Terminal.desktop', 'gnome-system-monitor.desktop', 'org.gnome.gedit.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Calculator.desktop', 'org.gnome.Screenshot.desktop', 'kde5-org.kde.krita.desktop', 'org.inkscape.Inkscape.desktop', 'audacious-gtk.desktop', 'audacity.desktop', 'org.shotcut.Shotcut.desktop', 'VSCodium.desktop', 'firefox.desktop', 'telegramdesktop.desktop']"
if [ ! -f "/usr/share/backgrounds/42.jpg" ]; then
echo "${pass_user}" | sudo -S cp -f "$gnome_41_dir/$style_run/42.jpg" /usr/share/backgrounds/
echo "${pass_user}" | sudo -S cp -f "$gnome_41_dir/$style_run/42bluring.jpg" /usr/share/backgrounds/
echo "картинка добавлена в папку /usr/share/backgrounds"
else
echo "картинка есть в папке /usr/share/backgrounds"
fi

#gsettings set org.gnome.desktop.background picture-uri-dark file:////usr/share/backgrounds/42.jpg
gsettings set org.gnome.desktop.background picture-uri file:////usr/share/backgrounds/42.jpg

readarray -t ge_list < "$gnome_41_dir/gnome-extensions-list-all";for (( i=0; i <= (${#ge_list[*]}-1); i=i+1 ));do gnome-extensions disable "${ge_list[$i]}";done
sleep "$time_sleep"

dconf reset -f /org/gnome/shell/extensions/
dconf load /org/gnome/shell/extensions/ < "$gnome_41_dir/$style_run/extensions.conf"

readarray -t ge_list < "$gnome_41_dir/$style_run/gnome-extensions-list-enable";for (( i=0; i <= (${#ge_list[*]}-1); i=i+1 ));do gnome-extensions enable "${ge_list[$i]}";done
#gsettings set org.gnome.shell disable-extension-version-validation false
gnome_rebooting
sleep "$time_sleep"
else

echo "$style_run Style gnome 42 установка!"

gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 4
gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,maximize,close"
gsettings set org.gnome.mutter attach-modal-dialogs false
gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark
gsettings set org.gnome.desktop.wm.preferences theme Adwaita
gsettings set org.gnome.gedit.preferences.editor scheme oblivion
gsettings set  org.gnome.desktop.interface cursor-theme elementary
gsettings set org.gnome.desktop.interface icon-theme Numix-Circle

if  echo "$gnome_42_dir/redroot/installing" | grep -ow "false" > /dev/null
then
dconf write /org/gnome/shell/favorite-apps "['bzu-gmb.desktop', 'gnome-control-center.desktop', 'org.gnome.tweaks.desktop', 'org.gnome.Extensions.desktop', 'org.gnome.DiskUtility.desktop', 'org.gnome.Terminal.desktop', 'gnome-system-monitor.desktop', 'org.gnome.gedit.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Calculator.desktop', 'org.gnome.Screenshot.desktop', 'kde5-org.kde.krita.desktop', 'org.inkscape.Inkscape.desktop', 'audacious-gtk.desktop', 'audacity.desktop', 'org.shotcut.Shotcut.desktop', 'VSCodium.desktop', 'firefox.desktop', 'telegramdesktop.desktop']"
echo "true" > "$gnome_42_dir/redroot/installing"
if [ ! -f "/usr/share/backgrounds/42.jpg" ]; then
echo "${pass_user}" | sudo -S cp -f "$gnome_42_dir/redroot/42.jpg" /usr/share/backgrounds/
echo "${pass_user}" | sudo -S cp -f "$gnome_42_dir/redroot/42bluring.jpg" /usr/share/backgrounds/
echo "картинка добавлена в папку /usr/share/backgrounds"
else
echo "картинка есть в папке /usr/share/backgrounds"
fi

gsettings set org.gnome.desktop.background picture-uri-dark file:////usr/share/backgrounds/42.jpg
gsettings set org.gnome.desktop.background picture-uri file:////usr/share/backgrounds/42.jpg
fi

gnome_ext_configure $style_run
fi
;;

esac

echo "перезапускаем модуль меню $version"
fi

done

exit 0


#GTK_THEME="Adwaita-dark" ${YAD} --title="Back to Ubuntu Vanilla" --image-on-top --picture --size=fit --filename="${script_dir}/icons/gnome-ext-pack.png" --width=327 --height=327 --center --inc=256  --text-align=center --text="ТРЕБУЕТСЯ ПЕРЕАГРУЗКА СИСТЕМЫ!" --timeout=5 --timeout-indicator=bottom 

#script_dir0=$(dirname $(readlink -f "$0"))
#

#if [[ "$installing_status" == "true" ]]
#  then
#  tput setaf 2
#  echo "core-utils уже установлены!"
#  tput sgr 0
#  else
#  #проверка что есть интернет
#  ip_test="8.8.8.8"
#  if ping -c 1 -w 1 ${ip_test} | grep -wo "100% packet loss" > /dev/null
#  then
#  tput setaf 1 
#  echo "ДЛЯ ПЕРВОГО ЗАПУСКА ПРОГРАММЫ ТРЕБУЕТСЯ ИНТЕРНЕТ!"
#  exit 0
#  else
# if [ ! -e /$script_dir/core-utils/yad ];then
#cd "$script_dir"
#wget https://github.com/redrootmin/bzu-gmb-modules/releases/download/v1/core-utils-lite-v1.tar.xz
#tar -xpJf "$script_dir/core-utils-lite-v1.tar.xz"
#rm -f "$script_dir/core-utils-lite-v1.tar.xz"
#fi
#  fi

#fi