#!/bin/bash

NEWX=$(ls -Art /tmp/resonances_x_*.csv | tail -n 1)
DATE=$(date +'%Y-%m-%d-%H%M%S')
if [ ! -d "~/printer_data/config/input_shaper" ]
then
    mkdir ~/printer_data/config/input_shaper
    chown pi:pi ~/printer_data/config/input_shaper
fi

~/klipper/scripts/calibrate_shaper.py $NEWX -o ~/printer_data/config/input_shaper/resonances_x_$DATE.png
