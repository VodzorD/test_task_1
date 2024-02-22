#!/bin/bash

#   Предлагаем решить вам задачу при помощи bash скрипта:

#   Нужно сделать скрипт который выберет диск из имеющихся в системе наименьшего объема но не менее 20 гигабайт,
#   после чего создать разделы размером 512mb и на все оставшееся место, первый раздел отформатировать в ext4,
#   на втором создать lvm с root и swap волумами


disks=$(lsblk -b -d -o NAME,SIZE | grep -E '^sd[a-z]' | awk '{print $1,$2}')

min_size=0
min_disk=""

while read -r disk; do
    disk_name=$(echo "$disk" | awk '{print $1}')
    disk_size=$(echo "$disk" | awk '{print $2}')
    disk_size_gb=$((disk_size / 1024 / 1024 / 1024))
    if [[ $disk_size_gb -ge 20 ]]; then
        if [[ $min_size -eq 0 || $disk_size_gb -lt $min_size ]]; then
            min_size=$disk_size_gb
            min_disk=$disk_name
        fi
    fi
done <<< "$disks"

if [[ -n $min_disk ]]; then
    echo "Configuring disk $min_disk..."
    parted -s /dev/$min_disk mklabel gpt

    parted -s /dev/$min_disk mkpart primary ext4 1MiB 513MiB
    mkfs.ext4 /dev/${min_disk}1
    mount /dev/${min_disk}1 /mnt/boot

    parted -s /dev/$min_disk mkpart primary 513MiB 100%
    pvcreate /dev/${min_disk}2
    vgcreate my_vg /dev/${min_disk}2

    lvcreate -L 1G -n swap my_vg
    lvcreate -l 100%FREE -n root my_vg

    mkswap /dev/my_vg/swap
    mkfs.ext4 /dev/my_vg/root

    mount /dev/my_vg/root /mnt

    echo "Disk $min_disk configured successfully."
else
    echo "No disk found with size more than 20GB."
fi