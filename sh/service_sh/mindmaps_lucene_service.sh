#! /bin/sh

root_dir=`dirname $0`

processor_pid=/web/2010/pids/mindmaps_lucene_service.pid

log_file=/web/2010/logs/mindmaps_lucene_service.log

. /etc/rc.status
. $root_dir/../function.sh

rails_env=$(get_rails_env)

case "$1" in
        start)
                assert_process_from_pid_file_not_exist $processor_pid
                echo "mindmaps_lucene_service start"
                cd $root_dir/../../java/lucene-service/dist
                java -jar lucene-service.jar mindmaps $rails_env -Xms32M -Xmx256M 1>> $log_file 2>> $log_file & 
                echo $! > $processor_pid
                rc_status -v
        ;;
        stop)
                echo "mindmaps_lucene_service stop"
                kill `cat $processor_pid`
                rc_status -v
        ;;
        restart)
                $0 stop
                sleep 1
                $0 start
        ;;
        *)
                echo "tip:(start|stop|restart)"
                exit 5
        ;;
esac
exit 0


