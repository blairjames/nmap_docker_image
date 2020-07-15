#!/bin/bash

timestamp() {
  date +"%Y-%m-%d_%H-%M-%S"
}

# Assign timestamp to ensure var is a static point in time.
timestp=$(timestamp)
echo "Timestamp: $timestp"

# Build the image using timestamp as tag.
docker build . -t blairy/nmap:$timestp || printf "\n\nBuild FAILED!!\n\n"

# Test - If test pass, commit and push to github and Dockerhub.
if ! ./test_script_nmap.py blairy/nmap:$timestp; then
    printf "\n\n******  WARNING!!  --  Tests FAILED!!  ******\n\n"
    exit 1
else
    # Push to github - Triggers builds in github and Dockerhub.
    git pull && \
    git add --all && \ 
    git commit -a -m "Automatic build $timestp" && \ 
    git push https://github.com/blairjames/nmap_docker_image || \
    printf "\n\ngit push FAILED!!\n\n"
fi
# Push the new tag to Dockerhub.
#docker push blairy/nmap:$timestp || printf "\n\ndocker push FAILED!!\n\n"
