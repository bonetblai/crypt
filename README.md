# crypt

Cryptographic encryption/decryption of files


## OpenSSL based encryption/decryption of datafiles

### Generate secret/public keys for RSA:

1. Generate secret key (need keyphrase from stdin):

```shell
openssl genrsa -des3 -out secret_key 2048
```

2. Generate public key using secret key (need keyphrase for secret key from stdin):

```shell
openssl rsa -in secret_key -out secret_key.pub -outform PEM -pubout
```

### Encrypt datafile using random key for single use

1. Generate random key for single use (128 is key length):

```shell
openssl rand -base64 -out random_key 128
```

2. Encrypt datafile with random key (store in base64, -A is for single-line output):

```shell
openssl enc -aes-256-cbc -a -A -salt -in datafile -out datafile.crypt.base64 -pass file:random_key
```

3. Encrypt random key with public key:

```shell
openssl rsautl -encrypt -inkey secret_key.pub -pubin -in random_key -out random_key.crypt
```

4. Encode encrypted random key with base64 (-A is single-line output):

```shell
openssl base64 -A -in random_key.crypt -out random_key.crypt.base64
```

5. Concat encrypted random key and encrypted data file into single (cryptographic) bundle:

```shell
cat random_key.crypt.base64 datafile.crypt.base64 > bundle.crypt.base64
```

### Decrypt cryptographic bundle

1. Separate bundle into `random_key.crypt.base64` and `datafile.crypt.base64`

```shell
head -1 bundle.crypt.base64 > random_key.crypt.base64
tail -1 bundle.crypt.base64 > datafile_key.crypt.base64
```

2. Decode base64 encrypted random key (-A is single-line input):

```shell
openssl base64 -A -d -in random_key.crypt.base64 -out random_key.crypt
```

3. Decode encrypted random key using secret key (need keyphrase for secret key):

```shell
openssl rsautl -decrypt -inkey secret_key -in random_key.crypt -out random_key
```

4. Decode datafile using decoded random key (-A is single-line input):

```shell
openssl enc -d -a -A -aes-256-cbc -in datafile.crypt.base64 -out datafile -pass file:random_key
```
