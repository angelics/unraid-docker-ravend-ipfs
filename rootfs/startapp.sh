#!/bin/sh
#!/usr/bin/with-contenv sh

set -u # Treat unset variables as an error.

trap "exit" TERM QUIT INT
trap "kill_rvn" EXIT

log() {
    echo "[rvnsupervisor] $*"
}

export HOME=/storage

getpid_rvn() {
    PID=UNSET
    if [ -f /storage/.raven/ravend.pid ]; then
        PID="$(cat /storage/.raven/ravend.pid)"
        # Make sure the saved PID is still running and is associated to
        # ravencoin.
        if [ ! -f /proc/$PID/cmdline ] || ! cat /proc/$PID/cmdline | grep -qw "ravend"; then
            PID=UNSET
        fi
    fi
    if [ "$PID" = "UNSET" ]; then
        PID="$(ps -o pid,args | grep -w "ravend" | grep -vw grep | tr -s ' ' | cut -d' ' -f2)"
    fi
    echo "${PID:-UNSET}"
}

is_rvn_running() {
    [ "$(getpid_rvn)" != "UNSET" ]
}

start_rvn() {
	exec ravend -sysperms -disablewallet
}

kill_rvn() {
    PID="$(getpid_rvn)"
    if [ "$PID" != "UNSET" ]; then
        log "Terminating ravend..."
		raven-cli -datadir=/storage/.raven stop
		wait $PID
	fi
}

if ! is_rvn_running; then
    log "ravend not started yet.  Proceeding..."
    start_rvn
fi

RVN_NOT_RUNNING=0
while [ "$RVN_NOT_RUNNING" -lt 5 ]
do
    if is_rvn_running; then
        RVN_NOT_RUNNING=0
    else
        RVN_NOT_RUNNING="$(expr $RVN_NOT_RUNNING + 1)"
    fi
    sleep 1
done

log "ravend no longer running.  Exiting..."