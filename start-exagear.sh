#!/bin/bash
##
## Script for managing Exagear'ed Linux distribution installations/running in Termux.
## by Zhymabek Roman
##
## Some pieces of code taken from proot-distro: https://github.com/termux/proot-distro

# Constants
PROGRAM_NAME="ExaGear for Termux"
PROGRAM_VERSION="3.1-stable"
CURRENT_WORK_FOLDER="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd
)"
DEFAULT_ROOTFS_FOLDER="exagear-fs"
DEFAULT_ROOTFS_FOLDER_PATH="${CURRENT_WORK_FOLDER}/${DEFAULT_ROOTFS_FOLDER}"

# Colors
PURPLE='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Enable bash strict mode
# TODO: seems to be it's not working!
set -euo pipefail

# Check whether it is running, in the root or normal environment.
if [ "$(id -u)" = "0" ] && [ "$(uname -o)" = "Android" ]; then
    echo
    echo -e "${RED}Error: '${PROGRAM_NAME}' should not be used as root. Exit...${NC}"
    echo
    exit 1
fi

arch=$(dpkg --print-architecture)
if ! [[ $arch == arm* ]] && ! [[ $arch = aarch64 ]]; then
    echo
    echo -e "${RED}Error: Exagear can only be started on systems with ARM processors. Exit...${NC}"
    echo
    exit 1
fi

function msg {
    local msg="${1}"
    echo -e "${msg}"
}

function print_welcome_message {
    msg "
    ░█░█░█▀█░█▀▄░█▀█
    ░░▀█░█▀▀░█░█░█▀█
    ░░░▀░▀░░░▀▀░░▀░▀
    "
    msg "${PROGRAM_NAME} by Zhymabek_Roman"
    msg "Version: ${PROGRAM_VERSION}, 2021-2023"
    msg ""
    msg "Copyright (c) 2013-2019 'Elbrus Technologies' LLC. All rights reserved."
    msg "This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE."
    msg ""
}

function print_usage_and_exit {
    echo 'Usage: ./start-exagear.sh'
    exit 0
}

function generate_proot_env_exec_cmd {
    local rootfs_path="${1}"
    local make_host_tmp_shared="${2}"
    local sysv_ipc="${3}"

    if [ "$MEMORY_BITS" = '3g' ]; then
        exagear_command="${CURRENT_WORK_FOLDER}/bin/exagear-binary-x86/ubt_x32a32_al_mem3g"
    elif [ "$MEMORY_BITS" = '2g' ]; then
        exagear_command="${CURRENT_WORK_FOLDER}/bin/exagear-binary-x86/ubt_x32a32_al_mem2g"
    fi

    exagear_command+=" --path-prefix ${rootfs_path}"
    exagear_command+=" --vfs-hacks=tlsasws,tsi,spd"
    exagear_command+=" --vfs-kind guest-first"
    exagear_command+=" --vpaths-list ${CURRENT_WORK_FOLDER}/bin/vpaths-list"
    exagear_command+=" --tmp-dir ${rootfs_path}/tmp"
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

    exec_cmd="${exagear_command}"
}

