#!/bin/sh

# netsh advfirewall set allprofiles state on
# netsh advfirewall set allprofiles state off

# netsh advfirewall set allprofiles state on
# netsh advfirewall set allprofiles state off

# http://stackoverflow.com/questions/11351651/how-to-check-windows-firewall-is-enabled-or-not-using-commands

if test -z "$(env | grep WINDIR)"
then
    # Linux
    sudo ufw status verbose
else
    # Windows
    {
	netsh advfirewall show private
	netsh advfirewall show public
	netsh advfirewall show domain
    } 2>&1
fi
