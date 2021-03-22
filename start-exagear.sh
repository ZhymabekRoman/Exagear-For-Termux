#!/bin/bash
##
## Script for managing Exagear'ed Linux distribution installations/running in Termux.
## by Zhymabek Roman
##
## Some pieces of code were taken from proot-distro: https://github.com/termux/proot-distro

# Constants 
PROGRAM_NAME="ExaGear for Termux"
PROGRAM_VERSION="2.0"
CURRENT_WORK_FOLDER=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
DEFAULT_ROOTFS_FOLDER=""$CURRENT_WORK_FOLDER"/exagear-fs/"

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

# Check whether it is running, in the root or normal environment.
if [ "$(id -u)" = "0" ]; then
	echo
	echo -e "Error: '${PROGRAM_NAME}' should not be used as root."
	echo
	exit 1
fi

function print_welcome_message {
    echo -e "
    ░█░█░█▀█░█▀▄░█▀█
    ░░▀█░█▀▀░█░█░█▀█
    ░░░▀░▀░░░▀▀░░▀░▀
    "
    echo "${PROGRAM_NAME} by Zhymabek_Roman"
    echo "Version: ${PROGRAM_VERSION}"
    echo -e "Copyright (c) 2013-2019 'Elbrus Technologies' LLC. All rights reserved.\n\nThis program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE."
    echo -e "\n"
}

function print_usage_and_exit {
    echo 'Usage: ./start-exagear.sh'
    exit 0
}

function edit_passwd
{
	local rootfs_path="$1"

	cat <<- EOF > ""$rootfs_path"/etc/passwd"
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
	EOF
}

