## Adding new nightly versions

First, make sure the commit you want to add is fetch in the git tree at 
`/your/rust/dir/.git`. Then, import the right source files:

```
$ echo FULL_COMMIT_ID ...|GIT_DIR=/your/rust/dir/.git ./sync.sh
```

Instead of echoing in the commit IDs, you might pipe in `rustc-commit-db 
list-valid`.

Now look at the changes with `git status`. If nothing changed then the commit 
you tried to add was already there. If only `mapping.rs` changed, the I/O code 
has not changed for this particular commit. If a directory in `src/` was added, 
`cd` into it to apply the patch.

Find out which previously-existing commit is closest to the new one and search 
this git repository for a commit with the description `Patch COMMIT for core`. 
For example, if you're adding dd56a6ad0845b76509c4f8967e8ca476471ab7e0, the 
best closest commit is 80d733385aa2ff150a5d6f83ecfe55afc7e19e68.

```
$ git log --pretty=oneline --grep=80d733385aa2ff150a5d6f83ecfe55afc7e19e68
92fc0ad81c432b5fa3e848fc1892815ca2f55100 Patch 80d733385aa2ff150a5d6f83ecfe55afc7e19e68 for core
```

The commit ID at the start of the line is the patch we'll try to apply:

```sh
$ git show 92fc0ad81c432b5fa3e848fc1892815ca2f55100|patch -p3
$ cargo build
```

Now, fix any errors `cargo` reports. If `patch` also reported errors, you may 
look at the rejects for inspiration ;).

Finally, commit this new version:

```
$ git commit -m "Patch dd56a6ad0845b76509c4f8967e8ca476471ab7e0 for core" .
```

Do not commit any files in different directories, this will break the patching 
scheme. If `mapping.rs` changed, update it in a separate commit.
