#!/data/data/com.termux/files/usr/bin/env bash
##
## Script for managing Exagear'ed Linux distribution installations/running in Termux.
##
## Copyright (C) 2020 Zhymabek_Roman <***REMOVED***>
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <http://www.gnu.org/licenses/>.
##

PROGRAM_VERSION="0.5 beta"

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

function print_welcome_message {
    clear
    echo -e "
░█░█░█▀█░█▀▄░█▀█
░░▀█░█▀▀░█░█░█▀█
░░░▀░▀░░░▀▀░░▀░▀
    "
    echo "Exagear for Termux by Zhymabek_Roman"
    echo "Version: $PROGRAM_VERSION"
    echo "Made with love from Kazakhstan : )"
    echo -e "\nCopyright (c) 2013-2019 'Elbrus Technologies' LLC. All rights reserved.\n\nThis program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE."
    echo -e "\n"
}

function print_usage_and_exit {
    echo 'Usage: ./start-exagear.sh [path_to_image]'
    exit 0
}

function edit_passwd {
cat > $1/etc/passwd <<-EOM
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync
games:x:5:60:games:/usr/games:/usr/sbin/nologin
man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
uucp:x:10:10:uucp:/var/spool/uucp:/usr/sbin/nologin
proxy:x:13:13:proxy:/bin:/usr/sbin/nologin
www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
backup:x:34:34:backup:/var/backups:/usr/sbin/nologin
list:x:38:38:Mailing List Manager:/var/list:/usr/sbin/nologin
irc:x:39:39:ircd:/var/run/ircd:/usr/sbin/nologin
gnats:x:41:41:Gnats Bug-Reporting System (admin):/var/lib/gnats:/usr/sbin/nologin
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
systemd-timesync:x:100:102:systemd Time Synchronization,,,:/run/systemd:/bin/false
systemd-network:x:101:103:systemd Network Management,,,:/run/systemd/netif:/bin/false
systemd-resolve:x:102:104:systemd Resolver,,,:/run/systemd/resolve:/bin/false
systemd-bus-proxy:x:103:105:systemd Bus Proxy,,,:/run/systemd:/bin/false
syslog:x:104:108::/home/syslog:/bin/false
_apt:x:105:65534::/nonexistent:/bin/false
messagebus:x:106:110::/var/run/dbus:/bin/false
pulse:x:107:112:PulseAudio daemon,,,:/var/run/pulse:/bin/false
rtkit:x:108:114:RealtimeKit,,,:/proc:/bin/false
EOM
}

function start_guest {
    case `cat $1/etc/passwd` in
		  xdroid:x:10287:10287::/home/xdroid/:/bin/sh)
		     echo -e "Editing passwd for better compatibility\n"
		    	edit_passwd $1 ;;
	   	"")
			    echo "'passwd' in guest not found. Exiting"; edit_passwd $1;;
		esac
		
    # unset LD_PRELOAD in case termux-exec is installed
   	# We need this to disable the preloaded libtermux-exec.so library
	  	# which redefines 'execve()' implementation.
    unset LD_PRELOAD

	    # /etc/resolv.conf may not be configured, so write in it our configuraton.
    		echo -e "Writing resolv.conf file (NS 1.1.1.1/1.0.0.1)...\n"
    		rm -f $1/etc/resolv.conf
cat <<- EOF > $1/etc/resolv.conf
nameserver 1.1.1.1
nameserver 1.0.0.1
EOF

    if [ ! -d $1/storage/ ]; then
      # Control will enter here if 'storage' doesn't exist.
      echo -e "Folder 'storage' in guest system not found. Creating....\n"
      mkdir $1/storage/
    fi

    $test_binary
    test_bin_ret=$?
    
    if [ "$test_bin_ret" -eq  '0' ]; then
      is_3g="1"
      echo -e "System memory configuration is determined as 3g/1g\n"
    else
      is_3g="0"
      echo -e "System memory configuration is determined as 2g/2g\n"
    fi

    command=""
    command+=" --use-sugid-wrapper `pwd`/ubt-sugid-wrapper "
    command+=" --allow-dash-dash-x"
    command+=" --path-prefix $1"
    command+=" --vfs-hacks=tlsasws,tsi,spd"
    command+=" --vfs-kind guest-first"
    command+=" --vpaths-list `pwd`/vpaths-list"
    command+=" --tmp-dir $1/tmp"
    command+=" --force-shm-align"
    command+=' -- /usr/bin/env -i 
    USER=root
    HOME=/root
    PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr
    LANG=en_US.utf8
    LANGUAGE=en_US.utf8
    LC_ALL=C
    BASH=/bin/bash
    SHELL=/bin/bash 
    PREFIX=/usr
    TERM=xterm 
    TMDIR=/tmp
    LD_LIBRARY_PATH=/lib:/usr/lib:/usr/lib/i386-linux-gnu/:/var/lib:/var/lib/dpkg/:/lib/i386-linux-gnu:/usr/local/lib/'
    if [ -f  $1/usr/bin/fakeroot-tcp ]; then
        command+=" /usr/bin/fakeroot-tcp"
    else 
        echo -e "'fakeroot' does not exist. You may be using a different image of the system and you may have problems with administrative rights. \n"
    fi
    command+=" /bin/bash --login "
    
    echo -e  "${GREEN}[Starting x86 environment]${NC}\n"
    
    ./ubt_x32a32_al_mem3g $command
    
    echo -e "\n${GREEN}[Exit from x86 environment]${NC}\n"
}

if [ "$1" == "--usage" ] || [ "$1" == "--help" ] || [ "$1" == "-h" ] || [ "$1" == "-dh" ]; then
    print_usage_and_exit
elif [ "$1" == "" ]; then
    print_welcome_message
    start_guest `pwd`/exagear-fs
else
    print_welcome_message
    start_guest $1
fi
