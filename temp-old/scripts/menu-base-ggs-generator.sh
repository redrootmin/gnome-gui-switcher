#!/bin/bash
#creator by RedRoot(Yaciyna Mikhail) for GAMER STATION [on linux] and Gaming Community OS Linux
# GPL-3.0 License

# считываем колличество наборов стилей в папке конфигураций
readarray -t gnome_all_packs < "$config_ggs_dir/conf/gnome-style-packs"
# обнуляем лог генератора меню для ggs
echo "[[[[[[[LOG-ERROR-MENU-GGS-GENERATOR-"`date`"-]]]]]]]]]" > "$config_ggs_dir/logs/log-menu-ggs-generator"
# обнуляем переменную для проверки набора стилей, что бы точно знать, что все нужные папки и файлы на месте и они не пусты!

echo -n > "$config_ggs_dir/conf/base_for_menu_ggs"
#создаем цикл проверки всех наборов стилей из папки gnome-packs
for gnome_packs in "${gnome_all_packs[@]}" 
  do
  # проверяем что набор стилей соотвествует версии гнома в системе
  if echo "${gnome_packs}" | grep -wo "rosa-gnome$gnome_version" > /dev/null
        then
            # если набор стилей совпал, то загружаем список требуемой структуры для набора стилей
            readarray -t gnome_packs_base_sample < "$config_ggs_dir/conf/gnome-packs-base-sample"
            gnome_packs_base_sample_num="${#gnome_packs_base_sample[*]}"
            let "gnome_packs_base_true = 0"
            # запускаем цикл сравнения того что в папке набора и того что требуется
            for gnome_packs_base in "${gnome_packs_base_sample[@]}" 
                do
                # создаем переменные что бы понять где папки а где файлы
                echo "gnome_packs_base[$gnome_packs_base]"
                key_type2="-d";echo "$gnome_packs_base" | grep "=d " > /dev/null || key_type2="-f"
                sample_search=`echo "$gnome_packs_base" | cut -d " " -f 2`
                            # проверяем что папка или файл сущутвуют в папке набора стилей
                            if [ ${key_type2} "$config_ggs_dir/gnome-packs/${gnome_packs}/${sample_search}" ]
                             then
                             echo "проверка наличие папки/файла [${sample_search}] набора стилей [${gnome_packs}] пройдена!"
                              #  если обьект папка, проверяем что на не пуста
                              if [[ ${key_type2} == "-d" ]];then
                                echo "проверяем папку [${sample_search}]" 
                                if [ `ls "$config_ggs_dir/gnome-packs/${gnome_packs}/${sample_search}" -a | wc -l` -eq 2 ];then
                                 echo "$config_ggs_dir/gnome-packs/${gnome_packs}/${sample_search} - Папка пуста, набор стилей $gnome_packs игнорируется генератором!" >> "$config_ggs_dir/logs/log-menu-ggs-generator"
                                 else
                                  let "gnome_packs_base_true += 1"
                                fi 
                              fi
                              # если обьект файл проверяем что он не пустой
                              if [[ ${key_type2} == "-f" ]];then
                                  if [[ `echo "$config_ggs_dir/gnome-packs/${gnome_packs}/${sample_search}"` == "" ]]; then
                                   echo "$config_ggs_dir/gnome-packs/${gnome_packs}/${sample_search} - файл пуст, набор стилей $gnome_packs игнорируется генератором!" >> "$config_ggs_dir/logs/log-menu-ggs-generator"
                                    else
                                    let "gnome_packs_base_true += 1"
                                  fi
                              fi
                                    # если количество положительно проверенных обьектов совпало с колличеством требуемых, переходим на этап проверки стилей и добавления их в базу генератора
                                    echo "gnome_packs_base_true[${gnome_packs_base_true}]-gnome_packs_base_sample[${#gnome_packs_base_sample[*]}]"
                                    if [[ "${gnome_packs_base_true}" == "${#gnome_packs_base_sample[*]}" ]]
                                     then
                                     #запись в лог что набор стилей проверен и далее будет проверка самих стилей
                                     info_gnome_packs="папки и файлы в наборе стилей [$config_ggs_dir/gnome-packs/${gnome_packs}] - существуют и не пусты, набор стилей  $gnome_packs добавляет в меню ggs генератором"
                                     echo "$info_gnome_packs"
                                     echo "$info_gnome_packs" >>"$config_ggs_dir/logs/log-menu-ggs-generator"
                                     echo "$gnome_packs" > "$config_ggs_dir/conf/gnome-pack-run"
                                       #загружаем список стилей для последующей проверки
                                        readarray -t style_all_packs < "$config_ggs_dir/gnome-packs/$gnome_packs/style-name"
                                         info_gnome_pack_styles="список стилей в наборе для проверки: ${style_all_packs[*]}"
                                         echo "$info_gnome_pack_styles" >> "$config_ggs_dir/logs/log-menu-ggs-generator"
                                        # создаем цикл проверки все стилей в папке набора стилей
                                        for style_packs_base in "${style_all_packs[@]}" 
                                         do
                                          #обнуляем счетчик провереных файлов стилей и загружаем список файлов которые должны быть в стиле
                                          let "style_packs_base_true = 0"
                                          readarray -t style_packs_base_sample < "$config_ggs_dir/conf/style-packs-base-sample"
                                          # запускаем цикл проверки файлов стиля на наличие и того что в них есть информация
                                            for style_packs_sample in "${style_packs_base_sample[@]}" 
                                             do
                                             #удаляем лишную информацию из имени файла (в будущем возможно в стиле будут не только файлы но и папки)
                                             style_packs_sample_clear=`echo "$style_packs_sample" | cut -d " " -f 2`
                                             #делам проверку что файл стиля существует
                                              
                                             if [ -f "$config_ggs_dir/gnome-packs/${gnome_packs}/style-packs/$style_packs_base/${style_packs_sample_clear}" ]
                                               then
                                                #проверяем что файл не пустой
                                                echo "$config_ggs_dir/gnome-packs/${gnome_packs}/style-packs/$style_packs_base/${style_packs_sample_clear}"
                                                if [[ `echo "$config_ggs_dir/gnome-packs/${gnome_packs}/style-packs/$style_packs_base/${style_packs_sample_clear}"` == "" ]];  then
                                                  info_style_pack_base="файл ${style_packs_sample_clear} в стиле $style_packs_base - пуст!"
                                                  echo "$info_style_pack_base" >> "$config_ggs_dir/logs/log-menu-ggs-generator"
                                                  else
                                                  let "style_packs_base_true += 1"
                                                fi
                                                 #если колличество положительно провереных файлов стиля совподает с их нужным колличеством стиль добовляется в базу проверенных 
                                                  if [[ "${style_packs_base_true}" == "${#style_packs_base_sample[*]}" ]]
                                                    then
                                                      echo "$style_packs_base" >> "$config_ggs_dir/conf/base_for_menu_ggs"
                                                      info_style_pack_base="добавляем стиль [$style_packs_base] в файл базу провереных стилей:[/conf/base_for_menu_ggs]"
                                                      echo "$info_style_pack_base"
                                                      echo "$info_style_pack_base" >> "$config_ggs_dir/logs/log-menu-ggs-generator"
                                                    fi
                                                else
                                                  info_style_pack_base="файл или папка [${style_packs_sample_clear}] стиля [$style_packs_base] не найдены"
                                                  echo "$info_style_pack_base"
                                                  echo "$info_style_pack_base" >> "$config_ggs_dir/logs/log-menu-ggs-generator"
                                              fi   
                                            done

                                        done
                                    fi
                                
                                else
                                # набор стилей не прошел проверку на наличие необходимых файлов/папок
                                info_gnome_packs="папка или файл [$config_ggs_dir/gnome-packs/${gnome_packs}/${sample_search}] - не существует, набор стилей $gnome_packs игнориуется генератором"
                                echo "$info_gnome_packs"
                                echo "$info_gnome_packs" >>"$config_ggs_dir/config-ggs/logs/log-menu-ggs-generator"
                            fi
            

            done
     else
       info_gnome_packs="набор стилей $gnome_packs не совпадает с версией в системе и игнорируетсмя генератором!"
       echo "$info_gnome_packs"
       echo "$info_gnome_packs" >>"$config_ggs_dir/logs/log-menu-ggs-generator"  
  fi

done 