function setup_fake_proc
{
    local rootfs_path="$1"

	mkdir -p ""$rootfs_path"/proc"
	chmod 700 ""$rootfs_path"/proc"
    mkdir -p ""$rootfs_path"/sys/fs/selinux/"

	if [ ! -f ""$rootfs_path"/sys/fs/selinux/enforce" ]; then
		cat <<- EOF > ""$rootfs_path"/sys/fs/selinux/enforce"
		0
		EOF
	fi

	if [ ! -f ""$rootfs_path"/proc/.loadavg" ]; then
		cat <<- EOF > ""$rootfs_path"/proc/.loadavg"
		0.54 0.41 0.30 1/931 370386
		EOF
	fi

	if [ ! -f ""$rootfs_path"/proc/.stat" ]; then
		cat <<- EOF > ""$rootfs_path"/proc/.stat"
		cpu  1050008 127632 898432 43828767 37203 63 99244 0 0 0
		cpu0 212383 20476 204704 8389202 7253 42 12597 0 0 0
		cpu1 224452 24947 215570 8372502 8135 4 42768 0 0 0
		cpu2 222993 17440 200925 8424262 8069 9 17732 0 0 0
		cpu3 186835 8775 195974 8486330 5746 3 8360 0 0 0
		cpu4 107075 32886 48854 8688521 3995 4 5758 0 0 0
		cpu5 90733 20914 27798 1429573 2984 1 11419 0 0 0
		intr 53261351 0 686 1 0 0 1 12 31 1 20 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7818 0 0 0 0 0 0 0 0 255 33 1912 33 0 0 0 0 0 0 3449534 2315885 2150546 2399277 696281 339300 22642 19371 0 0 0 0 0 0 0 0 0 0 0 2199 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2445 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 162240 14293 2858 0 151709 151592 0 0 0 284534 0 0 0 0 0 0 0 0 0 0 0 0 0 0 185353 0 0 938962 0 0 0 0 736100 0 0 1 1209 27960 0 0 0 0 0 0 0 0 303 115968 452839 2 0 0 0 0 0 0 0 0 0 0 0 0 0 160361 8835 86413 1292 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3592 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 6091 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 35667 0 0 156823 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 138 2667417 0 41 4008 952 16633 533480 0 0 0 0 0 0 262506 0 0 0 0 0 0 126 0 0 1558488 0 4 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 2 8 0 0 6 0 0 0 10 3 4 0 0 0 0 0 3 0 0 0 0 0 0 0 0 0 0 0 20 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 12 1 1 83806 0 1 1 0 1 0 1 1 319686 2 8 0 0 0 0 0 0 0 0 0 244534 0 1 10 9 0 10 112 107 40 221 0 0 0 144
		ctxt 90182396
		btime 1595203295
		processes 270853
		procs_running 2
		procs_blocked 0
		softirq 25293348 2883 7658936 40779 539155 497187 2864 1908702 7229194 279723 7133925
		EOF
	fi

	if [ ! -f ""$rootfs_path"/proc/.uptime" ]; then
		cat <<- EOF > ""$rootfs_path"/proc/.uptime"
		284684.56 513853.46
		EOF
	fi

	if [ ! -f ""$rootfs_path"/proc/.version" ]; then
		cat <<- EOF > ""$rootfs_path"/proc/.version"
		Linux version 5.4.0-faked (termux@androidos) (gcc version 4.9.x (Faked /proc/version by Exagear-For-Termux) ) #1 SMP PREEMPT Fri Jul 10 00:00:00 UTC 2020
		EOF
	fi

	if [ ! -f ""$rootfs_path"/proc/.vmstat" ]; then
		cat <<- EOF > ""$rootfs_path"/proc/.vmstat"
		nr_free_pages 146031
		nr_zone_inactive_anon 196744
		nr_zone_active_anon 301503
		nr_zone_inactive_file 2457066
		nr_zone_active_file 729742
		nr_zone_unevictable 164
		nr_zone_write_pending 8
		nr_mlock 34
		nr_page_table_pages 6925
		nr_kernel_stack 13216
		nr_bounce 0
		nr_zspages 0
		nr_free_cma 0
		numa_hit 672391199
		numa_miss 0
		numa_foreign 0
		numa_interleave 62816
		numa_local 672391199
		numa_other 0
		nr_inactive_anon 196744
		nr_active_anon 301503
		nr_inactive_file 2457066
		nr_active_file 729742
		nr_unevictable 164
		nr_slab_reclaimable 132891
		nr_slab_unreclaimable 38582
		nr_isolated_anon 0
		nr_isolated_file 0
		workingset_nodes 25623
		workingset_refault 46689297
		workingset_activate 4043141
		workingset_restore 413848
		workingset_nodereclaim 35082
		nr_anon_pages 599893
		nr_mapped 136339
		nr_file_pages 3086333
		nr_dirty 8
		nr_writeback 0
		nr_writeback_temp 0
		nr_shmem 13743
		nr_shmem_hugepages 0
		nr_shmem_pmdmapped 0
		nr_file_hugepages 0
		nr_file_pmdmapped 0
		nr_anon_transparent_hugepages 57
		nr_unstable 0
		nr_vmscan_write 57250
		nr_vmscan_immediate_reclaim 2673
		nr_dirtied 79585373
		nr_written 72662315
		nr_kernel_misc_reclaimable 0
		nr_dirty_threshold 657954
		nr_dirty_background_threshold 328575
		pgpgin 372097889
		pgpgout 296950969
		pswpin 14675
		pswpout 59294
		pgalloc_dma 4
		pgalloc_dma32 101793210
		pgalloc_normal 614157703
		pgalloc_movable 0
		allocstall_dma 0
		allocstall_dma32 0
		allocstall_normal 184
		allocstall_movable 239
		pgskip_dma 0
		pgskip_dma32 0
		pgskip_normal 0
		pgskip_movable 0
		pgfree 716918803
		pgactivate 68768195
		pgdeactivate 7278211
		pglazyfree 1398441
		pgfault 491284262
		pgmajfault 86567
		pglazyfreed 1000581
		pgrefill 7551461
		pgsteal_kswapd 130545619
		pgsteal_direct 205772
		pgscan_kswapd 131219641
		pgscan_direct 207173
		pgscan_direct_throttle 0
		zone_reclaim_failed 0
		pginodesteal 8055
		slabs_scanned 9977903
		kswapd_inodesteal 13337022
		kswapd_low_wmark_hit_quickly 33796
		kswapd_high_wmark_hit_quickly 3948
		pageoutrun 43580
		pgrotated 200299
		drop_pagecache 0
		drop_slab 0
		oom_kill 0
		numa_pte_updates 0
		numa_huge_pte_updates 0
		numa_hint_faults 0
		numa_hint_faults_local 0
		numa_pages_migrated 0
		pgmigrate_success 768502
		pgmigrate_fail 1670
		compact_migrate_scanned 1288646
		compact_free_scanned 44388226
		compact_isolated 1575815
		compact_stall 863
		compact_fail 392
		compact_success 471
		compact_daemon_wake 975
		compact_daemon_migrate_scanned 613634
		compact_daemon_free_scanned 26884944
		htlb_buddy_alloc_success 0
		htlb_buddy_alloc_fail 0
		unevictable_pgs_culled 258910
		unevictable_pgs_scanned 3690
		unevictable_pgs_rescued 200643
		unevictable_pgs_mlocked 199204
		unevictable_pgs_munlocked 199164
		unevictable_pgs_cleared 6
		unevictable_pgs_stranded 6
		thp_fault_alloc 10655
		thp_fault_fallback 130
		thp_collapse_alloc 655
		thp_collapse_alloc_failed 50
		thp_file_alloc 0
		thp_file_mapped 0
		thp_split_page 612
		thp_split_page_failed 0
		thp_deferred_split_page 11238
		thp_split_pmd 632
		thp_split_pud 0
		thp_zero_page_alloc 2
		thp_zero_page_alloc_failed 0
		thp_swpout 4
		thp_swpout_fallback 0
		balloon_inflate 0
		balloon_deflate 0
		balloon_migrate 0
		swap_ra 9661
		swap_ra_hit 7872
		EOF
	fi
}


