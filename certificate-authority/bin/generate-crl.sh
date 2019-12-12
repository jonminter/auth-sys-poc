#!/bin/bash

openssl ca -gencrl \
    -config etc/signing-ca.conf \
    -out crl/signing-ca.crl