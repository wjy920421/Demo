#!/bin/sh

make

find . -name "*.demo"|while read fname; do
    ./demo $fname
done