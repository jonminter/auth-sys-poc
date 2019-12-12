#!/bin/bash


# Revoke certificate
openssl ca \
    -config etc/signing-ca.conf \
    -revoke ca/signing-ca/01.pem \
    -crl_reason superseded