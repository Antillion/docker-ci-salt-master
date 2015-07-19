#!/bin/bash

# Variables from environement
: "${SALT_USE:=master}"
: "${SALT_NAME:=master}"
: "${LOG_LEVEL:=info}"
: "${OPTIONS:=}"
echo "WARN: Remember - do NOT use this for production builds"
# Set minion id
echo $SALT_NAME > /etc/salt/minion_id

# If salt master also start minion in background
if [ $SALT_USE == "master" ]; then
  echo "INFO: Starting salt-minion and auto connect to salt-master"
  sudo service salt-minion start
fi

# Set salt grains
if [ ! -z "$SALT_GRAINS" ]; then
  echo "INFO: Set grains on $SALT_NAME to: $SALT_GRAINS"
  echo $SALT_GRAINS > /etc/salt/grains
fi

echo "INFO: Starting SSHD"
#/usr/sbin/sshd -D &
service ssh start
echo "INFO: Starting salt-api"
service salt-api start
# Start salt-$SALT_USE
#echo "INFO: Starting salt-$SALT_USE with log level $LOG_LEVEL with hostname $SALT_NAME"
#sudo /usr/bin/salt-$SALT_USE --log-level=$LOG_LEVEL $OPTIONS
echo "INFO: Starting salt-master"
#service salt-master start
#sudo salt-master --log-level=$LOG_LEVEL $OPTIONS
service salt-master start
tail -f /var/log/salt/salt-master.log
