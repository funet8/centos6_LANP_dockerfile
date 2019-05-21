#!/bin/bash
#
#date :Wed May  3 15:51:34 CST 2017
#author: gaogd 
#
## 说明： ip为容器的ip，hostname为容器主机名，已经容器识别名称，hostname=itemname-servername-owner-ip
## 可以自己选择镜像，如果参数中木有指定镜像名称，那么就在脚本中展示出来，让用户选择，
## 如果用户也不选择，就是默认的sshd进行          
## 用法： sh createcontainter.sh  IP  HOSTNAME [imagesname]
## ./createcontainter.sh 172.18.0.34 gaogd-influxdb-influxdb04 influxdb:latest
## 目前只开放 172.18.0.1-172.18.0.254
 
 
function printInfo ()
{
    echo  "sh $0 IP  HOSTNAME [imagesname] "
    exit -1
}
 
function chooseimages ()
{
    echo -e "num \t\t REPOSITORY:TAG \t\t IMAGE ID \t\t"
    docker images |egrep -v REPOSITORY|cat -n|awk '{print $1"\t\t" $2":"$3  "\t\t"   $4}'
    read -p "Please input your choice(1|2|3 ...): " num
    image=`docker images |egrep -v REPOSITORY|cat -n |sed -n "${num}p"|awk '{print $2":"$3}'`
}
 
 
function createcontainter ()
{
    endnum=`echo $ip |awk -F'.' '{print $NF }'`
    echo -e "创建容器中.... \n"
    docker run -d -P -p 1${endnum}:4201 --net shadownet --ip $ip --name $hostname  --hostname $hostname $image
    echo docker run -d -P -p 1${endnum}:4201 --net shadownet --ip $ip --name $hostname  --hostname $hostname $image
    echo -e "创建完成 .... \n" 
    echo ip:    $ip , 
    echo hostname:    $hostname , 
    echo image:        $image
 
}
 
 
function IsIP()
{
    IP=$1
    echo test------IP:  $IP 
    if [ `echo $IP | awk -F . '{print NF}'` -ne 4 ];then
            echo "Wrong IP!"
            exit -1
    else
            a=`echo $IP | awk -F . '{print $1}'`
            b=`echo $IP | awk -F . '{print $2}'`
            c=`echo $IP | awk -F . '{print $3}'`
            d=`echo $IP | awk -F . '{print $4}'`
            #if [[ $a -gt 0 && $a -le 255 ]] && [[ $b -ge 0 && $b -le 255 ]] && [[ $c -ge 0 && $c -le 255 ]] && [[ $d -gt 0 && $d -lt 255 ]];then
            if [[ $a -eq 172 ]] && [[ $b -eq 18 ]] && [[ $c -eq 0 ]] && [[ $d -gt 0 && $d -lt 255 ]];then
                    echo "$IP Right IP!"
                    return 0
            else
                    echo "$IP Wrong IP!"
                    exit -1
            fi
    fi
     
}
 
function UsableIP()
{
    IP=$1
    echo test IP-----> $IP
    num=`ping  $IP  -c 3 |awk -F'[% ]+' '/received/{print $(NF-4)}'`
    echo test num-----> $num 
    if [ $num -gt 10 ]
    then
        echo "$IP Usable IP!"
        return 0
    else
        echo "$IP Not Usable IP!"
        exit -1
    fi
}
 
function UsableName()
{
    hostname=$1
    echo test hostname-----> $hostname
    for name in `docker ps -a |awk 'NR>1{print $NF}'`
    do
        if [ $name == $hostname ]
        then
            echo "$hostname Not Usable hostname!"
            exit -1
        fi
    done 
    echo "$hostname not same hostname!"
     
    if [ `echo $hostname|awk -F '-' '{print NF}'` -ne 3 ];then
            echo "but $hostname  format is error .! "
            echo "right hostname example : user-item-servicexx or gaogd-influxdb-influxdb01 "
            exit -1
    fi
    return 0
}
 
function Checkimage()
{
    image=$1
    echo test image-----> $image
    for name in `docker ps |awk 'NR>1{print $2}'`
    do
        if [ $name == $image ]
        then
            echo "$image  Usable image!"
            return 0
        fi
    done 
    echo "$image Not  Usable image!"
    exit -1
 
}
 
ip=$1
hostname=$2
 
if [ $# -lt 2 ]
then
    printInfo
fi
 
 
IsIP $ip  && UsableIP $ip  &&\
UsableName $hostname &&\
if [ $# -eq 3 ]
then
    image=$3
    Checkimage $image
else
    chooseimages
fi
 
createcontainter