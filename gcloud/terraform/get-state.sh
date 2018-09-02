#!/usr/bin/env bash -xe

# Clone state if none exists
if [ ! -d "state/.git" ]
then
    git clone -b master keybase://team/datacartel.de_training/state
fi

# Change folder
pushd state
# Get updates
git pull origin master
# Return to folder
popd
# Symlink tfstate
if [ -L "terraform.tfstate" ] || [ ! -f "terraform.tfstate" ]
then
    ln -sf state/terraform.tfstate
else
    echo "ERROR: You have a local terraform state that is not in synchronized"
    exit 1
fi
