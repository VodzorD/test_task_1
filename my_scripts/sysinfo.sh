#!/bin/bash

sys_info() {
    echo -e "-------------------------------System Information----------------------------"
    echo ""
    echo -e "Hostname:\t\t"`hostname`                                           # hostname
    echo -e "uptime:\t\t\t"`uptime | awk '{print $3,$4}' | sed 's/,//'`         # сколько система поднята, время на тачке, средняя загрузка на 1, 5, 15 мин
    echo -e "Manufacturer:\t\t"`cat /sys/class/dmi/id/chassis_vendor`           # поставщик оборудования или  
    echo -e "Product Name:\t\t"`cat /sys/class/dmi/id/product_name`             # наименование продукта или dmidecode -s system-product-name
    echo -e "Version:\t\t"`cat /sys/class/dmi/id/product_version`               # версия продукта
    echo -e "Serial Number:\t\t"`cat /sys/class/dmi/id/product_serial`          # сирийный номер

    # Более полная информация об аппаратном обеспечении компьютера может быть предоставлена командой dmidecode 

    #               echo ""
    #               echo ""
    #               dmidecode
    #               echo ""
    #               echo ""

    echo -e "Machine Type:\t\t"`vserver=$(lscpu | grep Hypervisor | wc -l); if [ $vserver -gt 0 ]; then echo "VM"; else echo "Physical"; fi`
                                                                                # тип машины


    # просмотр загруженных модулей ядра вместе с зависимостями - lsmod
    # просмотр лога ядра - dmesg

    echo -e "Processor Name:\t\t"`awk -F':' '/^model name/ {print $2}' /proc/cpuinfo | uniq | sed -e 's/^[ \t]*//'`
                                                                                # наименование процессора
    echo -e "Active User:\t\t"`w | cut -d ' ' -f1 | grep -v USER | xargs -n1`
                                                                                # активные пользователи


    #                       last reboot - история перезагрузки системы
    #                       last shutdown - история выключения системы
    #                       эту информацию можно посмотреть и по команде uptime

    echo ""
}

virtual_info() {
    echo -e "---------------------------Virtualisation information--------------------------"
    echo ""
    lscpu | grep -P 'Virtualization|Hypervisor vendor'
    echo ""
}


kernel_os_info() {
    echo -e "-----------------------------------Kernel & OS---------------------------------"
    echo ""
    echo -e "Operating System:\t"`hostnamectl | grep "Operating System" | cut -d ' ' -f5-`
                                                                                # операционная система
    # Полная информация об операционной системе (дистрибутиве): hostnamectl
    echo -e "Kernel:\t\t\t"`uname -r`                                           # версия ядра
    # Вся доступная информация о ядре: uname -a
    echo -e "Run level:\t\t"`runlevel`                                          # уровень загрузки системы

    #                       Всего в Systemd пять уровней запуска:
    #                       
    #                           - runlevel0.target, poweroff.target - выключение;
    #                           - runlevel1.target, rescue.target - однопользовательский текстовый режим;
    #                           - runlevel2.target, runlevel4.target - не используются;
    #                           - runlevel3.target, multi-user.target - многопользовательский текстовый режим;
    #                           - runlevel5.target, graphical.target - графический многопользовательский режим;
    #                           - runlevel6.target, reboot.target - перезагрузка.

    echo -e "Run level default:\t"`systemctl get-default`                      # уровень загрузки системы по умолчанию
    echo ""
    echo -e "Kernel boot settings:"                                             # параметры запуска ядра
    cat /proc/cmdline
    echo ""
}

motherboard_info() {
    echo -e "-----------------------------------Motherboard---------------------------------"
    echo ""
    echo -e "Motherboard information:"                                          # информация о материнской плате
    dmidecode -t 2
    echo ""                                                                     # информация о PCI устройствах, подключенных к материнской плате
    echo -e "PCI devices information:"
    lspci                                                                       # или lspci -vt - вывод в виде дерева
    echo ""
}

videocard_info() {
    echo -e "-----------------------------------Video card---------------------------------"
    echo ""
    echo -e "Video card information:"
    lspci | grep -i vga
    echo ""
}

