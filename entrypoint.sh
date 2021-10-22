#!/bin/bash
set -e

# set timezone
rm /etc/localtime
ln -s /usr/share/zoneinfo/$LOCALTIME /etc/localtime

# make sure we are running the latest version of jotta-cli
apt-get update
apt-get install jotta-cli
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/lists/*

# set the jottad user and group id
usermod -u $PUID jottad
usermod --gid $PGID jottad
usermod -a -G jottad jottad

sed -i 's+user="jottad"+user="'$JOTTAD_USER'"+g' /etc/init.d/jottad
sed -i 's+user="jottad"+group="'$JOTTAD_GROUP'"+g' /etc/init.d/jottad

chown jottad /var/lib/jottad -R

if [ $# -eq 1 ] && [ "$@" = "bash" ]; then
  exec "$@"
fi

# start the service
/etc/init.d/jottad start

# wait for service to fully start
sleep 5

# Exit on error no longer needed. Also, it would prevent detecting jotta-cli status
set +e

echo -n "Wait jottad to start for $STARTUP_TIMEOUT seconds. "
# inspired by https://github.com/Eficode/wait-for
while :; do
  timeout 1 jotta-cli status >/dev/null 2>&1
  R=$?

  if [ $R -eq 0 ] ; then
    echo "Jotta started."
    break
  fi

  if [ $R -ne 0 ]; then
    if [[ "$(timeout 1 jotta-cli status 2>&1)" =~ "Found remote device that matches this machine" ]]; then
      echo -n "..found matching device name.."
      /usr/bin/expect -c "
      set timeout 1
      spawn jotta-cli status
      expect \"Do you want to re-use this device? (yes/no): \" {send \"yes\n\"}
      expect eof
      "

    elif [[ "$(timeout 1 jotta-cli status 2>&1)" =~ "Error: The session has been revoked." ]]; then
      echo -n "Session expired. Logging out."
      jotta-cli logout

      echo -n "Logging in again."
      # Login user
      /usr/bin/expect -c "
      set timeout 20
      spawn jotta-cli login
      expect \"accept license (yes/no): \" {send \"yes\n\"}
      expect \"Personal login token: \" {send \"$JOTTA_TOKEN\n\"}
      expect \"Do you want to re-use this device? (yes/no): \" {send \"yes\n\"}
      expect eof
      # TODO: Jotta may return "Found remote device that matches this machine", where a yes/no answer could be given automatically
      "

    elif [[ "$(timeout 1 jotta-cli status 2>&1)" =~ "Not logged in" ]]; then
      echo -n "First time login. Logging in."

      # Login user
      /usr/bin/expect -c "
      set timeout 20
      spawn jotta-cli login
      expect \"accept license (yes/no): \" {send \"yes\n\"}
      expect \"Personal login token: \" {send \"$JOTTA_TOKEN\n\"}
      expect \"Devicename*: \" {send \"$JOTTA_DEVICE\n\"}
      expect eof
      # TODO: Jotta may return "Found remote device that matches this machine", where a yes/no answer could be given automatically
      "
    fi
  fi

  if [ "$STARTUP_TIMEOUT" -le 0 ]; then
    echo "waited for too long to start ($STARTUP_TIMEOUT seconds)"
    echo "ERROR: Not able to determine why Jotta cannot start:"
    jotta-cli status
    exit 1
    break
  fi

  STARTUP_TIMEOUT=$((STARTUP_TIMEOUT - 1))
  echo -n ".$STARTUP_TIMEOUT."
  sleep 1
done


echo "Adding backups"

for dir in /backup/* ; do if [ -d "${dir}" ]; then set +e && jotta-cli add /$dir && set -e; fi; done

# load ignore file
if [ -f /config/ignorefile ]; then
  echo "loading ignore file"
  jotta-cli ignores set /config/ignorefile
fi

# set scan interval
echo "Setting scan interval"
jotta-cli config set scaninterval $JOTTA_SCANINTERVAL

jotta-cli tail &

R=0
while [[ $R -eq 0 ]]
do
	sleep 15
	jotta-cli status >/dev/null 2>&1
        R=$?
done

echo "Exiting:"
jotta-cli status
exit 1
