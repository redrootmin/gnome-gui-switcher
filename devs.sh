#!/bin/bash
#creator by RedRoot(Yaciyna Mikhail) for GAMER STATION [on linux] and Gaming Community OS Linux
# GPL-3.0 License

#собираем данные о том в какой папке  находиться редактор
script_dir=$(cd $(dirname "$0") && pwd);

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
