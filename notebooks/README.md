## Zeppelin Notebooks
DE Academy uses [Zeppelin notebooks](https://zeppelin.apache.org/) as a teaching tool for students to try their Spark code.

This folder contains notebooks organized by session (e.g. `c1`, `c2`, etc.) For each session you should see at least two notebooks: one for examples (which contains code in PySpark and Scala) and another one for exercises.

## General Workflow
1. Create/delete/modify a notebook in a feature branch.
3. Open a PR for others to review and test the notebooks with non-Wizeline accounts in a GCP Dataproc cluster.
5. Run `./publish.sh` when your team is happy with the changes.

The `publish.sh` script will try to copy and commit notebooks to the public repo for DE Academy. You can clone that repo wherever you want, but you need to make sure that the environment variable `DE_ACADEMY_REPO` points to the root of that repo. If you don't have it set up, `publish.sh` will alert you and suggest a fix.
