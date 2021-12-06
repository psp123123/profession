#!/bin/bash
base_dir=$(cd "$(dirname "$0")"; pwd)

#1. 获取网卡IP和其他基本信息
#if [ ! -n "cat $base_dir/local_ip" ]
#  then
#    HOST_IP=`cat $base_dir/local_ip`
#  else
#    read -p '请输入本机网卡名：' name
#    HOST_IP=`ifconfig $name|awk 'NR==2{print $2}'`
#    echo "$HOST_IP" > $base_dir/local_ip
#fi
    
read -p '请输入本机网卡名：' name
HOST_IP=`ifconfig $name|awk 'NR==2{print $2}'`
echo "
设置的网络为：$HOST_IP 所在子网
"
#2. 安装createrepo服务
if [[ `rpm -qa |grep createrepo|wc -l` == "0" ]]
  then
    rpm -ivh $base_dir/rpm/python-deltarpm-3.6-3.el7.x86_64.rpm
    rpm -ivh $base_dir/rpm/deltarpm-3.6-3.el7.x86_64.rpm
    rpm -ivh $base_dir/rpm/createrepo-0.9.9-28.el7.noarch.rpm
fi


#3. 安装nginx,版本为：nginx_1_20
if [[ `rpm -qa |grep nginx |wc -l ` == "0" && `ps -ef|grep nginx|wc -l` == "0" ]]
  then
    cp -r /etc/yum.repos.d /mnt/
    echo "$HOST_IP" >$base_dir/local_ip
    \cp -r $base_dir/nginx /usr/local
    \cp -r $base_dir/rpm /usr/local
    #如果yum.repos.d目录发生误操作被删除，可查看/mnt下是否存在
  else
    read -p 'nginx已存在本机，请确认不会冲突,退出请按q，如继续安装，请按任意键：' choice
    if [[ $choice == "q" ]]
      then
        echo 'exit script'
        exit 1
      
    fi
    \cp -r $base_dir/nginx /usr/local
    \cp -r $base_dir/rpm /usr/local
fi
#4. rpm包建立索引,及源配置
createrepo -pdo $base_dir/rpm $base_dir/rpm > /dev/null 2>&1

mv /etc/yum.repos.d{,_old}
mkdir /etc/yum.repos.d
echo "[epel]
name=local epel
baseurl=http://$HOST_IP:9388/epel
enabled=1
gpgcheck=0" > /etc/yum.repos.d/local.repo

yum makecache fast > /dev/null 2>&1


#5. config nginx file


cat > /usr/lib/systemd/system/nginx.service << EOF
[Unit]
Description=The nginx HTTP and reverse proxy server
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
#PIDFile=/run/nginx.pid
# Nginx will fail to start if /run/nginx.pid already exists but has the wrong
# SELinux context. This might happen when running nginx -t from the cmdline.
# https://bugzilla.redhat.com/show_bug.cgi?id=1268621
ExecStartPre=/usr/bin/rm -f /usr/loca/nginx/logs/nginx.pid
ExecStartPre=/usr/local/nginx/sbin/nginx -t
ExecStart=/usr/local/nginx/sbin/nginx
ExecReload=/usr/local/nginx/sbin/nginx -s reload
KillSignal=SIGQUIT
TimeoutStopSec=5
KillMode=process
PrivateTmp=true

[Install]
WantedBy=multi-user.target

EOF

#4. start nginx service
systemctl daemon-reload
systemctl restart nginx

##5.1 安装inotify
#mv $base_dir/inotify /usr/local
#
##5.2 配置服务
#/usr/local/inotify/bin/inotifywait -mrq --format '%w%f' -e create,close_write,delete /usr/local/rpm| \
#while read line
#  do
#    creterepo --update /usr/local/rpm
#done

/bin/bash $base_dir/inotify.sh & >/dev/null 2>&1

#5. 使用注释
echo '

恭喜安装内网yum源完成!!!
==============================================================================================

1. 其他机器客户端配置需执行一下命令：
mv /etc/yum.repos.d{,_old}
cat > /etc/yum.repos.d/local.repo << EOF
[epel]
name=local epel
baseurl=http://$HOST_IP:9388/epel
enabled=1
gpgcheck=0
EOF

yum makecache

2. nginx服务管理方式为systemctl

3. 如果需要卸载本地yum源，可执行卸载脚本uninstall_repo.sh

==============================================================================================
'
