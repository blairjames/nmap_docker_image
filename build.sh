#!/bin/bash

# Env Vars for SSH.
source /root/.ssh/agent/root || . /root/.ssh/agent/root

# Log file
declare -r log="/home/docker/nmap/nmap_docker_image/log_nmap_docker_image.log"

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
logger "Starting Build. Timestamp: $timestp\n"

# Build the image using timestamp as tag.
function build() {
cmd="/usr/bin/docker build /home/docker/nmap/nmap_docker_image -t docker.io/blairy/nmap:$timestp >> $log"
logger "Running Docker Build.. cmd: $cmd"
/usr/bin/docker build /home/docker/nmap/nmap_docker_image -t docker.io/blairy/nmap:$timestp >> $log || logger "Error! docker build failed"
}

# Push to github - Triggers builds in github and Dockerhub.
git () {
    git="/usr/bin/git -C /home/docker/nmap/nmap_docker_image/"
    $git -C '/home/docker/nmap/nmap_docker_image/' pull git@github.com:blairjames/nmap_docker_image.git >> $log || except "git pull failed!"
    $git add --all >> $log || except "git add failed!"
    $git commit -a -m 'Automatic build '$timestp >> $log || except "git commit failed!"
    $git push >> $log || except "git push failed!"
} 

# Push the new tag to Dockerhub.
function docker_push() {
if docker push blairy/nmap:$timestp >> $log; then 
    logger "Docker push completed successfully.\n\n"
else
    logger "Docker push FAILED!!\n\n"
    exit 1 
fi
}

# Prune the git tree in the local dir
function prune() {
logger "Running git gc --prune"
/usr/bin/git gc --prune || logger "Error!! - git gc failed!"
}


function main() {
build
git
docker_push
prune
logger "All complete."
}

main
