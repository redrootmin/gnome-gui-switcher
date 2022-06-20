#!/bin/bash
#creator by RedRoot(Yaciyna Mikhail) for GAMER STATION [on linux] and Gaming Community OS Linux
# GPL-3.0 License 

#проверяем что скрипт установки не запущен от пользователя root
if [ "$UID" -eq 0 ];then
tput setaf 1; echo "Этот скрипт не нужно запускать из под root!";tput sgr0;exit 1
else
tput setaf 2; echo "все хорошо этот скрипт не запущен из под root!"
fi

#собираем данные о том в какой папке  находиться редактор
script_dir=$(cd $(dirname "$0") && pwd);
#app_dir="${script_dir}/app"
name_desktop_file="ggs.desktop"
name_script_start="ggs-starter.sh"
name_app="[GGS]gnome-gui-switcher"
exec_full="bash -c "${script_dir}"/"${name_script_start}""
icon1="Icon=${script_dir}/icons/gnome-ext-pack.png"
 
# Проверка что существует папка applications, если нет, создаем ее
if [ ! -d "/home/${USER}/.local/share/applications" ]
then
mkdir -p "/home/${USER}/.local/share/applications"
fi

#Создаем ярлык для скрипта
echo "[Desktop Entry]" > "${script_dir}/${name_desktop_file}"
echo "Version=1.0" >> "${script_dir}/${name_desktop_file}"
echo "Type=Application" >> "${script_dir}/${name_desktop_file}"
echo "Name=${name_app}" >> "${script_dir}/${name_desktop_file}"
echo "Comment=applications for switching kits (profiles) of additions in gnome 42" >> "${script_dir}/${name_desktop_file}" 
echo "Categories=Utility;" >> "${script_dir}/${name_desktop_file}"
echo "Exec=${exec_full}" >> "${script_dir}/${name_desktop_file}"
echo "Terminal=true" >> "${script_dir}/${name_desktop_file}"
echo "${icon1}" >> "${script_dir}/${name_desktop_file}"
cp -f "${script_dir}/${name_desktop_file}" "/home/$USER/.local/share/applications/"
#Даем права на запуск ярлыка в папке программы и копируем в папку с ярлыками пользователя
gio set "${script_dir}/${name_desktop_file}" "metadata::trusted" yes
gio set "/home/$USER/.local/share/applications/${name_desktop_file}" "metadata::trusted" yes
#gio info "${script_dir}/name_desktop_file" | grep "metadata::trusted"
#даем права на запуск программы и ее скриптов
chmod +x "${script_dir}"/"${name_script_start}"
echo "" > "${script_dir}/config/install-status"

exit 0
