#!/bin/bash
#creator by RedRoot(Yaciyna Mikhail) for GAMER STATION [on linux] and Gaming Community OS Linux
# GPL-3.0 License

#проверяем что скрипт установки не запущен от пользователя root
if [ "$UID" -eq 0 ];then
tput setaf 1; echo "Этот скрипт не нужно запускать из под root!";tput sgr0;exit 1
else
tput setaf 2; echo "все хорошо этот скрипт не запущен из под root!"
fi

#Определение расположениея папок для утилит и т.д.
update_time=`date +%d"."%m"."%Y`
script_dir=$(cd $(dirname "$0") && pwd);
echo "$script_dir"
install_version=`cat ${script_dir}/config/install-version`
echo "$install_version"
app_dir=`echo "${script_dir}" | sed "s|${install_version}||g"`
echo "$app_dir"
utils_dir="${script_dir}/core-utils"
echo "$utils_dir"
#Определение переменныех утилит и скриптов
YAD="${utils_dir}/yad"
zenity="${utils_dir}/zenity"
pass_user="$1"
name_script="$2"
#запрос пароля root для установки ПО необходимого для bzu-gmb
if [[ "${pass_user}" == "" ]]
then
read -sp 'Введите Пароль root:' pass_user
echo " "
else
echo "обнавляем Gnome-Gui-Switcher!"
cd "${app_dir}"
rm -f "${install_version}_old"*
tar cf - ${install_version} | xz -z - > "${install_version}_old-[$update_time].tar.xz" || true
rm -f "${install_version}"
rm -f -r "${install_version}"
wget https://github.com/redrootmin/gnome-gui-switcher/archive/refs/heads/rosa.zip -O "${install_version}.zip"
unzip "${install_version}.zip"
rm -f "${install_version}.zip"
chmod +x "${app_dir}/${install_version}/mini_install.sh"
echo "${install_version}" > "${app_dir}/${install_version}/config/install-version"
if  [ -d "${app_dir}/${install_version}" ];then
tput setaf 2; echo "Обнавление утилиты ${install_version} завершено :)"
tput sgr0
echo "$update_time" > "${app_dir}/${install_version}/config/update-status"
else
tput setaf 1; echo "Обнавление утилиты ${install_version} завершено с ОШИБКОЙ :("
tput sgr0
sleep 5
exit 0
fi
fi

#Даем права на главные скрипты утилиты и core-utils
chmod +x "${script_dir}/devs.sh"
chmod +x "${script_dir}/ggs-starter.sh"
chmod +x "${script_dir}/manual_update.sh"
chmod +x "${script_dir}/mini_install.sh"
chmod +x "${script_dir}/core-utils/yad"
chmod +x "${script_dir}/core-utils/zenity"
version0=`cat "${app_dir}/${install_version}/config/name_version"`
export version="Gnome-Gui-Switcher[${version0}]"
#Уведомление пользователя, о том что нового в этой версии
update_log=`cat "${script_dir}/update_log"`
GTK_THEME="Adwaita-dark" ${YAD} --list --column=text --no-click --image-on-top --picture --size=fit --image="${script_dir}/images/rosa/multi-wall-update.png" --width=512 --height=640 --center --inc=256  --text-align=center --title="Завершена установка $version" --separator=" " --search-column=1 --print-column=1 --wrap-width=560 "$update_log" --no-buttons

bash "${app_dir}/${install_version}/$name_script.sh" $pass_user