function generate_termux_env_exec_cmd {
    local rootfs_path="${1}"
    local make_host_tmp_shared="${2}"
    local sysv_ipc="${3}"

    if [ "$MEMORY_BITS" = '3g' ]; then
        exagear_command="/bin/exagear-binary-x86/ubt_x32a32_al_mem3g"
    elif [ "$MEMORY_BITS" = '2g' ]; then
        exagear_command="/bin/exagear-binary-x86/ubt_x32a32_al_mem2g"
    fi

    exagear_command+=" --path-prefix ${DEFAULT_ROOTFS_FOLDER}"
    exagear_command+=" --vfs-hacks=tlsasws,tsi,spd"
    exagear_command+=" --vfs-kind guest-first"
    exagear_command+=" --vpaths-list /bin/vpaths-list"
    exagear_command+=" --tmp-dir ${DEFAULT_ROOTFS_FOLDER}/tmp"
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

    proot_command="${CURRENT_WORK_FOLDER}/bin/proot-static/proot_static"
    proot_command+=" -0"
    proot_command+=" --link2symlink"
    proot_command+=" -r ${CURRENT_WORK_FOLDER}/"
    proot_command+=" -L"
    if [ "${sysv_ipc}" = true ]; then
        proot_command+=" --sysvipc"
    fi
    proot_command+=" --kill-on-exit"
    proot_command+=" --kernel-release=5.4.0-fake-kernel"
    proot_command+=" -b /sys"
    proot_command+=" -b /proc"
    proot_command+=" -b /dev"
    proot_command+=" -b /storage"
    proot_command+=" -b ${rootfs_path}:/exagear-fs/"
    proot_command+=" -b ${rootfs_path}/sys/fs/selinux/:/sys/fs/selinux"
    proot_command+=" -b ${rootfs_path}/tmp/:/dev/shm/"
    proot_command+=" -b /dev/urandom:/dev/random"
    proot_command+=" -w /"
    proot_command+=" -b ${CURRENT_WORK_FOLDER}/bin/other/stat:/proc/stat"
    proot_command+=" -b ${CURRENT_WORK_FOLDER}/bin/other/loadavg:/proc/loadavg"
    proot_command+=" -b ${CURRENT_WORK_FOLDER}/bin/other/uptime:/proc/uptime"
    proot_command+=" -b ${CURRENT_WORK_FOLDER}/bin/other/proc_version:/proc/version"
    proot_command+=" -b ${CURRENT_WORK_FOLDER}/bin/other/vmstat:/proc/vmstat"

    if ${make_host_tmp_shared}; then
        proot_command+=" -b ${PREFIX}/tmp/:/tmp/"
    fi

    exec_cmd="${proot_command} ${exagear_command}"
}

function generate_termux_old_env_exec_cmd {
    local rootfs_path="${1}"
    local make_host_tmp_shared="${2}"
    local sysv_ipc="${3}"

    if [ "$MEMORY_BITS" = '3g' ]; then
        exagear_command="${CURRENT_WORK_FOLDER}/bin/exagear-binary-x86/ubt_x32a32_al_mem3g"
    elif [ "$MEMORY_BITS" = '2g' ]; then
        exagear_command="${CURRENT_WORK_FOLDER}/bin/exagear-binary-x86/ubt_x32a32_al_mem2g"
    fi

    exagear_command+=" --path-prefix ${rootfs_path}"
    exagear_command+=" --vfs-hacks=tlsasws,tsi,spd"
    exagear_command+=" --vfs-kind guest-first"
    exagear_command+=" --vpaths-list ${CURRENT_WORK_FOLDER}/bin/vpaths-list-old"
    exagear_command+=" --tmp-dir ${rootfs_path}/tmp"
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

    proot_command="${CURRENT_WORK_FOLDER}/bin/proot-static/proot_static"
    proot_command+=" -0"
    proot_command+=" --link2symlink"
    proot_command+=" -L"
    if [ "${sysv_ipc}" = true ]; then
        proot_command+=" --sysvipc"
    fi
    proot_command+=" --kernel-release=5.4.0-fake-kernel"
    proot_command+=" -b /sys:${rootfs_path}/sys"
    proot_command+=" -b /proc:${rootfs_path}/proc"
    proot_command+=" -b /dev:${rootfs_path}/dev"
    proot_command+=" -b /storage:${rootfs_path}/storage"
    proot_command+=" -b ${rootfs_path}/sys/fs/selinux/"
    proot_command+=" -b ${rootfs_path}/tmp:${rootfs_path}/dev/shm"
    proot_command+=" -b /dev/urandom:/dev/random"
    proot_command+=" -b ${CURRENT_WORK_FOLDER}/bin/other/stat:${rootfs_path}/proc/stat"
    proot_command+=" -b ${CURRENT_WORK_FOLDER}/bin/other/loadavg:${rootfs_path}/proc/loadavg"
    proot_command+=" -b ${CURRENT_WORK_FOLDER}/bin/other/uptime:${rootfs_path}/proc/uptime"
    proot_command+=" -b ${CURRENT_WORK_FOLDER}/bin/other/proc_version:${rootfs_path}/proc/version"
    proot_command+=" -b ${CURRENT_WORK_FOLDER}/bin/other/vmstat:${rootfs_path}/proc/vmstat"

    if ${make_host_tmp_shared}; then
        proot_command+=" -b ${PREFIX}/tmp/:${rootfs_path}/tmp/"
    fi

    exec_cmd="${proot_command} ${exagear_command}"
}