function start_guest {
    local rootfs_path=$1

    chmod +x "$CURRENT_WORK_FOLDER"/bin/ubt_x32a32_al_mem2g "$CURRENT_WORK_FOLDER"/bin/ubt_x32a32_al_mem3g "$CURRENT_WORK_FOLDER"/bin/test-memory-available

    # Check the integrity of the guest system 
    if [ ! -d "$rootfs_path"/bin/ ]; then
      echo -e "Folder 'bin' in guest system not found. The guest system is likely damaged\n"
      exit
    fi

    case `cat "$rootfs_path"/etc/passwd` in
        xdroid:x:*:*::/home/xdroid/:/bin/sh)
            echo -e "ExaGear Windows/RPG/Strategy's rootfs system detected. Editing passwd for better compatibility\n"
            edit_passwd "$rootfs_path" ;;
        "")
            echo "'passwd' file in guest system not found. Exiting"
	        exit 1;;
    esac

    # unset LD_PRELOAD in case termux-exec is installed
    # We need this to disable the preloaded libtermux-exec.so library
    # which redefines 'execve()' implementation.
    unset LD_PRELOAD

    # /etc/resolv.conf and /etc/hosts may not be configured, so write in it our configuraton.
    echo -e "Writing resolv.conf file (NS 8.8.8.8/8.8.4.4)...\n"
    echo "127.0.0.1 localhost" > "$rootfs_path"/etc/hosts
    echo "nameserver 8.8.8.8" > "$rootfs_path"/etc/resolv.conf
    echo "nameserver 8.8.4.4" >> "$rootfs_path"/etc/resolv.conf

    # Check the storage and dev folders exists
    if [ ! -d "$rootfs_path"/storage/ ]; then
      echo -e "Folder 'storage' in guest system not found. Creating....\n"
      mkdir $rootfs_path/storage/
    fi
    if [ ! -d "$rootfs_path"/dev/ ]; then
      echo -e "Folder 'dev' in guest system not found. Creating....\n"
      mkdir $rootfs_path/dev/
    fi

    # This step is only needed for Ubuntu to prevent Group error
    touch "$rootfs_path"/root/.hushlogin

    setup_fake_proc "$rootfs_path"

    # Check memory configuration
    if ./bin/test-memory-available  0xa0000000 ; then
        MEMORY_BITS="3g"
    else
        MEMORY_BITS="2g"
    fi

    echo -e "System memory configuration is determined as ${MEMORY_BITS}\n"

    if [ "$MEMORY_BITS" = '3g' ]; then
        exagear_command="./bin/ubt_x32a32_al_mem3g"
    elif [ "$MEMORY_BITS" = '2g' ]; then
        exagear_command="./bin/ubt_x32a32_al_mem2g"
    fi

    exagear_command+=" --path-prefix "$rootfs_path""
    exagear_command+=" --vfs-hacks=tlsasws,tsi,spd"
    exagear_command+=" --vfs-kind guest-first"
    exagear_command+=" --vpaths-list "$CURRENT_WORK_FOLDER"/bin/vpaths-list"
    exagear_command+=" --tmp-dir "$rootfs_path"/tmp"
    exagear_command+=" -- /usr/bin/env -i
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
    LD_LIBRARY_PATH=/lib:/usr/lib:/usr/lib/i386-linux-gnu/:/var/lib:/var/lib/dpkg/:/lib/i386-linux-gnu:/usr/local/lib/"
    exagear_command+=" /bin/bash --login "

    proot_command=""$CURRENT_WORK_FOLDER"/bin/proot-static/proot_static"
    proot_command+=" -0"
    proot_command+=" -L"
    proot_command+=" --sysvipc"
    proot_command+=" --link2symlink"
    proot_command+=" --kill-on-exit"
    proot_command+=" --kernel-release=5.4.0-fake-kernel"
    proot_command+=" -b /sys:"$rootfs_path"/sys"
    proot_command+=" -b /proc:"$rootfs_path"/proc"
    proot_command+=" -b /dev:"$rootfs_path"/dev"
    proot_command+=" -b /storage:"$rootfs_path"/storage"
    proot_command+=" -b "$rootfs_path"/sys/fs/selinux/"
    proot_command+=" -b "$rootfs_path"/tmp:"$rootfs_path"/dev/shm"
    proot_command+=" -b /dev/urandom:/dev/random"
    proot_command+=" -b "$rootfs_path"/proc/.stat:"$rootfs_path"/proc/stat"
    proot_command+=" -b "$rootfs_path"/proc/.loadavg:"$rootfs_path"/proc/loadavg"
    proot_command+=" -b "$rootfs_path"/proc/.uptime:"$rootfs_path"/proc/uptime"
    proot_command+=" -b "$rootfs_path"/proc/.version:"$rootfs_path"/proc/version"
    proot_command+=" -b "$rootfs_path"/proc/.vmstat:"$rootfs_path"/proc/vmstat"

    echo -e "${GREEN}[Starting x86 environment]${NC}\n"
    $proot_command $exagear_command
    echo -e "\n${GREEN}[Exit from x86 environment]${NC}\n"
}


case "$1" in
        "") print_welcome_message; start_guest $DEFAULT_ROOTFS_FOLDER;;
		-h|--help|help|--usage|-dh) shift 1; print_usage_and_exit;;
		*)
			echo "Error: unknown command '$1'"
			exit 1
			;;
esac
