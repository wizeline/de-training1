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
if [ -L "terraform.tfstate" ] || [ ! -f "terraform.tfstate" ]
then
    ln -sf state/terraform.tfstate
else
    echo "ERROR: You have a local terraform state that is not in synchronized"
    exit 1
fi
