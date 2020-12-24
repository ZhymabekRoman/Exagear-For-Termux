# Exagear For Termux
Exagear For Termux - модифицированная версия Exagear, для Termux и Android девайсов. Основной целью проекта является достижение возможности стабильной и быстрой замены QEMU user mode + proot, который очень медленный и не стабильный.

## Что такое Exagear и с чем его едят?
Exagear - это новая технология виртуализации, которая позволяет приложениям Intel x86 работать на устройствах на базе микропроцессоров ARM. Проект разработан российской компанией Eltech, которая была основана в 2012 году. Разработка проекта была остановлена в 2019 году, но вновь [возобновлена в 2020 году под брендом Huawei](https://www.huaweicloud.com/kunpeng/software/exagear.html) и уже может переводить x86_64 инструкции процессора в ARM64 инструкции.

## Функции
* Поддержка System V IPC и POSIX IPC
* Высокая сорность и стабильность транслирования инструкции команд процессора 
* Быстрое и простое развертывание систем x86

## Установка
### In Termux:
1) Устанвливаем tar, proot и git:
```
pkg update -y & & pkg install tar proot git -y
```
2) Клонируем этот репозитории в домашнию папку Termux:
```
git clone https://github.com/ZhymabekRoman/Exagear-For-Termux ~/ExaTermux
```
2) Давайте откроем каталог ExaTermux, загрузим и распакуем в папку exagear-fs, например, rootfs образ системы Debian 10. Именно в этой папке должны храниться распакованные образы дистрибутивов на основе ядра Linux:
```
cd ~/ExaTermux
wget https ://github.com/termux/proot-distro/releases/download/v1.1-debian-rootfs/debian-buster-i386-2020.12.05.tar.gz
tar -C exagear-fs/--warning = no-unknown-keyword --delay-directory-restore --preserve-permissions --strip = 0 -xvf debian-buster-i386-2020.12.05.tar.gz --exclude = 'dev' | |:
```
3) Готово. Давайте запустим наконец-то Exagear-For-Termux
```
./start-exagear.sh
```