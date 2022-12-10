#!/bin/bash
#creator by RedRoot(Yaciyna Mikhail) for GAMER STATION [on linux] and Gaming Community OS Linux
# GPL-3.0 License




script_dir0=$(dirname $(readlink -f "$0"))
export script_dir=${script_dir0}
icon1="${script_dir}/icons/gnome-ext-pack-testing.png"
version0=`cat "${script_dir}/config/name_version"`
export version="Gnome-Gui-Switcher[${version0}]"
export config_ggs_dir="${script_dir}/config-ggs"
gnome_version0=`gnome-shell --version | grep -wo "42"` || gnome_version0="41"
export gnome_version=$gnome_version0
echo -n > "$config_ggs_dir/conf/gnome-pack-run"
sh "$script_dir/scripts/load-styles.sh"
sh "$script_dir/scripts/menu-base-ggs-generator.sh"
sh "$script_dir/scripts/html5-ui-ggs-generator.sh"

ggs_ui_html5_dev0=`cat "$config_ggs_dir/ui/html5/html5-ui-base-run.html"`
export ggs_ui_html5_global=$ggs_ui_html5_dev0


function ggs-ui-html5-app () {
 echo "$ggs_ui_html5_global" | stdbuf -oL -eL yad  --html \
--print-uri 2>&1 \
--center \
--undecorated \
--no-buttons \
--width=1064 --height=512 \
--window-icon="$icon1" | while read -r line; do
     export url_call="${line##*/}"
     tput setaf 2;echo "${url_call}";tput setaf 0
     case ${url_call} in
      rosa)
        echo "начинаем установку ${url_call}"

        ;;
      redroot)
        echo "начинаем установку ${url_call}"
        ;;
      macos)
        echo "начинаем установку ${url_call}"
        ;;
      mint)
        echo "начинаем установку ${url_call}"
        ;;
      ubuntu)
      echo "начинаем установку ${url_call}"
      ;;
      exit-app) killall yad
      ;;
      *) echo "неизвестная комманда[${url_call}]" 
      ;;

     esac
done
}

ggs-ui-html5-app









exit 0

function ggs-ui-html5-app2 () {
echo "$ggs_ui_html5_dev" | stdbuf -oL -eL yad  --html \
--width=830 --height=313 --print-uri 2>&1 \
--button=cancel:1 --center --undecorated \
--splash --print-uri 2>&1 --window-icon="$icon1" \
| while read -r line; do
export mesa_for_installing="${line##*/}"
     tput setaf 2;echo "${line##*/}";tput setaf 0
     case ${mesa_for_installing} in
      mesa-default)
        echo "начинаем установку ${mesa_for_installing}"
        ;;
      mesa-backports)
        echo "начинаем установку ${mesa_for_installing}"
        ;;
      mesa-fidel-git)
        echo "начинаем установку ${mesa_for_installing}"
        ;;
      mesa-fidel-git-devel)
        echo "начинаем установку ${mesa_for_installing}"
        ;;

      *) echo "неизвестная комманда" 
      ;;
     esac
done
}

#собираем данные о том в какой папке  находиться редактор
script_dir0=$(cd $(dirname "$0") && pwd);

# считываем колличество наборов стилей в папке конфигураций
readarray -t gnome_all_packs < "${script_dir}/config/gnome-style-packs"
# делаем цикл с перебором наборов стилей
for gnome_packs in "${gnome_all_packs[@]}" 
  do 
  echo "Пак-стилей: $gnome_packs"
  # делаем цикл с перебором стилей в наборе
  readarray -t style_all_names < "${script_dir}/config/$gnome_packs/style-name"
  for style_names in "${style_all_names[@]}"
   do
   # Сбрасываем значение первой установки стиля
   echo "Назвение стиля: $style_names - сборос значения установки"
   echo "false" > "${script_dir}/config/$gnome_packs/$style_names/installing"
  done
done 


exit 0
