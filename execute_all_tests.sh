#!/bin/bash
./clean.sh silent
BASE=$(pwd)
for D in `find -maxdepth 1 -path "./.git*" -prune -o -not -name "." -type "d" -print`
do
    echo $D
    cd $D
    ../execute_test.sh *.cu
    cd $BASE
    echo 
done
