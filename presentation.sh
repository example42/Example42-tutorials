#!/usr/bin/env bash
echo "Usage: $0 slide output"
echo "Available slides"
ls -1 slides/
echo

task=deck
slides=essential

slides=$1
task=$2

gradle -Pslides=$slides clean $task

open "build/$task/$slides/index.html"
