#!/bin/bash

# Start Nginx in the background
service nginx start

# Start Flask application in the background
flask run --host=0.0.0.0 --port=8000 --reload &

# Wait for all background processes
wait 