#!/bin/bash
#creator by RedRoot(Yaciyna Mikhail) for GAMER STATION [on linux] and Gaming Community OS Linux
# GPL-3.0 License 

html5_head="<!DOCTYPE html>
<html>
	<head>

		<title>Gnome-Gui-Switcher-ui-html5</title>
		<meta charset="UTF-8">
		<style>"
html5_style_body=" 
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
 "
html5_nav=" 
			.nav {
			  padding: 0px;
			  width: 1024;
			}
 "
 html5_button="
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
					}

			</style>"
html5_scripts="<script>
	window.console = window.console || function(t) {};
  </script>



	<script>
	if (document.location.search.match(/type=embed/gi)) {
	  window.parent.postMessage("resize", "*");
	}
  </script>

	</head>
     "
html5_body="	<body translate="no">
  <ul class="nav">"

html5_body_end=" 
  <div class="background"></div>
  </ul>
  <div class="button-red">
	<a href="exit-app"><span>ВЫХОД</span></a>
  </div>

   </body>
</html>"

html5_styles_sample=".image-sample {
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
    }"

html5_background_global_for_style_conf=" 
			.nav li:nth-child(1):hover ~ .background {
			  background: #05386b;
			}
 "