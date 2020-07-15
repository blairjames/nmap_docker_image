#!/bin/bash

timestamp() {
  date +"%Y-%m-%d_%H-%M-%S"
}

# Assign timestamp to ensure var is a static point in time.
timestp=$(timestamp)
echo "Timestamp: $timestp"

# Build the image using timestamp as tag.
docker build . -t blairy/nmap:$timestp

# Test - If test pass, commit and push to github and Dockerhub.
if ! ./test_script_nmap.py blairy/nmap:$timestp; then
    printf "\n\n******  WARNING!!  --  Tests FAILED!!  ******\n\n"
else
    # Push to github - Triggers builds in github and Dockerhub.
    git add Dockerfile 
    git commit -m "Automatic build $timestp"
    git push https://github.com/blairjames/nmap_docker_image

    # Push the new tag to Dockerhub.
    docker push blairy/nmap:$timestp
fi

