# Infrastructure update flow

Terraform keeps track of the state of the infrastructure based on a state file
(`terraform.tfstate`) the state in the cloud and the defined resources
(`environment.tf` and `environment.tfvars`). To keep the state in sync across
the team we will track the state files in git as a encrypted repo (since it can
contain credentials) using keybase git repos following the a flow similar to the
described in [here](https://medium.com/@delitescere/combining-an-existing-git-repo-with-keybase-encrypted-git-2841609166f0), except that we are gonna use repos instead of submodules.


## Prerequisites

The following steps only need to be setup once per system.

1. Install [keybase](https://keybase.io/download) if is not in your system.
   You can install with brew too, `brew cask install keybase`.

2. Have an account and login to the keybase client

3. Request membership to the keybase teams `datacartel` and
   `datacartel.de_training` if you are nott part of them.

4. And allow keybase protocol in git (*only the required the first time*)
   `git config --global --add protocol.keybase.allow always`


## Flow

1. Update the state with `./get-state.sh`

2. Apply the changes that you need.

3. Go to the `state` sub-folder and commit and push the changes to the
   `terraform.tfstate` file.

4. Go back to the `terraform` folder.

5. Commit and push the changes applied to the `environment.tf` and
   `environment.tfvars` file.