function edit_passwd {
    local rootfs_path="${1}"
    cp "${CURRENT_WORK_FOLDER}/bin/other/passwd" "${rootfs_path}/etc/"
}

function setup_fake_proc {
    local rootfs_path="${1}"

    mkdir -p "${rootfs_path}/proc"
    chmod 700 "${rootfs_path}/proc"

    # Setup selinux rule
    mkdir -p "${rootfs_path}/sys/fs/selinux/"
    cp -n "${CURRENT_WORK_FOLDER}/bin/other/selinux_enforce" "${rootfs_path}/sys/fs/selinux/enforce"
}

function start_guest {
    local rootfs_path="${DEFAULT_ROOTFS_FOLDER_PATH}"

    local make_host_tmp_shared=false
    local old_termux_exec_cmd=false
    local force_no_proot=false
    local sysv_ipc=true

    local exec_cmd

    while (($# >= 1)); do
        case "$1" in
        --)
            shift 1
            break
            ;;
        --path)
            if [[ $# -gt 1 && $2 != -* ]]; then
                rootfs_path="${2}"
                shift 1
            else
                echo "--path argument requires an path" 1>&2
                exit 1
            fi
            ;;
        --shared-tmp)
            make_host_tmp_shared=true
            ;;
        --old)
            old_termux_exec_cmd=true
            ;;
        --no-sysv-ipc)
            sysv_ipc=false
            ;;
        --force-no-proot)
            force_no_proot=true
            ;;
        *)
            msg "${RED}Error: unknown parameter: '$1'${NC}"
            exit 1
            ;;
        esac
        shift 1
    done

    if [ ! -d "${CURRENT_WORK_FOLDER}/bin/proot-static/" ] || [ -z "$(ls -A "${CURRENT_WORK_FOLDER}"/bin/proot-static)" ]; then
        echo "Git submodule 'proot-static' not found! Run these commands:"
        echo "git submodule init"
        echo "git submodule update"
        exit 1
    fi

    if [ ! -d "${CURRENT_WORK_FOLDER}/bin/exagear-binary-x86/" ] || [ -z "$(ls -A "${CURRENT_WORK_FOLDER}"/bin/exagear-binary-x86)" ]; then
        echo "Git submodule 'exagear-binary-x86' not found! Run these commands:"
        echo "git submodule init"
        echo "git submodule update"
        exit 1
    fi

    # Check memory configuration
    if "${CURRENT_WORK_FOLDER}/bin/exagear-binary-x86/test-memory-available" 0xa0000000; then
        MEMORY_BITS="3g"
    else
        MEMORY_BITS="2g"
    fi

    msg "System memory configuration is determined as ${MEMORY_BITS}"

    if [ ! -d "${rootfs_path}" ] || [ -z "$(ls -A "${rootfs_path}")" ]; then
        msg "Guest rootfs '$(basename "${rootfs_path}")' folder not found or empty. Exit..."
        exit 1
    fi

    # Check the integrity of the guest system
    if [ ! -d "${rootfs_path}/bin/" ]; then
        msg "Folder 'bin' in guest system not found. The guest system is likely damaged. Exit..."
        exit 1
    fi

    case $(cat "${rootfs_path}/etc/passwd") in
    xdroid:x:*:*::/home/xdroid/:/bin/sh)
        msg "ExaGear Windows/RPG/Strategy's rootfs image detected. Editing 'passwd' for better compatibility"
        edit_passwd "${rootfs_path}"
        ;;
    "")
        msg "'passwd' file in guest system not found. Ignoring..."
        ;;
    esac

    # unset LD_PRELOAD in case termux-exec is installed
    # We need this to disable the preloaded libtermux-exec.so library
    # which redefines 'execve()' implementation.
    unset LD_PRELOAD

    # /etc/resolv.conf and /etc/hosts may not be configured, so write in it our configuraton.
    msg "Writing resolv.conf file (NS 8.8.8.8/8.8.4.4)..."
    echo "127.0.0.1 localhost" >"$rootfs_path"/etc/hosts
    echo "nameserver 8.8.8.8" >"$rootfs_path"/etc/resolv.conf
    echo "nameserver 8.8.4.4" >>"$rootfs_path"/etc/resolv.conf

    # Check the storage and dev folders exists
    if [ ! -d "${rootfs_path}/storage/" ]; then
        echo -e "Folder 'storage' in guest system not found. Creating....\n"
        mkdir "${rootfs_path}/storage/"
    fi
    if [ ! -d "${rootfs_path}/dev/" ]; then
        echo -e "Folder 'dev' in guest system not found. Creating....\n"
        mkdir "${rootfs_path}/dev/"
    fi
    if [ ! -d "${rootfs_path}/proc/" ]; then
        echo -e "Folder 'proc' in guest system not found. Creating....\n"
        mkdir "${rootfs_path}/proc/"
    fi
    if [ ! -d "${rootfs_path}/sys/" ]; then
        echo -e "Folder 'sys' in guest system not found. Creating....\n"
        mkdir "${rootfs_path}/sys/"
    fi

    # This step is only needed for Ubuntu to prevent Group error
    touch "${rootfs_path}/root/.hushlogin"

    setup_fake_proc "${rootfs_path}"

    if [ "$(uname -o)" != "Android" ] || ${force_no_proot}; then
        echo -e "Your environment is defined as proot (or forced)\n"
        generate_proot_env_exec_cmd "${rootfs_path}" "${make_host_tmp_shared}" "${sysv_ipc}"
    else
        if ${old_termux_exec_cmd}; then
            echo -e "Your environment is defined as Termux (executed with --old flag)\n"
            generate_termux_old_env_exec_cmd "${rootfs_path}" "${make_host_tmp_shared}" "${sysv_ipc}"
        else
            echo -e "Your environment is defined as Termux\n"
            generate_termux_env_exec_cmd "${rootfs_path}" "${make_host_tmp_shared}" "${sysv_ipc}"
        fi
    fi

    echo -e "${GREEN}[Starting x86 environment]${NC}\n"

    if ${exec_cmd}; then
        msg "${GREEN}[Exit from x86 environment with status 0]${NC}"
    else
        msg "${RED}[Exit from x86 environment with error status]${NC}"
    fi

}

ARG_ACTION="${1:-}"
ARG_PARAMS="${@:2}"

case "${ARG_ACTION}" in
"login")
    print_welcome_message
    start_guest $ARG_PARAMS
    ;;
"")
    msg "${RED}WARNING: starting the utility start-exagear.sh without parameters is DEPRECATED! Running without parameters is removed in version 3.0."
    msg ""
    msg "New comand line syntax: start-exagear.sh login <PARAMETERS>${NC}"
    ;;
-h | --help | help | --usage | -dh)
    shift 1
    print_welcome_message
    print_usage_and_exit
    ;;
*)
    echo "Error: unknown command '${ARG_ACTION}'"
    exit 1
    ;;
esac
