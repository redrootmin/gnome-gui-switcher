#!/bin/bash
#creator by RedRoot(Yacyna Mehail) for GAMER STATION [on linux] and Gaming Community OS Linux
# GPL-3.0 License 
#проверяем что скрипт установки не запущен от пользователя root
if [ "$UID" -eq 0 ];then
tput setaf 1; echo "Этот скрипт не нужно запускать из под root!";tput sgr0;exit 1
else
tput setaf 2; echo "все хорошо этот скрипт не запущен из под root!"
fi

#запрос пароля root для установки ПО необходимого для bzu-gmb
read -sp 'Введите Пароль root:' pass_user
echo " "

# переменные
script_dir=$(cd $(dirname "$0") && pwd);


# основные команды
if inxi -G | grep -ow "x11" > /dev/null
then
echo "${pass_user}" | sudo -S dnf install -y inxi paprefs pavucontrol zenity yad
cd "$script_dir"
rm -fr "/home/$USER/.local/share/gnome-shell/extensions" || true
tar -xpJf "$script_dir/themes-ggs/extensions-rosa122-v2.tar.xz" -C "/home/$USER/.local/share/gnome-shell/"
echo "${pass_user}" | sudo -S killall -3 gnome-shell
sleep 5
else
GTK_THEME="Adwaita-dark" yad --title="скрипт запущен в Wayland!" --image-on-top --picture --size=fit --filename="${script_dir}/temp/xorg-wayland.png" --width=450 --height=327 --center --inc=256  --text-align=center --text="Данный скрипт работает только в сессии X.org" --timeout=10 --timeout-indicator=bottom
fi































exit 0
GTK_THEME="Adwaita-dark" ${YAD} --title="Back to Ubuntu Vanilla" --image-on-top --picture --size=fit --filename="${script_dir}/icons/debian-logo-icon327.png" --width=327 --height=327 --center --inc=256  --text-align=center --text="ТРЕБУЕТСЯ ПЕРЕАГРУЗКА СИСТЕМЫ!" --timeout=5 --timeout-indicator=bottom

if inxi -G | grep -ow "wayland" > /dev/null; then echo "xorg yes!";fi



gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
gsettings set org.gnome.mutter attach-modal-dialogs false
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme Yaru
gsettings set org.gnome.desktop.wm.preferences theme Yaru
gsettings set org.gnome.desktop.interface icon-theme Yaru
gsettings set  org.gnome.desktop.interface cursor-theme Yaru
dconf write /org/gnome/shell/favorite-apps "['firefox_firefox.desktop', 'org.gnome.Nautilus.desktop', 'snap-store_ubuntu-software.desktop', 'yelp.desktop', 'software-properties-drivers.desktop', 'org.gnome.DiskUtility.desktop', 'org.gnome.gedit.desktop', 'gnome-system-monitor.desktop', 'org.gnome.Terminal.desktop', 'gnome-control-center.desktop', 'org.gnome.Calculator.desktop']"
gsettings set org.gnome.desktop.background picture-uri-dark file:////usr/share/backgrounds/warty-final-ubuntu.png
gsettings set org.gnome.desktop.background picture-uri file:////usr/share/backgrounds/warty-final-ubuntu.png
readarray -t ge_list < "$script_dir/config/gnome-extensions-list-all";for (( i=0; i <= (${#ge_list[*]}-1); i=i+1 ));do gnome-extensions disable "${ge_list[$i]}";done
sleep 5
dconf reset -f /org/gnome/shell/extensions/
dconf load /org/gnome/shell/extensions/ < "$script_dir/config/ubuntu/extensions.conf"
readarray -t ge_list < "$script_dir/config/ubuntu/gnome-extensions-list-enable";for (( i=0; i <= (${#ge_list[*]}-1); i=i+1 ));do gnome-extensions enable "${ge_list[$i]}";done

#запуск основных команд модуля
echo "${pass_user}" | sudo -S rm -r "${script_dir}/modules-temp/${name_script}/temp" || let "error += 1"
echo "${pass_user}" | sudo -S mkdir -p "${script_dir}/modules-temp/${name_script}/temp" || let "error += 1"
cd "${script_dir}/modules-temp/${name_script}/temp" || let "error += 1"
echo "${pass_user}" | sudo -S wget "https://drive.google.com/uc?export=download&id=1eVbeZdMwW57zjs73LhEZKIUpkzuWxC70" -O "${name_script}.tar.xz" || let "error += 1"
echo "${pass_user}" | sudo -S tar -xpJf "${name_script}.tar.xz"
cd "${script_dir}/modules-temp/${name_script}/temp/${name_script}"

# установка дополнительного ПО
echo "${pass_user}" | sudo -S apt install -f -y --reinstall gnome-session gnome-tweaks chrome-gnome-shell gnome-shell-extensions numix-icon-theme-circle git libglib2.0-dev grub-customizer paprefs pavucontrol
echo "${pass_user}" | sudo -S apt update
echo "${pass_user}" | sudo -S apt upgrade
echo "${pass_user}" | sudo -S apt install -f -y --reinstall gnome-session gnome-tweaks chrome-gnome-shell gnome-shell-extensions numix-icon-theme-circle git libglib2.0-dev grub-customizer paprefs pavucontrol

# устаноавливаем черное logo ubuntu на заставку загрузки
rm -rf ubuntu-darwin | true
git clone https://github.com/ashutoshgngwr/ubuntu-darwin.git
echo "${pass_user}" | sudo -S mv ubuntu-darwin/ubuntu-darwin /usr/share/plymouth/themes/ubuntu-darwin
echo "${pass_user}" | sudo -S update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/ubuntu-darwin/ubuntu-darwin.plymouth 10
echo "${pass_user}" | sudo -S echo "2" | sudo update-alternatives --config default.plymouth
rm -rf ubuntu-darwin | true

#включаем настройки окон и темы
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark
gsettings set org.gnome.desktop.wm.preferences theme Adwaita-dark
gsettings set org.gnome.desktop.interface icon-theme Numix-Circle
gsettings set  org.gnome.desktop.interface cursor-theme DMZ-White

# включаем свои обоя на рабочий стол и на экран входа в систему
echo "${pass_user}" | sudo -S cp -f 17.jpg /usr/share/backgrounds/
gsettings set org.gnome.desktop.background picture-uri file:////usr/share/backgrounds/17.jpg
# включаем свои обоя на экран входа в систему
#echo "${pass_user}" | sudo -S ./focalgdm3 --set /usr/share/backgrounds/17.jpg

#установка коллекции дополнений GNOME 40
### dconf dump /org/gnome/shell/extensions/ > extensions.conf ###
### dconf dump / > dconf_full.conf ###
### dconf reset -f /org/gnome/shell/extensions/ ###
### dconf load /org/gnome/shell/extensions/ < extensions.conf ###
### gnome-extensions list ###
### for disable gnome-extension ###
rm -fr "/home/${user_run_script}/.local/share/gnome-shell/extensions" || true
tar -xpJf "extensions.tar.xz" -C "/home/${user_run_script}/.local/share/gnome-shell/"
cp -f user "/home/${user_run_script}/.config/dconf"
dconf reset -f /org/gnome/shell/extensions/
dconf load /org/gnome/shell/extensions/ < extensions.conf
#dconf load / < dconf_full.conf
gsettings set org.gnome.shell disable-user-extensions true
gsettings set org.gnome.shell disable-user-extensions false
echo "${root_pass}" | sudo -S pkill -9 ^gnome-shell
sleep 5
gsettings set org.gnome.shell disable-user-extensions true
gsettings set org.gnome.shell disable-user-extensions false

gnome-extensions enable add-to-desktop@tommimon.github.com
gnome-extensions enable dash-to-panel@jderose9.github.com
gnome-extensions enable just-perfection-desktop@just-perfection
gnome-extensions enable drive-menu@gnome-shell-extensions.gcampax.github.com
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
gnome-extensions enable applications-overview-tooltip@RaphaelRochet
gnome-extensions enable bluetooth-quick-connect@bjarosze.gmail.com
gnome-extensions enable blur-my-shell@aunetx
gnome-extensions enable BringOutSubmenuOfPowerOffLogoutButton@pratap.fastmail.fm
gnome-extensions enable caffeine@patapon.info
gnome-extensions enable panel-date-format@atareao.es
gnome-extensions enable gamemode@christian.kellner.me
gnome-extensions enable gsconnect@andyholmes.github.io
gnome-extensions enable impatience@gfxmonk.net
gnome-extensions enable openweather-extension@jenslody.de
gnome-extensions enable workspace-indicator@gnome-shell-extensions.gcampax.github.com
gnome-extensions enable sound-output-device-chooser@kgshank.net
gnome-extensions enable panel-osd@berend.de.schouwer.gmail.com
gnome-extensions enable x11gestures@joseexposito.github.io
gnome-extensions enable compiz-windows-effect@hermes83.github.com
gnome-extensions enable big-avatar@gustavoperedo.org
gnome-extensions enable ding@rastersoft.com
gnome-extensions enable ubuntu-appindicators@ubuntu.com
gnome-extensions enable ubuntu-dock@ubuntu.com

#включаем настройки темной оригинальной темы Ubuntu
gsettings set org.gnome.desktop.interface gtk-theme Yaru-dark
#делаем повторно замену файла конфигруации пользовательского окружения
cp -f user "/home/${user_run_script}/.config/dconf"
#финально перезагружем окружение gnome
echo "${pass_user}" | sudo -S pkill -9 ^gnome-shell

#выходим из временной папки и удаляем ее
cd
echo "${pass_user}" | sudo -S rm -r "${script_dir}/modules-temp/${name_script}/temp" || true

tput setaf 2; echo "Установка ${name_script} завершена!"
tput sgr0

#добавляем информацию в лог установки о уровне ошибок модуля, чем выше цифра, тем больше было ошибок и нужно проверить модуль разработчику
echo "модуль ${name_script}, дата установки:${date_install}, количество ошибок:${error}"	 				  >> "${script_dir}/module_install_log"

exit 0


#Для создания скрипта использовались следующие ссылки
#https://techblog.sdstudio.top/blog/google-drive-vstavliaem-priamuiu-ssylku-na-izobrazhenie-sayta
#https://www.linuxliteos.com/forums/scripting-and-bash/preview-and-download-images-and-files-with-zenity-dialog/
#https://www.ibm.com/developerworks/ru/library/l-zenity/
#https://habr.com/ru/post/281034/
#https://webhamster.ru/mytetrashare/index/mtb0/20
#https://itfb.com.ua/kak-prisvoit-rezultat-komandy-peremennoj-obolochki/
#https://tproger.ru/translations/bash-cheatsheet/
#https://mirivlad.ru/2017/11/20-primerov-ispolzovaniya-potokovogo-tekstovogo-redaktora-sed/
#https://www.opennet.ru/docs/RUS/bash_scripting_guide/c1833.html
#https://losst.ru/massivy-bash
#https://www.shellhacks.com/ru/grep-or-grep-and-grep-not-match-multiple-patterns/
#https://techrocks.ru/2019/01/21/bash-if-statements-tips/
#https://habr.com/ru/post/511608/
#https://techrocks.ru/2019/01/21/bash-if-statements-tips/

