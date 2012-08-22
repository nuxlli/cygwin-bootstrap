#!/usr/bin/env bash

remoteuser=$USERNAME

# Fix permissions
chmod +r /etc/passwd
chmod +r /etc/group
chmod 111 /var

# add user to Cygwin's user list
# if -n grep "^${remoteuser}:" /etc/passwd ; then
#  mkpasswd -u $remoteuser -l >> /etc/passwd
#fi

# configure SSH service
ssh-host-config -p 22 -u $remoteuser -y

# fixing log permission
log_file=/var/log/sshd.log
touch $log_file
chown sshd $log_file

# Firewall configure
netsh advfirewall firewall add rule name="SSH" dir=in action=allow service=any enable=yes profile=any localport=22 protocol=tcp 

# start service
cygrunsrv -S sshd

#echo "Cygwin instaled!"
#echo "TODO: implement the ssh configuration"
