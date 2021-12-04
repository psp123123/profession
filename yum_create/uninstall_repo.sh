#!/bin/bash
base_dir=$(cd "$(dirname "$0")"; pwd)

echo '
即将清空目录/usr/loca/nginx  /usr/local/rpm'
systemctl stop nginx
inotify_pid=`ps -ef|grep inotify |grep -v grep |awk '{print $2}'`
kill -9 $inotify_pid
#sleep 5
repos_num=`ls /etc/yum.repos.d/|wc -l`
if [[ $repos_num == '1' ]]
  then
    rm -fr /etc/yum.repos.d
fi
mv /etc/yum.repos.d_old /etc/yum.repos.d
rm -fr /usr/local/nginx
rm -fr /usr/local/rpm 
rm -fr /usr/local/inotify
rm -f /usr/lib/systemd/system/nginx.service
#rm -f $base_dir/local_ip

