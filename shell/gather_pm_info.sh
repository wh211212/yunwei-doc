#!/bin/bash
###################################################################
# Functions: gather physical machine information
# Info: be suitable for CentOS/RHEL 6/7 
# Changelog:
#      2017-12-23    hwang@aniu.tv     initial commit
###################################################################
# need dmidecode
#which dmidecode || yum -y install dmidecode

# system infomation

#System_name=`cat /etc/redhat-release`
#System_version=`awk '{print $(NF-1)}' /etc/redhat-release`
#System_kernel=`uname -a | awk '{print $3}'`
function osinfo() { 
    release=`cat /etc/redhat-release | awk '{print $1" "$3}'`
    kernalname=`uname -s`
    hostname=`uname -n`
    kernal=`uname -r`
    arch=`uname -i`
    Mac=`ifconfig | grep HWaddr | grep em1 | awk '{print $NF}'`
    #printf "OS_RELEASE: $release $arch\n"
    #printf "OS_DETAIL:$kname $hostname $kernal $arch\n"
    printf "HOSTNAME: $hostname\n"
    printf "OS_MAC: $Mac\n"
}
osinfo

# 服务器型号
#Server_model=`dmidecode | grep "Product Name" | head -1 | cut -d : -f2 | awk '{print $2}'`
#Server_Serial_number=`dmidecode | grep "Serial Number" | head -1 | awk '{print $3}'`
#Server_MAC=`ifconfig | grep HWaddr | grep em1 | awk '{print $NF}'`

#echo "服务器型号: $Server_model"
#echo "服务器序列号: $Server_Serial_number"
#echo "服务器MAC地址: $Server_MAC"

function serverinfo() { 
    vendor=`dmidecode -t 1 | grep "Manufacturer" | awk '{print $2}'`
    model=`dmidecode -t 1 | grep "Product" | awk '{print $4}'`
    sn=`dmidecode -t 1 | grep "Serial" | awk '{print $3}'`
    printf "MODEL: $vendor $model\n"
    printf "SN: $sn\n"
}
serverinfo

# CPU 型号
#Cpu_type=`grep "model name" /proc/cpuinfo | awk -F ': ' '{print $2}' | sort | uniq | awk '{print $4}'`
#Cpu_type=`grep "model name" /proc/cpuinfo | awk -F ': ' '{print $2}' | sort | uniq`
#Cpu_number=`grep "physical id" /proc/cpuinfo| sort | uniq | wc -l`

function cpuinfo() {
    cpu_model=`cat /proc/cpuinfo | grep "model name" | head -1 | awk -F: '{print $2}'`
    cpu_count=`cat /proc/cpuinfo | grep "core id" | grep "0" | uniq -c | awk '{print $1}'`
    cpu_total_cores=`cat /proc/cpuinfo | grep "processor" | wc -l`
    single_cores=`expr $cpu_total_cores / $cpu_count`
    printf "CPU:$cpu_model ($cpu_count"*"$single_cores"Cores")\n"
}
cpuinfo

#echo "CPU类型: $Cpu_type"
#echo "CPU数量: $Cpu_number"
# 硬盘


# 内存
#MemTotal=`dmidecode | grep -P -A5 "Memory\s+Device" | grep Size | grep MB | awk '{print $2}' | awk '{sum+=$1} END {print sum}'` # MB
#MemTotal_GB=`"$((MemTotal/1024))""GB"`
#MemNumber=`dmidecode | grep -P -A5 "Memory\s+Device" | grep MB | awk '{print $2}' | wc -l`
#MemSize=`dmidecode | grep -P -A5 "Memory\s+Device" | grep MB | awk '{print $2}' | uniq -c | awk '{print $2}'` # MB
#MemSize_GB=`expr $MemSize / 1024` #GB
#printf "服务器内存: $MemNumber"*"$MemSize_GB "GB"\n"

function meminfo() {
    count=`dmidecode -q -t 17 2 | grep "Size" | grep -v "No Module Installed" | awk '{print $2}' | uniq -c | awk '{print $1}'`
    size=`dmidecode -q -t 17 2 | grep "Size" | grep -v "No Module Installed" | awk '{print $2}'| uniq -c | awk '{print $2}'` # MB
    capacity=`expr $size / 1024` # GB
    printf "MEMORY: $count"*"$capacity "GB"\n"
}
meminfo

function diskinfo() {
    raidlevel=`/opt/MegaRAID/MegaCli/MegaCli64 -LDInfo -Lall -aALL | grep "RAID Level" | uniq | awk '{print $4}' | cut -b 9-9`
    disknumber=`/opt/MegaRAID/MegaCli/MegaCli64 -LDInfo -Lall -aALL | grep "Drives" | uniq | awk -F ":" '{print $2}'`
    disktype=`/opt/MegaRAID/MegaCli/MegaCli64 -PDList -aALL | grep "PD Type" | head -1 | awk -F: '{print $2}'`
    diskcapacity=`/opt/MegaRAID/MegaCli/MegaCli64 -PDList -aALL | grep "Raw Size" | head -1 | awk '{print $3}'`
    printf "DISK: $disknumber"*"$diskcapacity "GB"$disktype (Raid Level: $raidlevel)\n"
}
diskinfo
