#!/bin/bash

source ~/printer_data/config/3dwork-klipper/scripts/moonraker-ensure-policykit-rules.sh
ensure_moonraker_policiykit_rules

validate_moonraker_config()
{
  echo "Ensuring valid moonraker config.."
  install_version=$(~/moonraker-env/bin/python -mlmdb -e ~/.moonraker_database/ -d moonraker get validate_install)
  cat ~/printer_data/config/moonraker.conf | grep "\[include 3dwork-klipper/moonraker.conf\]" > /dev/null
  has_include=$?
  if [ $has_include -eq 0 ] && [ "$install_version" = "'validate_install': missing" ]; then
    # Temporarily replace with old config
    echo "Installing old moonraker config.."
	echo $has_include
	echo $install_version
    # cp ~/printer_data/config/3dwork-klipper/old-moonraker.conf ~/printer_data/config/3dwork-klipper/moonraker.conf
  fi
}

validate_moonraker_config
