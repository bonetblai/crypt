# crypt

Cryptographic encryption/decryption of files


## OpenSSL based encryption/decryption of datafiles

### Generate secret/public keys for RSA:

1. Generate secret key (need keyphrase from stdin):

```openssl genrsa -des3 -out secret.key 2048```

Generate public key using secret key (need keyphrase for secret key from stdin):
openssl rsa -in secret.key -out public.key -outform PEM -pubout

- Encrypt datafile using random key for single use

Generate random key for single use (128 is key length):
openssl rand -base64 -out random.key 128

Encrypt datafile with random key (store in base64, -A is for single-line output):
openssl enc -aes-256-cbc -a -A -salt -in datafile -out datafile.crypt.base64 -pass file:random.key

Encrypt random key with public key:
openssl rsautl -encrypt -inkey public.key -pubin -in random.key -out random.key.crypt

Encode encrypted random key with base64 (-A is single-line output):
openssl base64 -A -in random.key.crypt -out random.key.crypt.base64

Concat encrypted random key and encrypted data file into single bundle:
cat random.key.crypt.base64 datafile.crypt.base64 > bundle.crypt.base64

- Decrypt cryptographic bundle:

Separate bundle into random.key.crypt.base64 and datafile.crypt.base64
head -1 bundle.crypt.base64 > random.key.crypt.base64
tail -1 bundle.crypt.base64 > datafile.key.crypt.base64

Decode base64 encrypted random key (-A is single-line input):
openssl base64 -A -d -in random.key.crypt.base64 -out random.key.crypt

Decode encrypted random key using secret key (need keyphrase for secret key):
openssl rsautl -decrypt -inkey secret.key -in random.key.crypt -out random.key

Decode datafile using decoded random key (-A is single-line input):
openssl enc -d -a -A -aes-256-cbc -in datafile.crypt.base64 -out datafile -pass file:random.key

