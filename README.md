### Choose a language / Выберите язык: English / [Русскии](https://github.com/ZhymabekRoman/Exagear-For-Termux/blob/master/README-RU.md)

# Exagear For Termux
**Exagear For Termux** - modified version of Exagear, for Termux and Android devices. The main goal of the project is to achieve the possibility of a stable and fast replacement of QEMU user mode + proot, which is very slow and not stable.

## What is Exagear and what is it eaten with?
Exagear is a new virtualization technology that enables Intel x86 applications to run on ARM microprocessor-based devices. The project was developed by the Russian company Eltech, which was founded in 2012. Project development was stopped in 2019, but was again [resumed in 2020 under the Huawei brand](https://www.huaweicloud.com/kunpeng/software/exagear.html) and can already translating x86_64 application instructions into ARM64 instructions.

## Features
* Support for System V IPC and POSIX IPC
* High speed and stable translating instructions
* Quickly and easily deploy x86 systems

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
4) Now let's download and unpack for example rootfs of Debian 10 system to exagear-fs folder. It is in this folder that unpacked distribution images should be stored:
```
wget https://github.com/termux/proot-distro/releases/download/v1.1-debian-rootfs/debian-buster-i386-2020.12.05.tar.gz
mkdir exagear-fs/ && tar -C exagear-fs/ --warning=no-unknown-keyword --delay-directory-restore --preserve-permissions --strip=0 -xvf debian-buster-i386-2020.12.05.tar.gz --exclude='dev'||: && cd exagear-fs/ && mv debian-buster-i386-2020.12.05/* ./ && rm -rfv debian-buster-i386-2020.12.05/ && cd ../
```
5) Done. Let's start Exagear-For-Termux
```
./start-exagear.sh
```
