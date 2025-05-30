#!/bin/bash

restart_worker() {
    while true; do
        if [ "$COMPONENT" = "worker" ]; then
            prefect config set PREFECT_API_URL='https://weasley-production.up.railway.app/api'
            prefect work-pool create 'default' --type process 2>/dev/null || true
            
            # Start worker in background
            prefect worker start -p 'default' &
            WORKER_PID=$!
            
            # Wait 24 hours (86400 seconds)
            sleep 86400
            
            # Kill the worker
            kill $WORKER_PID 2>/dev/null
            wait $WORKER_PID 2>/dev/null
            
            echo "Worker restarted at $(date)"
        fi
    done
}

# Your existing logic for server
if [ "$COMPONENT" = "server" ]; then
    prefect config set PREFECT_API_URL='https://weasley-production.up.railway.app/api'
    prefect server start --port $PORT --host 0.0.0.0
elif [ "$COMPONENT" = "worker" ]; then
    restart_worker
fi
