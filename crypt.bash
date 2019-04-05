#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: crypt.bash [e|d] <filename-secret-key> <file> (you may need to enter keyphrase for secret key)"
    echo "Examples: encrypt: crypt.bash e secret_key <datafile>"
    echo "          decrypt: crypt.bash d secret_key <bundle>"
    exit
fi

mode=$1
secret_key=$2
public_key=${secret_key}.pub
datafile=$3
bundle=$3

tempfolder=$(mktemp -d tempfolder.XXXX)
#echo "Tempfolder is ${tempfolder}"

if [ "$mode" == "e" ]; then
    #echo "Generating random key for single use of 128 bits ..."
    openssl rand -base64 -out ${tempfolder}/random.key 128

    #echo "Encrypting data with random key ..."
    openssl enc -aes-256-cbc -a -salt -in ${datafile} -out ${tempfolder}/datafile.crypt.base64 -pass file:${tempfolder}/random.key -md md5

    #echo "Encrypting random key with public key ..."
    openssl rsautl -encrypt -inkey ${public_key} -pubin -in ${tempfolder}/random.key -out ${tempfolder}/random.key.crypt

    #echo "Encoding encrypted random key with base64 ..."
    openssl base64 -A -in ${tempfolder}/random.key.crypt -out ${tempfolder}/random.key.crypt.base64

    #echo "Generating cryptographic bundle ..."
    cat ${tempfolder}/random.key.crypt.base64 > ${tempfolder}/bundle.crypt.base64
    echo >> ${tempfolder}/bundle.crypt.base64
    cat ${tempfolder}/datafile.crypt.base64 >> ${tempfolder}/bundle.crypt.base64

    #echo "Removing intermidate files ..."
    rm ${tempfolder}/datafile.crypt.base64 ${tempfolder}/random.key.crypt.base64 ${tempfolder}/random.key.crypt ${tempfolder}/random.key

    #echo "Cryptographic bundle is ${tempfolder}/bundle.crypt.base64"
    echo ${tempfolder}/bundle.crypt.base64
else
    #echo "Separate cryptographic bundle into components ..."
    head -n 1 ${bundle} > ${tempfolder}/random.key.crypt.base64
    tail -n +2 ${bundle} > ${tempfolder}/datafile.crypt.base64

    #echo "Decoding base64 encrypted random key ..."
    openssl base64 -A -d -in ${tempfolder}/random.key.crypt.base64 -out ${tempfolder}/random.key.crypt

    #echo "Decoding encrypted random key using secret key ..."
    openssl rsautl -decrypt -inkey ${secret_key} -in ${tempfolder}/random.key.crypt -out ${tempfolder}/random.key

    #echo "Decoding encrypted data with decoded random key ..."
    openssl enc -d -a -aes-256-cbc -in ${tempfolder}/datafile.crypt.base64 -out ${tempfolder}/datafile -pass file:${tempfolder}/random.key -md md5

    #echo "Removing intermidate files ..."
    rm ${tempfolder}/datafile.crypt.base64 ${tempfolder}/random.key.crypt.base64 ${tempfolder}/random.key.crypt ${tempfolder}/random.key

    #echo "Decrypted file is ${tempfolder}/datafile"
    echo ${tempfolder}/datafile
fi

