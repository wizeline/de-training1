#!/usr/bin/env bash

export ERROR=`tput setaf 1`
export SUCCESS=`tput setaf 2`
export WARNING=`tput setaf 3`
export INFO=`tput setaf 6`
export RESET=`tput sgr0`

if [ -z "$DE_ACADEMY_REPO" ]; then
    echo "${ERROR}ERROR: The environment variable ${INFO}DE_ACADEMY_REPO${ERROR} is not set${RESET}"
    echo "You need to set it to point to the public DE Academy repo (e.g. ${INFO}export DE_ACADEMY_REPO=path${RESET})"
else
    cp ./c1/* "$DE_ACADEMY_REPO/notebooks/c1"
    cp ./c2/* "$DE_ACADEMY_REPO/notebooks/c2"
    cp ./c3/* "$DE_ACADEMY_REPO/notebooks/c3"
    cp ./c4/* "$DE_ACADEMY_REPO/notebooks/c4"

    pushd "$DE_ACADEMY_REPO"
    git add .
    git commit
    popd
fi
