### Choose a language / Выберите язык: English / [Русскии](https://github.com/ZhymabekRoman/Exagear-For-Termux/blob/master/README-RU.md)

# Exagear For Termux
**Exagear For Termux** - modified version of Exagear, for Termux and Android devices. The main goal of the project is to achieve the possibility of a stable and fast replacement of QEMU user mode + proot, which is very slow and not stable.

## What is Exagear and what is it eaten with?
Exagear is a new virtualization technology that enables Intel x86 applications to run on ARM microprocessor-based devices. The project was developed by the Russian company Eltech, which was founded in 2012. Project development was stopped in 2019, but was again [resumed in 2020 under the Huawei brand](https://www.huaweicloud.com/kunpeng/software/exagear.html) and can already translating x86_64 application instructions into ARM64 instructions.

## Features
* Support for System V IPC and POSIX IPC
* High stable translating instructions
* Quickly and easily deploy x86 systems

## Issues
* Exagear For Termux is too slow.

Every process is hooked through ptrace(), so PRoot can hijack the system call arguments and return values. This is typically used to translate file paths so traced program will see the different file system layout. If you want to play games then please use Exagear Windows/RPG/Strategy

## Installation
### In Termux:
1) Install tar and git:
```
pkg update -y && pkg install tar git -y
```
2) Clone this repository to home directory:
```
git clone https://github.com/ZhymabekRoman/Exagear-For-Termux ~/ExaTermux
```
3) Now let's initializing the module proot-static:
```
cd ~/ExaTermux
git submodule init
git submodule update
```
4) Now you need to extract any rootfs archive of the distribution into the exagear-fs folder. For example, let's take and extract the Debian 11 archive that came with proot-distro:
```
mkdir exagear-fs/
wget https://github.com/termux/proot-distro/releases/download/v2.2.0/debian-i686-pd-v2.2.0.tar.xz
tar -C exagear-fs/ --warning=no-unknown-keyword --delay-directory-restore --preserve-permissions -xvf debian-i686-pd-v2.2.0.tar.xz --exclude='dev'||:
```
5) Done. Let's start Exagear-For-Termux
```
./start-exagear.sh
```
