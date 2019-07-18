#!/bin/bash
############################################################
#名字：	aliyun_swap.sh
#功能：	阿里云创建swap分区
#作者：	star
#邮件：	star@funet8.com
#时间：2019/07/18
#Version 1.0
#20190718修改记录：
# shell脚本初始化
###########################################################

#内存为32G以上则不考虑 
#内存在16G至32G之间，交换分区配置为8G
#内存在4G至16G之间，交换分区配置为4G 
#内存小于4G的则配置交换分区为2G 

size_block="8192"
#size_block="4096"
#size_block="2048"

#设置4G的swap大小
dd if=/dev/zero of=/mnt/swap bs=1M count=$size_block
#dd if=/dev/zero of=/mnt/swap bs=1M count=4096

#设置交换分区文件：
mkswap /mnt/swap

#启用交换分区文件
swapon /mnt/swap

#开机时自启用
echo '/mnt/swap swap swap defaults 0 0'>>/etc/fstab
mount -a

#配置为空闲内存少于 10% 时使用 SWAP 分区
echo 10 >/proc/sys/vm/swappiness

echo 'vm.swappiness=10' >> /etc/sysctl.conf

sysctl -p