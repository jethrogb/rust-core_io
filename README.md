# core_io

`std::io` with all the parts that don't work in core removed.

## Adding new nightly versions

First, make sure the commit you want to add is fetch in the git tree at
`/your/rust/dir/.git`. Then, import the right source files:

```
$ echo FULL_COMMIT_ID ...|GIT_DIR=/your/rust/dir/.git ./build-src.sh
```

Instead of echoing in the commit IDs, you might pipe in `rustc-commit-db
list-valid`.

The build-src script will prompt you to create patches for new commits.
