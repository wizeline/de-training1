## Zeppelin Notebooks
DE Academy uses [Zeppelin notebooks](https://zeppelin.apache.org/) as a teaching tool for students to try their Spark code.

This folder contains notebooks organized by visibility (`public` for consumption by students and `private` for mentors and instructors) and session (e.g. `c1`, `c2`, etc.) For each session you should see at least two notebooks: one for examples and exercises (which contains code in PySpark and Scala) and another one for solutions to the exercises.

## General Workflow
1. Create/delete/modify a notebook (following the existing structure) in a feature branch.
2. Open a PR for others to review and test the notebooks with non-Wizeline accounts in a GCP Dataproc cluster.
3. Run `./publish.sh` when your team is happy with the changes.

The `publish.sh` script will try to copy and commit notebooks to the public repo for DE Academy. You can clone that repo wherever you want, but you need to make sure that the environment variable `DE_ACADEMY_REPO` points to the root of that repo. If you don't have it set up, `publish.sh` will alert you and suggest a fix.

The `publish.sh` script will also try to commit the changes copied from this repo to the public repo for DE Academy, but you will have a chance to write a commit message.

If you are suddenly facing an unknown editor, you're most likely looking at Vi[m]. You can use the instructions [here](https://stackoverflow.com/questions/4708645/vim-for-windows-what-do-i-type-to-save-and-exit-from-a-file) to fix your problem, and later on read [this](https://stackoverflow.com/questions/2596805/how-do-i-make-git-use-the-editor-of-my-choice-for-commits) if you want git to use your favorite editor instead of Vim.
