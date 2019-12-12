#!/bin/bash
source ./bin/common.sh

if [ -z "$1" ]; then
    echo "You must supply the user ID (first.last)"
    exit 1
fi

user_id=$1

id_cert_path=./id-certificates
root_domain=.best-pet-adoption.jonminter.dev
user_domain=${user_id}${root_domain}
user_key_path=${id_cert_path}/${user_domain}.key

mkdir -p $id_cert_path

# Generate key pair
print_header "Generating key and CSR"
openssl genrsa -out $user_key_path 2048
check_failed $? "Failed generating key"
openssl req -new \
    -config ./etc/idm.conf \
     -key $user_key_path \
     -out $id_cert_path/$user_domain.csr \
     -subj "/C=US/ST=DC/DC=best-pet-adoption.jonminter/DC=dev/O=Best Pet Adoption LLC/CN=$user_domain"
check_failed $? "Failed signing req"


# Sign cert
print_header "Creating certificate for user"
openssl ca \
    -config etc/signing-ca.conf \
    -in $id_cert_path/$user_domain.csr \
    -out $id_cert_path/$user_domain.crt \
    -extensions email_ext
check_failed $? "Failed creating cert"

# Create PKCS#12 bundle
openssl pkcs12 -export \
    -name $user_id \
    -inkey $user_key_path \
    -in $id_cert_path/$user_domain.crt \
    -out $id_cert_path/$user_domain.p12
check_failed $? "Failed creating PKCS#12 bundle"