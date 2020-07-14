#!/bin/sh
trigger_url="https://hub.docker.com/api/build/v1/source/6c51ffb1-670a-4d83-9cd0-9c3abb233167/trigger/fc009bfe-2bb8-4f1e-888d-91a62703fe8f/call/"
curl -d "nmap" -X POST $trigger_url