network_info() {
    echo -e "-------------------------------Network Information-----------------------------"                                                                        
    echo ""
    echo -e "System Main IP:\t\t"`hostname -I`                                  # IP адресс машины   
    echo ""                            
    echo -e "Interfaces and IP addresses:"
    ip addr show | awk '/inet / {print "Interface:", $NF, "\tIP Address:", $2}' # интерфейсы и ip адреса
    echo ""
    echo -e "Routing table:"
    ip route                                                                    # таблица маршрутизации
    echo ""
    echo -e "DNS Cofiguration:"
    cat /etc/resolv.conf                                                        # кофигурация системы доменных имен
    echo ""
    echo -e "Network Connections and Listening Ports:"
    netstat -tuln                                                               # сетевые подключения и порты прослушивания
    echo ""
    echo -e "Firewall Rules:"
    iptables -L                                                                 # правила бредмауэра
    echo ""
    #               echo ""
    #               echo -e "Interfaces:\t\t"
    #               ls /sys/class/net
}

mem_usage() {
    echo -e "-----------------------------------Memory Usage------------------------------"
    echo ""
    echo -e "Memory Usage:\t"`free | awk '/Mem/{printf("%.2f%"), $3/$2*100}'`   # состояние оперативной памяти на данный момент
    echo -e "Swap Usage:\t"`free | awk '/Swap/{printf("%.2f%"), $3/$2*100}'`    # состояние swap памяти на данный момент или swapon -s

    # Более полную информацию можно узнать путем использования команды cat /proc/meminfo
    echo ""
}

cpu_info() {
    echo "-----------------------------------CPU Information------------------------------"
    echo ""
    #echo -e "CPU Usage:\t\t"`cat /proc/stat | awk '/cpu/{printf("%.2f%\n"), ($2+$4)*100/($2+$4+$5)}' |  awk '{print $0}' | head -1`
                                                                                # состояние процессора на данный момент
    echo -e "CPU Model:\t\t"`cat /proc/cpuinfo | grep "model name" | uniq | awk -F ':' '{print $2}'`
                                                                                # модель CPU
    echo -e "CPU Architecture:\t"`uname -m`                                     # архитектура процессора
    echo -e "Number of CPU Cores:\t"`grep -c '^processor' /proc/cpuinfo`        # количество ядер процессора
    echo -e "CPU Frequency:\t\t"`cat /proc/cpuinfo | grep "cpu MHz" | uniq | awk -F ':' '{print $2 " MHz"}'`
                                                                                # частота процессора
    echo -e "CPU Cache Size:\t\t"`cat /proc/cpuinfo | grep "cache size" | uniq | awk -F ':' '{print $2}'`
                                                                                # размер кеша процессора
    echo -e "CPU load average:\t"`uptime | awk -F'load average: ' '{print $2}'` # также можно узнать при помощи cat /proc/loadavg
    echo ""
    
    # Вся информация о процессоре может быть предоставлена при использовании команды cat /proc/cpuinfo или lscpu
}

disks_info() {
    echo -e "-------------------------------Disks Information-------------------------------"
    echo ""
    echo -e "Disks space:\t\t"
    df -Ph | sed s/%//g                                                         # состояние разделов памяти
    echo ""
    echo -e "List of block devices:\t"
    lsblk                                                                       # информация о блочных устройствах
    echo ""
    echo -e "Mount information:"                                                # Информация о премонтированных разделах
    mount | grep /dev/
    echo ""
    echo -e "SCSI device settings:"                                             # информация о настройках подключенных SCSI устройствах
    lsscsi
    echo ""
    echo -e "Disks speed:"
    hdparm -Tt /dev/vda /dev/vdb
    echo ""
}

sys_info
virtual_info
kernel_os_info
motherboard_info
videocard_info
network_info
mem_usage
cpu_info
disks_info

#           echo ""
#           echo -e "----------------------------Accesses & Users----------------------------"
#           echo ""
#           echo -e "Users information:"
#           echo ""
#           cat /etc/passwd
#           echo ""
#           echo ""
#           echo -e "Groups information:"
#           echo ""
#           cat /etc/group
#           echo ""
#           echo ""

#           echo -e "-------------------------------For WWN Details-------------------------------"
#           vserver=$(lscpu | grep Hypervisor | wc -l)
#           if [ $vserver -gt 0 ]
#           then
#           	echo "$(hostname) is a VM"
#           else
#           	cat /sys/class/fc_host/host?/port_name
#           fi                                                                          # скрипт показаывает, виртуальная ли это машина или нет 
#           echo ""