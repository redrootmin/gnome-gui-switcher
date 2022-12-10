#!/bin/bash
#creator by RedRoot(Yaciyna Mikhail) for GAMER STATION [on linux] and Gaming Community OS Linux
# GPL-3.0 License 

html5_head='<!DOCTYPE html>
<html>
 <head>

 <title>Gnome-Gui-Switcher-ui-html5</title>
 <meta charset="UTF-8">
<style>
 '
html5_style_body=' 
body {
 background: #303030;
 font-family: "Roboto", sans-serif;
 text-shadow: 0.5px 0.5px 0 #CCCCCC;
}

.background {
 position: fixed;
 z-index: -1;
 top: 0;
 right: 0;
 bottom: 0;
 left: 0;
 transition: 0.75s;
}

 ul {
 list-style-type: none;

}

li a {
 padding: 5px;
 float: left;
 width: 256px;
 text-align: center;
 font-size: 15px;
 color: #edf5e1;
 text-decoration: none;
}
 '
html5_style_nav=' 
.nav {
 padding: 0px;
 width: 1024;
}
 '
 html5_style_button='
.button-red {
 position: fixed;
 top: 94%;
 left: 89%;
 transform: translate(-50%, -50%);
}
.button-red a {
 display: block;
 width: 200px;
 height: 40px;
 line-height: 40px;
 font-size: 18px;
 font-family: sans-serif;
 text-decoration: none;
 color: rgb(184, 184, 184);
 border: 2px solid rgb(0, 0, 0);
 letter-spacing: 2px;
 text-align: center;
 position: relative;
 transition: all .35s;
}

.button-red a span{
 position: relative;
 z-index: 2;
}

.button-red a:after{
 position: absolute;
 content: "";
 top: 0;
 left: 0;
 width: 0;
 height: 100%;
 background: #830926;
 transition: all .35s;
}

.button-red a:hover{
 color: #fff;
 border: 2px solid rgb(255, 255, 255);
}

.button-red a:hover:after{
 width: 100%;
}'
html5_style_end=' 
</style>
 '
html5_scripts='<script>
window.console = window.console || function(t) {};
</script>



<script>
 if (document.location.search.match(/type=embed/gi)) {
 window.parent.postMessage("resize", "*");
 }
</script>

</head>
 '
html5_body=' 
<body translate="no">
<ul class="nav">
 '

html5_body_end='  
 <div class="background"></div>
 </ul>
 <div class="button-red">
 <a href="exit-app"><span>ВЫХОД</span></a>
 </div>

 </body>
</html>
 '

html5_styles_sample='.image-sample {
        width: 256px;
        height: 144px;
        background: url(data:image/png;base64,####) no-repeat;
    }

	.image-sample {
		transition: transform .25s, filter .25s ease-in-out;
		transform-origin: center center;
    }

    .image-sample:hover  {
  		transform: scale(1.1);
    }'

html5_background_global_for_style_conf=' 
			.nav li:nth-child(1):hover ~ .background {
			  background: #05386b;
			}
 '

gnome_pack=`cat "$config_ggs_dir/conf/gnome-pack-run"`
readarray -t style_all_pack < "$config_ggs_dir/conf/base_for_menu_ggs"
info_gnome_pack_styles="Формируем меню из набора стилей $gnome_pack"
echo "$info_gnome_pack_styles" >> "$config_ggs_dir/logs/log-menu-ggs-generator"
echo "$info_gnome_pack_styles"
html5_ui_base+="${html5_head}"
html5_ui_base+="${html5_style_body}"
html5_ui_base+="${html5_style_nav}"
html5_ui_base+="${html5_style_button}"

 for style_pack in "${style_all_pack[@]}" 
  do
 let n+=1
 images_style=`cat "$config_ggs_dir/gnome-packs/$gnome_pack/style-packs/$style_pack/image.base64"`
 color_style=`cat "$config_ggs_dir/gnome-packs/$gnome_pack/style-packs/$style_pack/background-color-ui-html5"`
 html5_ui_base+=" 
.${style_pack}"' {
 width: 256px;
 height: 144px;
 background: url('"${images_style}"') no-repeat;
}

.'"${style_pack}"' {
 transition: transform .25s, filter .25s ease-in-out;
 transform-origin: center center;
}

.'"${style_pack}"':hover  {
 transform: scale(1.1);
}

.nav li:nth-child('"${n}"'):hover ~ .background {
 background: '"${color_style}"';
}
 '
	
  done
html5_ui_base+="$html5_style_end"
html5_ui_base+="$html5_scripts"
html5_ui_base+="$html5_body"

let n=0
 for style_pack in "${style_all_pack[@]}" 
  do
  let n+=1
html5_ui_base+=' 
	<li>
		<a href="'"$style_pack"'" target="_blank">
		  <div class="circle"></div>
		  <div class="'"$style_pack"'"></div>
		</a>
	  </li>
 '

  done
html5_ui_base+="$html5_body_end"
echo "$html5_ui_base" > "$config_ggs_dir/ui/html5/html5-ui-base-run.html"
info_gnome_pack_styles="Меню набора стилей $gnome_pack сгенерировано в формате html5[$config_ggs_dir/ui/html5/html5-ui-base-run.html]"
echo "$info_gnome_pack_styles" >> "$config_ggs_dir/logs/log-menu-ggs-generator"
echo "$info_gnome_pack_styles"
export html5_ui_base_global=$html5_ui_base