#!/bin/bash
BASE_DIR=/data/service/offlinetask
JAR_DIR=$BASE_DIR/jar
LOG_DIR=$BASE_DIR/logs
CHAT_JAR=chat-analysis.jar
[ -z $JAR_DIR ] && mkdir -p $JAR_DIR
[ -z $LOG_DIR ] && mkdir -p $LOG_DIR
[ -f $JAR_DIR/$CHAT_JAR ] || echo "请将$CHAT_JAR 保存至$JAR_DIR"
function usage() {
        echo $"usage:$0 { start | stop | restart | status }"
}
function start_srv {
        hadoop dfs -rm -r /data/spark/streaming/data-analysis-4.0/chat-analysis/checkpoint_dir/cp_1 > /dev/null 2>&1
        /data/service/spark/bin/spark-submit --class com.sobot.chat_analysis.run.RunJob $JAR_DIR/chat-analysis.jar &> $LOG_DIR/chat-analysis.log &
        attempt=0
        while true
          do
            count_pid=`ps -ef|grep chat-analysis.jar|grep -v grep|wc -l`
            if [[ $count_pid -ne 0 ]]
              then
                echo -n '.'
                ((attempt++))
                 if (( attempt > 6 ))
                   then
                     echo '启动成功'
                     exit 4
                 fi
              else
                echo '进程自动退出！！！请查看日志'
                exit 3
            fi
        done
}

function stop_srv() {
        chat_analysis_pid=`ps -ef|grep chat-analysis.jar|grep -v grep|awk '{print $2}'`
        if [[ $chat_analysis_pid -eq 0 ]]
          then
            echo '服务不存在！！！'
        else
            kill -9 $chat_analysis_pid  > /dev/null 2>&1
            echo '服务关闭成功'
        fi
}
function status_srv() {
        chat_analysis_pid=`ps -ef|grep chat-analysis.jar|grep -v grep|awk '{print $2}'`
        if [[ $chat_analysis_pid -ne 0 ]]
          then
            port_srv=`netstat -nltp|grep $chat_analysis_pid|awk '{print $4}'|awk -F : '{print $NF}'|xargs`
            echo "进程号：$chat_analysis_pid |端口号：$port_srv" 
        else
            echo '进程不存在'
            exit 1
        fi
 

}

case "$1" in
    start)
      start_srv
      ;;
    stop)
      stop_srv
      ;;
    status)
      status_srv
      ;;
    restart)
      stop_srv
      sleep 3
      start_srv
      ;;
    *)
      usage
      exit 2
esac
