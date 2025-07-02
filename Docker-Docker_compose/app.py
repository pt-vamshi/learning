#!/usr/bin/env python3
"""
Simple Python Hello World Application
"""

from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello_world():
    return {
        'message': 'Hello, World!',
        'status': 'success',
        'container_id': os.environ.get('HOSTNAME', 'unknown')
    }

@app.route('/health')
def health_check():
    return {
        'status': 'healthy',
        'service': 'python-hello-world'
    }

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True) 