#########################################################################
# File Name: auth.sh
# Created Time: Mon 29 Mar 2021 12:42:59 PM CST
#########################################################################
#!/bin/bash


password=123456
#######
base_dir=$(cd "$(dirname "$0")"; pwd)

if [[ `rpm -qa |grep expect|wc -l` == "0" ]]
  then
    rpm -ivh $base_dir/rpm/tcl-8.5.13-8.el7.x86_64.rpm
    rpm -ivh $base_dir/rpm/expect-5.45-14.el7_1.x86_64.rpm
fi


echo '安装expect...done!'

if [ ! -f $base_dir/ip_list ]
  then
    echo '请准备ip_list名称的文件'
    exit 1
fi
if [ ! -f ~/.ssh/id_rsa ]
  then
    ssh-keygen -f ~/.ssh/id_rsa -q -N ''
  else
    echo '私钥已存在，未重新创建'
fi

expect_bin=`which expect`
for h in `cat ip_list`
  do
    $expect_bin <<EOF 
    spawn ssh-copy-id -i /root/.ssh/id_rsa.pub root@$h
    expect {
      "yes/no" {exp_send "yes\r";exp_continue}
      "*password" {exp_send "$password\r"}
    }
    expect eof
    
EOF

done
