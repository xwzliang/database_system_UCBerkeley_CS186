#!/bin/bash

echo "Running" $0 "on" $1

# Make the locale as C to use only ASCII character set with single byte encoding, pass LC_ALL=C to awk's environment:
LC_ALL=C awk -f hw1.awk $1

echo "Finished"
exit 0
