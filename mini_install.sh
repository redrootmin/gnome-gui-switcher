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
name_desktop_file2="ggs-testing.desktop"
name_script_start="ggs-starter.sh"
name_script_start2="ggs-starter-testing.sh"
name_app="[GGS]gnome-gui-switcher"
name_app2="[GGS]gnome-gui-switcher-testing"
exec_full="bash -c "${script_dir}"/"${name_script_start}""
exec_full2="bash -c "${script_dir}"/"${name_script_start2}""
icon1="Icon=${script_dir}/icons/gnome-ext-pack.png"
icon2="Icon=${script_dir}/icons/gnome-ext-pack-testing.png"
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

#Создаем ярлык для скрипта тестовая версия
echo "[Desktop Entry]
Version=1.0
Type=Application
Name=${name_app2}
Comment=applications for switching kits (profiles) of additions in gnome 42
Categories=Utility;
Exec=${exec_full2}
Terminal=true
${icon2}" > "${script_dir}/${name_desktop_file2}"

#копируем ярлыки в папку пользователя
cp -f "${script_dir}/${name_desktop_file}" "/home/$USER/.local/share/applications/"
cp -f "${script_dir}/${name_desktop_file2}" "/home/$USER/.local/share/applications/"
#Даем права на запуск ярлыка в папке программы и копируем в папку с ярлыками пользователя
gio set "${script_dir}/${name_desktop_file}" "metadata::trusted" yes
gio set "/home/$USER/.local/share/applications/${name_desktop_file}" "metadata::trusted" yes
gio set "${script_dir}/${name_desktop_file2}" "metadata::trusted" yes
gio set "/home/$USER/.local/share/applications/${name_desktop_file2}" "metadata::trusted" yes
#gio info "${script_dir}/name_desktop_file" | grep "metadata::trusted"
#даем права на запуск программы и ее скриптов
chmod +x "${script_dir}"/"${name_script_start}"
echo "" > "${script_dir}/config/install-status"
echo "" > "${script_dir}/config/gnome-version"

#считываем колличество наборов стилей в папке конфигураций
readarray -t gnome_all_packs < "${script_dir}/config/gnome-style-packs"
#делаем цикл с перебором наборов стилей
for gnome_packs in "${gnome_all_packs[@]}" 
  do 
  echo "Пак-стилей: $gnome_packs"
  #делаем цикл с перебором стилей в наборе
  readarray -t style_all_names < "${script_dir}/config/$gnome_packs/style-name"
  for style_names in "${style_all_names[@]}"
   do
   #Сбрасываем значение первой установки стиля
   echo "Назвение стиля: $style_names - сборос значения установки"
   echo "false" > "${script_dir}/config/$gnome_packs/$style_names/installing"
  done
done 

exit 0
