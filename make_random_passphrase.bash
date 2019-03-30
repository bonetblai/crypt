#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: make_random_passphrase.bash <num-blocks> (a block consists of 3 hexdigits; blocks are separated by hyphens)"
    echo "Examples: make_random_passphrase.bash 4"
    exit
fi

n=$1
key=`openssl rand -hex $((2*n))`

n=$n key=$key python - <<EOF
import sys
import os
n = int(os.environ['n'])
key = list(os.environ['key'])
for i in range(0,n):
    key[4*i+3] = '-'
print (''.join(key))[0:4*n-1]
EOF

