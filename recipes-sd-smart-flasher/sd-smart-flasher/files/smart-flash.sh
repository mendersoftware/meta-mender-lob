#!/bin/bash

# How this script works:
# * first we need to discover the smart plug we are using and switch the power off
# * once the device is off we need to discover sd-mux(es) 
# * having the sd-mux device we need to replace the content of the sd-card
# * once everything above is done we are plugging the tested board on 
# * we enjoy using the freshly flashed device

if test "$#" -le 2; then
  echo "smart SD card flasher

usage $0 <smart-plug-mac> <path-to-sd-image> [<sd-mux-serial>]

smart-plug-mac 	  - MAC address of the smart power switch
path-to-sd-image  - path to the image that the SD 
sd-mux-serial 	  - serial name of the sd-mux device 
" 

  exit 1
fi

PLUG_MAC_ADDR=$1
SD_IMAGE=$2
SD_MUX_SERIAL=$3

# do the network discovery and look for the smart plug
discover_smart_plug() {

  ## first calculate the network we need to scan
  networks=`ip -o -f inet addr show | awk '/scope global/ {print $4}'`

  for net in $networks; do
    ip=${net%/*}
    mask=${net#*/}
    IFS=. read -r i1 i2 i3 i4 <<< $ip
    IFS=. read -r xx m1 m2 m3 m4 <<< $(for a in $(seq 1 32); do if [ $(((a - 1) % 8)) -eq 0 ]; then echo -n .; fi; if [ $a -le $mask ]; then echo -n 1; else echo -n 0; fi; done)
    network=$(printf "%d.%d.%d.%d\n" "$((i1 & (2#$m1)))" "$((i2 & (2#$m2)))" "$((i3 & (2#$m3)))" "$((i4 & (2#$m4)))")

    # do only ARP ping scanning to make the things faster
    plug_discovery=`sudo nmap -n -sP -PR "$network/$mask" | awk '/Nmap scan report/{printf $5;printf " ";getline;getline;print $3;}' | grep $1`
    plug_ip=${plug_discovery% *}

    # check if we have a valid IP address
    if [[ $plug_ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      echo $plug_ip
      return 0
    fi
  done
  return 1
}

is_plug_working() {
  
  # check that we have what we need; now it is simple check but can add some more logic later
  local model=`tplink-smarthome-api getModel $1`
  if [[ $model =~ HS1[0-9]0 ]]; then 
    return 0
  fi
    return 1
}

# if we don't have sd-mux serial provided scan the connected devices 
# and pick up the first one
get_sd_mux() {
  local sd_mux=`sd-mux-ctrl -l | sed -n "s/^.*Serial: \([a-zA-Z]*-[0-9]*\),.*$/\1/p" | head -1`
  echo $sd_mux
}

get_sd_mux_status() {
  local status=`sd-mux-ctrl --device-serial=sdw-4 --status | sed -n "s/SD connected to: \([a-zA-Z]*$\)/\1/p"`
  echo $status
}

get_block_device() {

  # write the new image to the sd-card
  # can do the discovery using lsblk -l -p 
  # root@raspberrypi3:~# lsblk -p -l
  # NAME           MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
  # /dev/sda         8:0    1 14.9G  0 disk
  # /dev/sda1        8:1    1   16M  0 part
  # /dev/sda2        8:2    1  208M  0 part
  # /dev/sda3        8:3    1  208M  0 part
  # /dev/sda4        8:4    1  128M  0 part
  # /dev/mmcblk0   179:0    0  7.3G  0 disk
  # /dev/mmcblk0p1 179:1    0   40M  0 part /uboot
  # /dev/mmcblk0p2 179:2    0  212M  0 part /
  # /dev/mmcblk0p3 179:3    0  212M  0 part
  # /dev/mmcblk0p4 179:4    0  128M  0 part /data

  local devices=`lsblk -p -l | grep disk | grep -oh "/dev/sd[a-z]*" | awk '{print $1}' | head -1`
  echo $devices
}

echo "discovering smart plug ip ..."
plug_ip=$(discover_smart_plug $PLUG_MAC_ADDR)
printf "got smart plag ip: %s\n" "$plug_ip"

set -x

echo "check if plug is connected and working ..."
if ! is_plug_working $plug_ip; then 
  echo "error: smart plug is not working"
  exit 1
fi

if [ -z "$SD_MUX_SERIAL" ]; then
  SD_MUX_SERIAL=$(get_sd_mux)
fi
printf "got sd-mux serial: %s\n" "$SD_MUX_SERIAL"


# switch the smart plug off
tplink-smarthome-api send -D $plug_ip '{"system":{"set_relay_state":{"state":0}}}'

sleep 1

# connect the sd-mux device to the server
sd-mux-ctrl --device-serial=$SD_MUX_SERIAL -s

# wait until device will be initialized
sleep 10

block_device=$(get_block_device)

if [ -z $block_device ]; then
  print "block device not initialized; trying to reinitialize"
  sd-mux-ctrl --device-serial=$SD_MUX_SERIAL -d
  sleep 1
  sd-mux-ctrl --device-serial=$SD_MUX_SERIAL -s
  
  # wait until device will be initialized
  sleep 10
  block_device=$(get_block_device)

  if [ -z $block_device ]; then
    echo "block device not initialized; aborting"
    exit 1
  fi
else
  echo "sd-mux in the test server mode"
fi

# flash the sd-card
echo "flasing the sd-card ..."

if sudo dd if=$SD_IMAGE of=$block_device bs=1M; then
  echo "image copied to the SD card succesfully"
  sync
else 
  echo "failed to copy image to the SD card"
  exit 1
fi  

# connect the sd-mux device to the test device 
sd-mux-ctrl --device-serial=$SD_MUX_SERIAL -d

sleep 1

# switch the smart plug on
tplink-smarthome-api send -D $plug_ip '{"system":{"set_relay_state":{"state":1}}}'

