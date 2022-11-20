#!/bin/bash
#creator by RedRoot(Yaciyna Mikhail) for GAMER STATION [on linux] and Gaming Community OS Linux
# GPL-3.0 License

#проверяем что скрипт установки не запущен от пользователя root
if [ "$UID" -eq 0 ];then
tput setaf 1; echo "Этот скрипт не нужно запускать из под root!";tput sgr0;exit 1
else
tput setaf 2; echo "все хорошо этот скрипт не запущен из под root!";tput sgr0
fi

#собираем данные о том в какой папке  находиться редактор
export utils_dir=$(cd $(dirname "$0") && pwd);
echo "папка утилит:[$utils_dir]"
export LD_LIBRARY_PATH="$utils_dir/lib64":$LD_LIBRARY_PATH
echo "папка доп. библиотек:[$LD_LIBRARY_PATH]"
export YAD="$utils_dir/bin/yad"
echo "ссылка на протативный yad:[$YAD]"
export zenity="$utils_dir/bin/zenity"
echo "ссылка на протативный zenity:[$zenity]"
