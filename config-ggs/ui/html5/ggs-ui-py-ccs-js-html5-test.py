#!/usr/bin/env python3
import os
import sys
import gi
import glob
gi.require_version('Soup', '2.4')
import webview

class Api():
  def log(self, value):
    print(value)
    if value == "exit":
       print("run exit")
       window.destroy()    

window = webview.create_window('GGS-web-gui-test', 'html5-ui-base-run-2.html', width=1064, height=512, js_api=Api())
webview.start(window)

