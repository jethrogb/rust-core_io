#!/bin/sh
# Recommended command-line:
#
# commit-db.rb list-valid nightly|GIT_DIR=/your/rust/dir/.git sync.sh

cd "$(dirname "$0")"
for COMPILER_COMMIT in $(sort -u); do
	IO_COMMIT=$(git log -n1 --pretty=format:%H $COMPILER_COMMIT -- src/libstd/io)
	if ! [ -d src/$IO_COMMIT ]; then
		mkdir src/$IO_COMMIT
		git archive $IO_COMMIT src/libstd/io|tar xf - -C src/$IO_COMMIT --strip-components=3
		git archive $IO_COMMIT src/libstd/memchr.rs|tar xf - -C src/$IO_COMMIT --strip-components=2
		rm -f src/$IO_COMMIT/stdio.rs src/$IO_COMMIT/lazy.rs
	fi
	if ! grep -q $COMPILER_COMMIT mapping.rs; then
		echo "-Mapping(\"$COMPILER_COMMIT\",\"$IO_COMMIT\")" >> mapping.rs
	fi
done
