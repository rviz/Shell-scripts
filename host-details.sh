#! /bin/bash

# unset any variable which system may be using
unset resetcol os architecture kernelrelease internalip externalip nameserver loadaverage sysuptime

# Define Variable resetcol
resetcol=$(tput sgr0)

# Check OS Type
os=$(uname -o)
echo -e '\E[32m'"OS Type \t:" $resetcol $os

# Check OS Release Version and Name
###################################
OS=`uname -s`
REV=`uname -r`
MACH=`uname -m`

GetVersionFromFile()
{
    VERSION=`cat $1 | tr "\n" ' ' | sed s/.*VERSION.*=\ // `
}

if [ "${OS}" = "SunOS" ] ; then
    OS=Solaris
    ARCH=`uname -p`
    OSSTR="${OS} ${REV}(${ARCH} `uname -v`)"
elif [ "${OS}" = "AIX" ] ; then
    OSSTR="${OS} `oslevel` (`oslevel -r`)"
elif [ "${OS}" = "Linux" ] ; then
    KERNEL=`uname -r`
    if [ -f /etc/redhat-release ] ; then
        DIST='RedHat'
        PSUEDONAME=`cat /etc/redhat-release | sed s/.*\(// | sed s/\)//`
        REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
    elif [ -f /etc/SuSE-release ] ; then
        DIST=`cat /etc/SuSE-release | tr "\n" ' '| sed s/VERSION.*//`
        REV=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
    elif [ -f /etc/mandrake-release ] ; then
        DIST='Mandrake'
        PSUEDONAME=`cat /etc/mandrake-release | sed s/.*\(// | sed s/\)//`
        REV=`cat /etc/mandrake-release | sed s/.*release\ // | sed s/\ .*//`
    elif [ -f /etc/os-release ]; then
	DIST=`awk -F "PRETTY_NAME=" '{print $2}' /etc/os-release | tr -d '\n"'`
    elif [ -f /etc/debian_version ] ; then
        DIST="Debian `cat /etc/debian_version`"
        REV=""

    fi
    if ${OSSTR} [ -f /etc/UnitedLinux-release ] ; then
        DIST="${DIST}[`cat /etc/UnitedLinux-release | tr "\n" ' ' | sed s/VERSION.*//`]"
    fi

    OSSTR="${OS} ${DIST} ${REV}(${PSUEDONAME} ${KERNEL} ${MACH})"

fi
##################################
echo -e '\E[32m'"OS Version \t:" $resetcol $OSSTR 

# Check Architecture
architecture=$(uname -m)
echo -e '\E[32m'"Architecture \t:" $resetcol $architecture

# Check Kernel Release
kernelrelease=$(uname -r)
echo -e '\E[32m'"Kernel Release \t:" $resetcol $kernelrelease

# Check hostname
echo -e '\E[32m'"Hostname \t:" $resetcol $HOSTNAME

# Check Internal IP
internalip=$(hostname -I)
echo -e '\E[32m'"Internal IP \t:" $resetcol $internalip

# Check External IP
externalip=$(dig +short myip.opendns.com @resolver1.opendns.com)
echo -e '\E[32m'"External IP \t: $resetcol "$externalip

# Check DNS
nameservers=$(cat /etc/resolv.conf | sed '1 d' | awk '{print $2}')
echo -e '\E[32m'"Name Servers \t:" $resetcol $nameservers 

# Check Logged In Users
who>/tmp/who
echo -e '\E[32m'"Logged In users :" $resetcol && cat /tmp/who 

# Check RAM and SWAP Usages
free -h | grep -v + > /tmp/ramcache
echo -e '\E[32m'"Ram Usages \t:" $resetcol
cat /tmp/ramcache | grep -v "Swap"
echo -e '\E[32m'"Swap Usages \t:" $resetcol
cat /tmp/ramcache | grep -v "Mem"

# Check Disk Usages
df -h| grep 'Filesystem\|^/dev/*' > /tmp/diskusage
echo -e '\E[32m'"Disk Usages \t:" $resetcol 
cat /tmp/diskusage

# Check Load Average
loadaverage=$(top -n 1 -b | grep "load average:" | awk '{print $10 $11 $12}')
echo -e '\E[32m'"Load Average \t:" $resetcol $loadaverage

# Check System Uptime
sysuptime=$(uptime -p | awk '!($1="")')
echo -e '\E[32m'"System Uptime \t:" $resetcol $sysuptime

# Unset Variables
unset resetcol os architecture kernelrelease internalip externalip nameserver loadaverage sysuptime

# Remove Temporary Files
rm /tmp/who /tmp/ramcache /tmp/diskusage
