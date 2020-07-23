#!/bin/bash

# Log file
log="/home/docker/nmap/nmap_docker_image/log_nmap_docker_image.log"

# Setup SSH key management
# TODO: Add test for existing ssh-agent - nb. The file with the env vars 
# needs to be current with the running pid. So at some point we need 
# to run and capture the ssh-agent cmd and add the pvt key. 
# need to test if ssh-agent runs at start up etc 
# make this a function!

is_ssh_agent_running () {
    pid = "ps aux | grep -i ssh-agent | grep -iv defunct | grep -iv grep | cut -c 11-16" 
    pid_env = "cat /root/.ssh/agent/root | tail -n 1 | cut -c 15-20"
}

start_ssh_agent () {
    pkill ssh-agent
    sleep 2
    ssh-agent -s | grep -v echo > "/root/.ssh/agent/root"
    source /root/.ssh/agent/root
    ssh-add "/root/.ssh/blair_at_blairjames.com"
}

# Generate timestamp
timestamp () {
    date +"%Y%m%d_%H%M%S"
}

# Log and Print
logger () {
    printf "$1\n"
    printf "$(timestamp) - $1\n" >> $log
}

# Assign timestamp to ensure var is a static point in time.
timestp=$(timestamp)
logger "Starting Build.\n"

# Build the image using timestamp as tag.
if /usr/bin/docker build /home/docker/nmap/nmap_docker_image -t docker.io/blairy/nmap:$timestp >> $log; then
    logger "Build completed successfully.\n\n"
else
    logger "Build FAILED!! Aborting.\n\n"
    exit 1
fi

# Test - If test pass, commit and push to github and Dockerhub.
if /home/docker/nmap/nmap_docker_image/test_script_nmap.py docker.io/blairy/nmap:$timestp >> $log; then
    logger "Tests completed successfully.\n\n"
else
    logger "******  WARNING!!  --  Tests FAILED!!  Aborting. ******\n\n"
    exit 1
fi

# Push to github - Triggers builds in github and Dockerhub.
# TODO: Make this a function and add better exception management.. 
# only run this if the SSH function is successful.
git="/usr/bin/git -C /home/docker/nmap/nmap_docker_image/"
$git -C '/home/docker/nmap/nmap_docker_image/' pull git@github.com:blairjames/nmap_docker_image.git >> $log || logger "git pull failed!"
$git add --all >> $log || logger "git add failed!"
$git commit -a -m 'Automatic build $timestp' >> $log || logger "git commit failed!"
$git push >> $log || logger "git push failed!"

# Push the new tag to Dockerhub.
if docker push blairy/nmap:$timestp >> $log; then 
    logger "Docker push completed successfully.\n\n"
else
    logger "Docker push FAILED!!\n\n"
    exit 1 
fi

# All completed successfully
logger "All completed successfully"
