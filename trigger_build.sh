#!/bin/bash

timestamp() {
  date +"%Y-%m-%d_%H-%M-%S"
}

#docker build . -t blairy/nmap:$(timestamp)



git add --all  
git commit -m "Automatic build $(timestamp)"
git push "https://blairjames:5vBq!Z%47k\@github.com/blairjames/nmap_docker_image" --all

