#!/bin/bash

# Start Prefect server if COMPONENT is "server"
if [ "$COMPONENT" = "server" ]; then
    prefect config set PREFECT_API_URL='https://weasley-production.up.railway.app/api'
    prefect server start --port $PORT

# Start Prefect worker if COMPONENT is "worker"
elif [ "$COMPONENT" = "worker" ]; then
    prefect config set PREFECT_API_URL='https://weasley-production.up.railway.app/api'
    prefect work-pool create 'default' --type process
    prefect worker start -p 'default'
fi