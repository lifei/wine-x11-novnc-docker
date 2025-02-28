#!/usr/bin/env bash

wine64 /opt/python-3.9.13/python.exe /opt/python-3.9.13/get-pip.py --no-warn-script-location
wine64 /opt/python-3.9.13/python.exe -m pip install -U wcferry
winetricks fonts cjkfonts
