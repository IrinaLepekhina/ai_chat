#!/bin/sh
set -e

# Run the setup script
./bin/setup

# Remove server PID file if it exists
if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

# Execute the command provided in the CMD instruction
exec "$@"
