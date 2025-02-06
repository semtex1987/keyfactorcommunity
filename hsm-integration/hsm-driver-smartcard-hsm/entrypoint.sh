#!/bin/bash

# Start VirtualHere Client daemon
/usr/local/bin/start-vh-client

# Continue with your original container startup command
exec "$@"
