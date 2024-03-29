#########################################################################
# File Name: init.sh
# Created Time: Mon 30 Nov 2020 04:34:12 PM CST
#########################################################################
#!/bin/bash

function yum_install(){
        yum install -y net-tools vim lrzsz tree screen lsof tcpdump wget chrony telnet unzip ntpdate
}

function epel(){
        wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
        mv /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo.backup
        mv /etc/yum.repos.d/epel-testing.repo /etc/yum.repos.d/epel-testing.repo.backup
        wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
        yum makecache
}

function _locale(){
        cat >> /etc/environment << EOF
        LANG=en_US.utf-8
        LC_ALL=en_US.utf-8
EOF
        source /etc/environment
        echo 'LANG="en_US.utf-8"' > /etc/locale.conf
        source /etc/locale.conf
        locale
}

function offUseDns(){
        sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config 
}
function utc(){
        ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
}
 

function _ulimit(){
cat >> /etc/security/limits.conf<< EOF
* soft nofile 655350
* hard nofile 655350
EOF
ulimit -n 655350
}
function limit(){
        sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config 
        setenforce 0
        systemctl stop firewalld
        systemctl disable firewalld
}
function time_sync(){
        echo '*/5 * * * * root /usr/sbin/ntpdate time1.aliyun.com > /dev/null 2>&1' >> /etc/crontab
}
function ping_c(){
        ping -c 1 114.114.114.114 > /dev/null 2>&1
        if [ $? -ne 0 ]
          then
            echo -e "
\e[1;31m        Internet is unreachable!!!         \e[0m
"
            continue
        fi
}

#while true:
#  do
echo -e "\e[1;31m
>> 0: 自动优化（下面各项都会优化）\e[0m"
echo -e "\e[1;32m>> 1: 修改epel源为阿里云\e[0m"
echo -e "\e[1;32m>> 2: 添加必要的工具：net-tools vim lrzsz tree screen lsof tcpdump wget chrony telnet unzip ntpdate\e[0m"
echo -e "\e[1;32m>> 3: 修改字符集\e[0m"
echo -e "\e[1;32m>> 4: 修改时区\e[0m"
echo -e "\e[1;32m>> 5: 修改limit值\e[0m"
echo -e "\e[1;32m>> 6: 关闭linux的限制（Selinux/firewalld）\e[0m"
echo -e "\e[1;32m>> 7: 对阿里云服务器同步时间（time1.aliyum.com）\e[0m"
echo -e "\e[1;32m>> 8: 优化ssh连接慢（关闭UseDNS的反解析功能）\e[0m"
echo -e "\e[1;34m
>> t: 脚本测试项
\e[0m"
echo -e "\e[1;34m
>> q: 输入q退出脚本
\e[0m"

#read -p '请输入需要优化内容：' choice
while true
  do
    while read -p '请输入需要优化内容：' choice
      do
        expr $choice + 1 > /dev/null 2>&1
        if [ $? -eq 0 ] > /dev/null 2>&1
          then
            break
            #echo '输入正确'
        elif [ "$choice" == "t" ]
          then
            echo 脚本测试项
            break
        elif [ "$choice" == "q" ]
          then
            echo -e "\e[1;31m退出脚本 ^v^\e[0m"
            exit 1
        else
          echo "[ $choice ]字符输入错误,请重新输入"
        fi
    done
    
    case $choice in
      0)
        ping_c
        epel         > /dev/null 2>&1
        echo 'create epel done'
        yum_install  > /dev/null 2>&1
        echo 'yum install tools done'
        locale       > /dev/null 2>&1
        echo 'locale time done'
        utc          > /dev/null 2>&1
        echo 'utc done'
        _ulimit      > /dev/null 2>&1
        echo 'ulimit done'
        limit        > /dev/null 2>&1
        echo 'limit done'
        time_sync    > /dev/null 2>&1
        echo 'time sync done'
        offUseDns    > /dev/null 2>&1
        echo 'UseDNS is allready closed'
        echo 'done'
        ;;
      1)
        ping_c
        epel         > /dev/null 2>&1
        echo 'done'
        ;;
      2)
        ping_c
        yum_install  > /dev/null 2>&1
        echo done
        ;;
      3)
        _locale      > /dev/null 2>&1
        echo done
        ;;
      4)
        utc          > /dev/null 2>&1
        echo done
        ;;
      5)
        ulimit       > /dev/null 2>&1
        echo done
        ;;
      6)
        limit        > /dev/null 2>&1
        echo done
        ;;
      7)
        ping_c
        time_sync    > /dev/null 2>&1
        echo done
        ;;
     8)
       offUseDns > /dev/null 2>&1
       echo done
       ;;
      t)
        ping_c         
        echo done
        ;;

      q)
        exit
        ;;
    esac
done
