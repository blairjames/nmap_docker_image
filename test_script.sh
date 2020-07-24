#!/bin/bash

testfunc () {
    echo "test func run!" || return 1
}

if testfunc; then
    echo "if statement ran..."
else
    echo "if statement failed.."
fi

if [[ "ls /" -z ]]; then
    echo "bottom if statement"
fi
