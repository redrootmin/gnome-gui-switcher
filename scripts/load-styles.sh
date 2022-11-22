#!/bin/bash
#creator by RedRoot(Yaciyna Mikhail) for GAMER STATION [on linux] and Gaming Community OS Linux
# GPL-3.0 License
# собираем данные о названии групп стилей
cd "$config_ggs_dir/gnome-packs" 
ls -1 -d */ | sed "s|/||g" > "$config_ggs_dir/conf/gnome-style-packs" 


# считываем колличество наборов стилей в папке конфигураций
readarray -t gnome_all_packs < "$config_ggs_dir/conf/gnome-style-packs"
# делаем цикл с перебором наборов стилей
for gnome_packs in "${gnome_all_packs[@]}" 
  do 
  echo "Пак-стилей: $gnome_packs"
  # делаем цикл с поиском стилей в наборе
 cd "$config_ggs_dir/gnome-packs/$gnome_packs/style-packs" 
 ls -1 -d */ | sed "s|/||g" > "$config_ggs_dir/gnome-packs/$gnome_packs/style-name" 
 # for style_names in "${style_packs[@]}"
  # do
   # Сбрасываем значение первой установки стиля
   readarray -t style_all_packs < "$config_ggs_dir/gnome-packs/$gnome_packs/style-name"
   echo "Назвение стилей: ${style_all_packs[*]}"
   #echo "false" > "${script_dir}/config/$gnome_packs/$style_names/installing"
  #done
done 