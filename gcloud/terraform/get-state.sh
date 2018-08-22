#!/usr/bin/env bash -xe

# Clone state if none exists
if [ ! -f "state/.git/config" ]
then
    git submodule update --init
    pushd state
    git checkout master
    popd
fi

# Change folder
pushd state
# Get updates
git pull origin master
# Return to folder
popd
# Symlink tfstate
ln -sf state/terraform.tfstate
