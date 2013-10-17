#!/usr/bin/env bash
echo "Usage: $0 slide output"
echo "Available slides"
ls -1 slides/
echo

JBOSS_HOME=${JBOSS_HOME:-"<%= scope.lookupvar('jboss::real_jboss_dir') %>"}

task=${1:-"deck"}
slides=${2:-"essentials"}

gradle -Pslides=$slides clean $task

open "build/$task/$slides/index.html"
