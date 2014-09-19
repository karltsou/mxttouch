#!/bin/sh

# parsing multiple log files
for f in *.log
do
  echo "-- $f ---"
  python csv1.py "$f"
done 
