#!/bin/bash

# Set up Camera config directory
mkdir -p $HOME/camera/config

# Run the container command
exec "$@"
