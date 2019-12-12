#!/bin/bash
# Debug commands
set -x

function check_failed() {
    set +x
    exit_code=$1
    error_message=$2

    if [ $exit_code -ne 0 ]; then
        echo $error_message
        exit $exit_code
    fi
    set -x
}

function print_header() {
    set +x
    header_message=$1
    echo "==============================================================================="
    echo $header_message
    echo "==============================================================================="
    set -x
}