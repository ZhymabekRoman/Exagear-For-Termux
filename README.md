# Exagear For Termux


## CAUTON: WE HAVE SOME SERIOUS ISSUES! SEE in ISSUES section below



**Exagear For Termux** - Non official modified version of Exagear for Termux and proot based environemnts - Anlinux, AndroNix, UserLand and etc. The main goal of the project is to achieve the possibility of a stable and fast replacement of QEMU user mode with proot, which is very slow and not stable. No root access required.

## What is Exagear?
Exagear is a virtualization technology makes it possible to run Intel x86 applications on ARM-based devices. You can even run Windows applications on your ARM device if you install Wine. Eltechs solution is being developed since the project launch in 2012 and was discontinued in 2019, but was again [resumed in 2020 under the Huawei brand](https://www.huaweicloud.com/kunpeng/software/exagear.html) and can already run x86_64 applications on ARM64 devices.

## Features
* Quickly and easily deploy x86 Linux distros
* Support for System V IPC and POSIX IPC
* High stable translating instructions

## Issues
* Exagear For Termux is too slow, compared to Exagear Windows, but much faster than proot with QEMU

Every process is hooked through ptrace(), so PRoot can hijack the system call arguments and return values. This is typically used to translate file paths so traced program will see the different file system layout. If you want to play games then please use Exagear Windows/RPG/Strategy

* `FATAL: attempted to create non-posix thread; clone_flags == 00004111`

A critical error, which at the moment there is no explanation - because of what and how to solve it. If you have a solution, please join the discussion - [FATAL: attempted to create non-posix thread; clone_flags == 00004111](https://github.com/ZhymabekRoman/Exagear-For-Termux/issues/16)

## Installation
Recommended manual for beginners: [Run Windows exe on Android through Proot Exagear on Termux](https://ivonblog.com/en-us/posts/termux-proot-exagear-wine/)

1) Install `tar`, `wget` and `git` using Termux's package manager (`pkg`):
```bash
pkg update -y && pkg install tar git wget -y
```
or using `apt` if you have Debian based distro:
```bash
apt update && apt upgrade -y && apt install tar git wget -y
```
2) Clone this repository to home directory:
```bash
git clone https://github.com/ZhymabekRoman/Exagear-For-Termux ~/ExaTermux
```
3) Now let's initializing the module proot-static:
```bash
cd ~/ExaTermux
git submodule init
git submodule update
```
4) Now you need to extract any rootfs archive of the distribution into the `exagear-fs` folder. For example, let's take and extract the Debian 11 archive that came with proot-distro:
```bash
# Download Debian 12 from proot-distro's repo
wget "https://github.com/termux/proot-distro/releases/download/v4.6.0/debian-i686-pd-v4.6.0.tar.xz"
# Extract tar
tar --warning=no-unknown-keyword --delay-directory-restore --preserve-permissions -xvf debian-i686-pd-v4.6.0.tar.xz --exclude='dev'||:
# Rename extracted folder
mv debian-i686 exagear-fs
```
5) Done. Let's start Exagear-For-Termux
```bash
./start-exagear.sh
```
