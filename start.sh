#!/bin/bash

set -e

prefect config set PREFECT_API_URL="${PREFECT_API_URL}"

if [ "$COMPONENT" = "server" ]; then
    echo "Starting Prefect Server..."
    exec gunicorn "prefect.server.api.server:create_app()" \
        --workers 1 \
        --worker-class uvicorn.workers.UvicornWorker \
        --bind 0.0.0.0:$PORT \
        --max-requests 1000 \
        --max-requests-jitter 100

elif [ "$COMPONENT" = "worker" ]; then
    echo "Starting Prefect Worker..."

    until curl -sf "${PREFECT_API_URL}/health" > /dev/null; do
        echo "Server not ready yet, retrying in 5s..."
        sleep 5
    done
    echo "Server is ready."

    prefect work-pool create 'default' --type process 2>/dev/null || true

    while true; do
        echo "Launching worker at $(date)"

        # Run worker for max 6 hours OR kill if memory exceeds 400MB
        prefect worker start -p 'default' &
        WORKER_PID=$!

        # Monitor memory usage while worker is running
        while kill -0 $WORKER_PID 2>/dev/null; do
            # Get memory in KB, convert to MB
            MEM_KB=$(cat /proc/$WORKER_PID/status 2>/dev/null | grep VmRSS | awk '{print $2}')
            
            if [ -n "$MEM_KB" ]; then
                MEM_MB=$((MEM_KB / 1024))
                echo "Worker memory usage: ${MEM_MB}MB"

                # Kill if memory exceeds threshold (default 400MB)
                MAX_MEM_MB="${MAX_WORKER_MEMORY_MB:-400}"
                if [ "$MEM_MB" -gt "$MAX_MEM_MB" ]; then
                    echo "Memory limit exceeded (${MEM_MB}MB > ${MAX_MEM_MB}MB). Restarting worker..."
                    kill $WORKER_PID 2>/dev/null
                    break
                fi
            fi

            # Check every 60 seconds
            sleep 60
        done

        wait $WORKER_PID 2>/dev/null || true
        echo "Worker stopped. Restarting in 10s..."
        sleep 10
    done
fi
