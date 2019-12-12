#!/bin/bash

source ./bin/common.sh

root_ca_path=./ca/root-ca
root_ca_config=./etc/root-ca.conf
root_ca_ext=root_ca_ext

signing_ca_path=./ca/signing-ca
signing_ca_config=./etc/signing-ca.conf
signing_ca_ext=signing_ca_ext

crl_path=./crl
id_cert_path=./id-certificates

root_ca_priv_key=ca-root-priv.key
root_ca_cert_days=365
root_ca_cert=ca-root-cert.crt

# Create Root CA

function create_ca() {
    ca_name=$1
    ca_path=$2
    ca_config_file=$3
    sign_config_file=$4
    ca_ext=$5

    # Create dirs
    print_header "Creating CA directories for $ca_name"
    mkdir -p $ca_path/private $ca_path/db $ca_path/crl
    check_failed $? "Failed creating CA direcrtories"
    chmod 0700 $ca_path/private
    check_failed $? "Failed setting permissions for CA direcrtories"

    # Create CA db
    print_header "Creating CA databases for $ca_name"
    touch $ca_path/db/ca.db $ca_path/db/ca.db.attr
    echo 01 > $ca_path/db/ca.crt.srl
    echo 01 > $ca_path/db/ca.crl.srl

    # Create CA CSR/key
    print_header "Creating CA CSR/Private Key for $ca_name"
    key_path=$ca_path/private/ca.key
    openssl genrsa -out $key_path 4096
    check_failed $? "Failed generating CA private key"
    openssl req -new \
        -config $ca_config_file \
        -key $key_path \
        -out $ca_path/ca.csr
    check_failed $? "Failed creating CA certificate CSR"

    # Create CA cert
    print_header "Signing CA cert for $ca_name"
    should_selfsign=''
    if [ "$ca_config_file" == "$sign_config_file" ]; then
        should_selfsign='-selfsign'
    fi
    openssl ca $should_selfsign \
        -config $sign_config_file \
        -in $ca_path/ca.csr \
        -out $ca_path/ca.crt \
        -extensions $ca_ext
    check_failed $? "Failed signing CA certificate"
}

create_ca "Root CA" $root_ca_path $root_ca_config $root_ca_config $root_ca_ext
create_ca "Signing CA" $signing_ca_path $signing_ca_config $root_ca_config $signing_ca_ext

# Generate cert chain
openssl crl2pkcs7 -nocrl \
    -certfile ca/signing-ca/ca.crt \
    -certfile ca/root-ca/ca.crt \
    -out ca/signing-ca-chain.p7c \
    -outform der