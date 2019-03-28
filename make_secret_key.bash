#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: make_secret_key.bash <file> <num-bits> (public key stored in <file>.pub)"
    echo "Examples: make_secret_key.bash my_secret_key 2048"
    exit
fi

secret_key=$1
public_key=${secret_key}.pub
num_bits=$2

echo "Making secret key '${secret_key}' ... "
openssl genrsa -des3 -out ${secret_key} ${num_bits}

echo
echo "Making public key '${public_key}' ... "
openssl rsa -in ${secret_key} -out ${public_key} -outform PEM -pubout

