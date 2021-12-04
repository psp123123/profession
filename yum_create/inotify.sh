#!/bin/bash
#5.1 安装inotify
base_dir=$(cd "$(dirname "$0")"; pwd)
\cp -r $base_dir/inotify /usr/local

#5.2 配置服务
/usr/local/inotify/bin/inotifywait -mrq --format '%w%f' -e create,close_write,delete /usr/local/rpm| \
while read line
  do
    /usr/bin/createrepo --update /usr/local/rpm >/dev/null 2>&1
    /usr/bin/yum makecache >/dev/null 2>&1
done
