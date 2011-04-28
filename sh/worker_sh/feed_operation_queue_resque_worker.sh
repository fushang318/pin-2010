#! /bin/sh

. /etc/rc.status

self_dir=`dirname $0`

. $self_dir/../function.sh

processor_pid=/web/2010/pids/feed_operation_queue_resque_worker.pid

log_path=/web/2010/logs/feed_operation_queue_resque_worker.log

cd $self_dir/../../sites/pin-user-auth

rails_env=$(get_rails_env)

if [ ! -f $log_path ]; then
  touch $log_path
fi

case "$1" in
  start)
    echo "start"
    assert_process_from_pid_file_not_exist $processor_pid
    VVERBOSE=1 INTERVAL=1 QUEUE=feed_operation_queue_worker rake environment resque:work 1>>$log_path 2>>$log_path &
    echo $! > $processor_pid
    rc_status -v
  ;;
  stop)
    echo "stop"
    kill -9 `cat $processor_pid`
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



