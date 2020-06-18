#!/bin/bash -e
#
# Name:         jboss-ctl.sh
# Adapted to jboss7: Marco Ortega <marcoantonio.ortega@dxc.com>
# Description:  Control script for JBoss instance lifecycle administration. Do not edit directly.
#
# change log:
# 2016-09-29 Added support for standalone, standalone-full, standalone-ha and standalone-full-ha modes.

function printUsage(){
    echo "Usage: \$0 [start|stop|restart|threaddump|status]"
    exit 1
}

function do_log() {
    users=$(who -q | grep -v '#')
    if [[ $INIT_SCRIPT == 1 ]]; then
        users="init"
    fi
    if [[ -x /usr/bin/logger ]]; then
        /usr/bin/logger -t "jboss-${APP_NAME}" "$1: $users"
    fi
}

function get_java_pid() {
    local pid=`ps -fww -u $APP_USER | grep java | grep "jboss.node.name=$NODE_NAME " | head -1 | awk '{print $2}'`
    echo $pid
}

function get_standalone_pid() {
    local pid=`ps -fww -u $APP_USER | grep "standalone.sh " | grep "jboss.node.name=$NODE_NAME " | head -1 | awk '{print $2}'`
    echo $pid
}

function is_running() {
    local pid=`get_java_pid`
    if [[ -n $pid ]]; then
        return 0
    fi
    return 1
}

function is_listening() {
    count=0
    while [ $count -lt 30 ]; do
        sleep 2
        if lsof -P -n -i | grep ":$HTTP_PORT (LISTEN)" > /dev/null; then
            return 0
        fi
        let count=${count}+1
    done
    return 1
}

function do_threaddump() {
    local pid=`get_java_pid`
    if [[ -n $pid ]]; then
        kill -3 $pid
    fi
}

function do_kill_tree() {
    local pid=$1
    for child in $(ps -o pid --no-headers --ppid ${pid}); do
        do_kill_tree ${child}
    done
    kill -TERM ${pid}
}

function do_start(){
    if [[ $INIT_SCRIPT == 1 && $AUTO_RESTART == 0 ]]; then
        echo "Application is not configured to auto restart"
        return 0
    fi
    if is_running; then
        echo "Application is already running"
        return 0
    fi
    do_log "Starting"
    $APP_HOME/bin/standalone.sh \
                -Djboss.server.default.config=$STANDALONE_MODE \
        -Djboss.server.base.dir=$APP_BASE \
        $PORT_OFFSET \
        -Djboss.node.name=$NODE_NAME \
        -b=$JBOSS_BIND_ADDR \
        -bmanagement=$JBOSS_BIND_ADDR_MGMT \
        $MULTICAST_ADDRESS \
        >> $APP_BASE/log/console.log 2>&1 &
    if ! is_listening; then
        echo "Timed out waiting for http listening port"
        exit 1
    fi
}

function do_stop(){
    if is_running; then
        do_log "Stopping"
        do_threaddump
        standalone_pid=`get_standalone_pid`
        java_pid=`get_java_pid`
        if [[ -n $standalone_pid ]]; then
            # First preference
            do_kill_tree $standalone_pid
        else
            # Second preference
            do_kill_tree $java_pid
        fi
        # Final option, wait a bit before we do it though, ie:
        # Sleep for 1s then check, if still running sleep for 2s then check, if still running sleep for 10s then kill -9
        if sleep 2 && is_running && sleep 5 && is_running && sleep 10 && is_running; then
            kill -KILL $java_pid >/dev/null 2>&1
        fi
    fi
}


# Validate cmd line args
if [[ $# -ne 1 ]]; then
    printUsage
fi

# Check for jboss config file
if [[ -r $CONFIG_FILE ]]; then
    . $CONFIG_FILE
    echo "Using options from file $CONFIG_FILE"
else
    echo "Error: Unable to read $CONFIG_FILE config file. Are you sure it exists?"
    exit 1
fi

if [ -z "$JAVA_HOME" ]; then
  echo "No JAVA_HOME defined, default JAVA_HOME will be used instead"
else
  export JAVA_HOME
fi

if [ -z "$JAVA_OPTS" ]; then
    echo "Error: Proper JAVA_OPTS not defined in config file"
    exit 1
fi
export JAVA_OPTS

if [ -z "$JBOSS_PIDFILE" ]; then
    echo "Error: Proper JBOSS_PIDFILE not defined in config file"
    exit 1
fi
export JBOSS_PIDFILE

## Enable JBOSS to run in background
export LAUNCH_JBOSS_IN_BACKGROUND=true

# Check APP_HOME is defined
if [[ -z $APP_HOME ]]; then
    echo "Error: APP_HOME not defined"
    exit 1
fi

# Check APP_BASE is defined
if [[ -z $APP_BASE ]]; then
    echo "Error: APP_BASE not defined"
    exit 1
fi

# Check APP_NAME is defined
if [[ -z $APP_NAME ]]; then
    echo "Error: APP_NAME not defined"
    exit 1
fi

# Check APP_USER is defined
if [[ -z $APP_USER ]]; then
    echo "Error: APP_NAME not defined"
    exit 1
fi

# Set some globals
DIRNAME=`dirname "$0"`
APP_HOME=`cd "$DIRNAME/.."; pwd`

# Set the public bind address if not manually defined
if [[ -z $JBOSS_BIND_ADDR ]]; then
    HOST_NAME=`hostname`
    JBOSS_BIND_ADDR=`host $HOST_NAME 2>/dev/null | awk '{print $4}'`
    # Default to 0.0.0.0 (all interfaces) if unable to determine the public interface.
    # Only downside is that TCP unicast clustering wont work with 0.0.0.0 (it needs a public interface).
    # 127.0.0.1 is also not preferred as it can restrict external access.
    [[ $JBOSS_BIND_ADDR == "127.0.0.1" || ! $JBOSS_BIND_ADDR =~ ^[0-9]{1,3}\..* ]] && JBOSS_BIND_ADDR="0.0.0.0"
fi

# Set the mgmt bind address to that of the public unless manually specified
JBOSS_BIND_ADDR_MGMT=${JBOSS_BIND_ADDR_MGMT:-"$JBOSS_BIND_ADDR"}

# Set the port offset
HTTP_PORT=8080
if [[ -n $PORT_OFFSET ]]; then
    let HTTP_PORT=${HTTP_PORT}+$PORT_OFFSET
    PORT_OFFSET="-Djboss.socket.binding.port-offset=$PORT_OFFSET"
fi

# Set the multicast address, if defined
if [[ -n $MULTICAST_ADDRESS ]]; then
    MULTICAST_ADDRESS="-Djboss.default.multicast.address=$MULTICAST_ADDRESS"
fi

# Set th node name (needs to be unique for clusters)
NODE_NAME=$APP_NAME
SHORT_HOST_NAME=`hostname -s 2>/dev/null`
[[ -n $SHORT_HOST_NAME ]] && NODE_NAME="$APP_NAME-$SHORT_HOST_NAME"

case "$1" in
    start)
        do_start
    ;;
    stop)
        do_stop
    ;;
    restart)
        do_stop
        sleep 1
        do_start
    ;;
    threaddump)
        do_threaddump
    ;;
    status)
        if is_running; then
            java_pid=`get_java_pid`
            echo "Application (pid:$java_pid) is RUNNING"
        else
            echo "Application is DOWN"
        fi
    ;;
    *)
        printUsage
esac

exit 0
