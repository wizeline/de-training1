# Infrastructure update flow

1. Update the state with `./get-state.sh`

2. Apply the changes that you need.

3. Go to the `state` sub-folder and commit and push the changes to the
   `terraform.tfstate` file.

4. Go back to the `terraform` folder.

5. Commit and push the changes to the `environment.tf` and `environment.tfvars`
   file, and `state` submodule folder.
