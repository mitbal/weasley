#!/bin/bash

# Start Prefect server if COMPONENT is "server"
if [ "$COMPONENT" = "server" ]; then
    prefect server start --host 0.0.0.0 --port $PORT

# Start Prefect worker if COMPONENT is "worker"
elif [ "$COMPONENT" = "worker" ]; then
    prefect config set PREFECT_API_URL='http://weasley-production.up.railway.app/api'
    prefect worker start -p 'default'
fi