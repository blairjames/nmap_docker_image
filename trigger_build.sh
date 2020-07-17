#!/bin/bash

# Log file
log="/home/docker/nmap/nmap_docker_image/log_nmap_docker_image.log"
ssh-agent -s && ssh-add /root/.ssh/blair_at_blairjames.com >> $log

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
# if /home/docker/nmap/nmap_docker_image/test_script_nmap.py docker.io/blairy/nmap:$timestp >> $log; then
#     logger "Tests completed successfully.\n\n"
# else
#     logger "******  WARNING!!  --  Tests FAILED!!  Aborting. ******\n\n"
#     exit 1
# fi


# Push to github - Triggers builds in github and Dockerhub.
git="/usr/bin/git -C /home/docker/nmap/nmap_docker_image/"
git  -C '/home/docker/nmap/nmap_docker_image/' remote -v >> $log
ssh -T git@github.com:blairjames/nmap_docker_image.git
/usr/bin/git -C '/home/docker/nmap/nmap_docker_image/' pull git@github.com:blairjames/nmap_docker_image.git >> $log || logger "git pull failed!"
$git add --all >> $log || logger "git add failed!"
$git commit -a -m 'Automatic build $timestp' >> $log || logger "git commit failed!"
$git push >> $log || logger "git push failed!"


# # Push the new tag to Dockerhub.
# if docker push blairy/nmap:$timestp >> $log; then 
#     logger "Docker push completed successfully.\n\n"
# else
#     logger "Docker push FAILED!!\n\n"
#     exit 1 
# fi

# All completed successfully
#logger All completed successfully

