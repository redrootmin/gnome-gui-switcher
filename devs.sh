#!/bin/bash
#creator by RedRoot(Yaciyna Mikhail) for GAMER STATION [on linux] and Gaming Community OS Linux
# GPL-3.0 License

#определяем какая система запустила ggs
linuxos_version=`cat "/etc/os-release" | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/"//g'`
linuxos_gnome="true"
if [ ! -e /usr/bin/gnome-shell ];then linuxos_gnome="false";fi

#проверяем что система совместима с ggs
if echo "${linuxos_version}" | grep -ow "ROSA Fresh Desktop 12.2" > /dev/null && echo "${linuxos_gnome}" | grep -ow "true" > /dev/null;then
tput setaf 2;echo "Операциооная система: ${linuxos_version} совместима с [GGS]gnome-gui-switcher"
tput sgr 0
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
#собираем данные о том в какой папке находиться bzu-gmb
script_dir=$(cd $(dirname "$0") && pwd);

#запрос пароля root для установки ПО необходимого для bzu-gmb
read -sp 'Введите Пароль root:' pass_user
echo " "



#Проверка что существует папка extensions c доплнениями, если нет
#копируем распоковываем архив с дополнениями в папку пользователя и ребутим гном сшелл
#что бы система их увидела
if [ ! -d "/home/${USER}/.local/share/gnome-shell/extensions/redroot-pack" ]
then
tput setaf 1;echo "ВНИМАНИЕ: начинается установка комплектп дополнений необходимых для [GGS]gnome-gui-switcher!"
tput sgr 0
#ЗАБИКАПИТЬ ДЕФОЛТНЫЕ ДОПОЛНЕНИЯ!
cd "/home/${USER}/.local/share/gnome-shell/"
tar cf - extensions | xz -z - > "extensions_old.tar.xz"
rm -fr "/home/${USER}/.local/share/gnome-shell/extensions" || true
tar -xpJf "$script_dir/data/extensions-ggs-rosa-v1.tar.xz" -C "/home/${USER}/.local/share/gnome-shell/"
killall -3 gnome-shell
sleep 5
else
tput setaf 2;echo "комплект дополнений необходимый для [GGS]gnome-gui-switcher уже установлен :)"
tput sgr 0
fi


exit 0
