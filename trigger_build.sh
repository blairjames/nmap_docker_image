#!/bin/bash

timestamp() {
  date +"%Y-%m-%d_%H-%M-%S"
}

docker build . -t blairy/nmap:$(timestamp)

git add Dockerfile 
git commit -m "Automatic build $(timestamp)"
git push https://github.com/blairjames/nmap_docker_image

