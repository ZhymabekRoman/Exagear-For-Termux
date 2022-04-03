### Choose a language / Выберите язык: [English](https://github.com/ZhymabekRoman/Exagear-For-Termux/blob/master/README.md) / Русскии

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
1) Устанвливаем tar и git:
```
pkg update -y && pkg install tar git wget -y
```
2) Клонируем этот репозитории в домашнию папку Termux:
```
git clone https://github.com/ZhymabekRoman/Exagear-For-Termux ~/ExaTermux
```
3) Теперь давайте про инициализируем модуль proot-static:
```
cd ~/ExaTermux
git submodule init
git submodule update
```
4) Теперь вам нужно распаковать любой rootfs архив дистрибутива в папку exagear-fs. К примеру, давайте мы возьмем и распакуем архив Debian 11 поставляемый с proot-distro:
```
mkdir exagear-fs/
wget https://github.com/termux/proot-distro/releases/download/v2.2.0/debian-i686-pd-v2.2.0.tar.xz
tar -C exagear-fs/ --warning=no-unknown-keyword --delay-directory-restore --preserve-permissions -xvf debian-i686-pd-v2.2.0.tar.xz --exclude='dev'||:
```
5) Готово. Давайте запустим наконец-то Exagear-For-Termux
```
./start-exagear.sh
```
