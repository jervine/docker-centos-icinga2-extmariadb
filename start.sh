#!/bin/bash
##
## Start up script for Icinga2 on CentOS docker container
##

## Initialise any variables being called:
# Set the correct timezone for PHP
PHP_TZ=${TZ:-UTC}
PHP_TZ_CONT=`echo $PHP_TZ | awk 'BEGIN { FS="/" } { print $1 }'`
PHP_TZ_CITY=`echo $PHP_TZ | awk 'BEGIN { FS="/" } { print $2 }'`
setup=/config/.setup

## The remaining initialisation is contained in an if condition. When the initialisation completes an empty /etc/icinga2/.setup file is created. If this exists the initialisation is skipped. By deleting this file, the initialisation can be restarted.
if [ ! -f "${setup}" ]; then

  ## Set up basic Icinga2 configuration/features
  # Enable feature: ido-mysql
  if [[ -L /etc/icinga2/features-enabled/ido-mysql.conf ]]; then
    echo "Symlink for /etc/icinga2/features-enabled/ido-mysql.conf exists already...skipping"
  else
    ln -s /etc/icinga2/features-available/ido-mysql.conf /etc/icinga2/features-enabled/ido-mysql.conf
  fi

  # Enable feature: checker
  if [[ -L /etc/icinga2/features-enabled/checker.conf ]]; then
    echo "Symlink for /etc/icinga2/features-enabled/checker.conf exists already... skipping"
  else
    ln -s /etc/icinga2/features-available/checker.conf /etc/icinga2/features-enabled/checker.conf
  fi

  # Enable feature: mainlog
  if [[ -L /etc/icinga2/features-enabled/mainlog.conf ]]; then
    echo "Symlink for /etc/icinga2/features-enabled/mainlog.conf exists already... skipping"
  else
    ln -s /etc/icinga2/features-available/mainlog.conf /etc/icinga2/features-enabled/mainlog.conf
  fi

  # Enable feature: command >> /dev/null
  if [[ -L /etc/icinga2/features-enabled/command.conf ]]; then
    echo "Symlink for /etc/icinga2/features-enabled/command.conf exists already...skipping"
  else
    ln -s /etc/icinga2/features-available/command.conf /etc/icinga2/features-enabled/command.conf
  fi

  # Enable feature: livestatus >> /dev/null
  if [[ -L /etc/icinga2/features-enabled/livestatus.conf ]]; then
    echo "Symlink for /etc/icinga2/features-enabled/livestatus.conf exists already...skipping"
  else
    ln -s /etc/icinga2/features-available/livestatus.conf /etc/icinga2/features-enabled/livestatus.conf
  fi
  
  ## Initialising the icingaweb2 configuration
#  if [[ -L /etc/icingaweb2 ]]; then
#    echo "Icinga2 web configuration directory already exists...skipping"
#  else
#    cd /usr/share/icingaweb2
#    icingacli setup config directory
#    icingacli setup token create
#  fi

  # Configure the PHP timezone correctly:
  if [ "$PHP_TZ_CITY" = "" ]; then
    sed -i "s/;date.timezone =/date.timezone = ${PHP_TZ_CONT}/" /etc/opt/rh/rh-php71/php.ini
  else
    sed -i "s/;date.timezone =/date.timezone = ${PHP_TZ_CONT}\/${PHP_TZ_CITY}/" /etc/opt/rh/rh-php71/php.ini
  fi

# Mark the setup as complete
  touch /config/.setup
fi


## Start up icinga2 and apache web server daemons via supervisord
/usr/bin/supervisord -n -c /etc/supervisord.conf
