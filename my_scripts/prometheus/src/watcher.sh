#!/bin/bash

# Watch for changes to ovr.xml
while inotifywait -e modify ovr.xml; do
        echo "ovr.xml changed. Generating targets..."
    # Run the script to generate targets
        python generator.py
    # Restart Prometheus container
        docker-compose restart prometheus
done
