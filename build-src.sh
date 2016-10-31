#!/bin/bash
# Recommended command-line:
#
# commit-db.rb list-valid nightly|GIT_DIR=/your/rust/dir/.git sync.sh

git_file_exists() {
	[ "$(git ls-tree --name-only $IO_COMMIT -- $1)" = "$1" ]
}

git_extract() {
	slashes=${1//[^\/]/}
	git archive $IO_COMMIT $1|tar xf - -C src/$IO_COMMIT --strip-components=${#slashes}
}

git_commits_ordered() {
	format=$1
	shift
	if [ $# -ge 1 ]; then
		git log --topo-order --no-walk=sorted --date=iso-local --pretty=format:$format "$@"
	fi
}

echo_lines() {
	for i in "$@"; do
		echo $i
	done
}

get_io_commits() {
	for COMPILER_COMMIT in $COMPILER_COMMITS; do
		IO_COMMIT=$(git log -n1 --pretty=format:%H $COMPILER_COMMIT -- src/libstd/io)
		if ! grep -q $COMPILER_COMMIT mapping.rs; then
			echo "-Mapping(\"$COMPILER_COMMIT\",\"$IO_COMMIT\")" >> mapping.rs
		fi
		echo $IO_COMMIT
	done
}

get_patch_commits() {
	find $PATCH_DIR -type f -printf %f\\n|cut -d. -f1
}

prepare_version() {
	mkdir src/$IO_COMMIT
	git_extract src/libstd/io/
	if git_file_exists src/libstd/sys/common/memchr.rs; then
		git_extract src/libstd/sys/common/memchr.rs
	else
		git_extract src/libstd/memchr.rs
	fi
	rm -f src/$IO_COMMIT/stdio.rs src/$IO_COMMIT/lazy.rs
}

bold_arrow() {
	echo -ne '\e[1;36m==> \e[0m'
}

prompt_changes() {
	local MAIN_GIT_DIR="$GIT_DIR"
	local GIT_DIR=./.git CORE_IO_COMMIT=$IO_COMMIT
	git init > /dev/null
	git add .
	git commit -a -m "rust src import" > /dev/null
	export CORE_IO_COMMIT
	
	bold_arrow; echo 'No patch found for' $IO_COMMIT
	bold_arrow; echo 'Nearby commit(s) with patches:'
	echo
	GIT_DIR="$MAIN_GIT_DIR" git_commits_ordered '%H %cd' $(get_patch_commits) $IO_COMMIT | \
	grep --color=always -1 $IO_COMMIT | sed /$IO_COMMIT/'s/$/ <=== your commit/'
	echo
	bold_arrow; echo -e "Try applying one of those using: \e[1;36mpatch -p1 < ../../patches/COMMIT.patch\e[0m"
	bold_arrow; echo -e "Remember to test your changes with: \e[1;36mcargo build\e[0m"
	bold_arrow; echo -e "Make your changes now (\e[1;36mctrl-D\e[0m when finished)"
	bash <> /dev/stderr
	while git diff --exit-code > /dev/null; do
		bold_arrow; echo "No changes were made"
		while true; do
			bold_arrow; echo -n "(T)ry again or (A)bort? "
			read answer <> /dev/stderr
			case "$answer" in
				[tT])
					break
					;;
				[aA])
					bold_arrow; echo "Aborting..."
					exit 1
					;;
			esac
		done
		bash <> /dev/stderr
	done
	bold_arrow; echo "Saving changes as $IO_COMMIT.patch"
	git clean -f -x
	git diff > ../../patches/$IO_COMMIT.patch
	rm -rf .git
}

if [ ! -t 1 ] || [ ! -t 2 ]; then
	echo "==> /dev/stdout or /dev/stderr is not attached to a terminal!"
	echo "==> This script must be run interactively."
	exit 1
fi

cd "$(dirname "$0")"
PATCH_DIR="$PWD/patches"
COMPILER_COMMITS=$(cat)
IO_COMMITS=$(get_io_commits|sort -u)
PATCH_COMMITS=$(get_patch_commits|sort -u)
NEW_COMMITS=$(comm -2 -3 <(echo_lines $IO_COMMITS) <(echo_lines $PATCH_COMMITS))
OLD_COMMITS=$(comm -1 -2 <(echo_lines $IO_COMMITS) <(echo_lines $PATCH_COMMITS))

find src -mindepth 1 -type d -prune -exec rm -rf {} \;

for IO_COMMIT in $OLD_COMMITS $(git_commits_ordered %H $NEW_COMMITS|tac); do
	if ! [ -d src/$IO_COMMIT ]; then
		prepare_version
		
		if [ -f patches/$IO_COMMIT.patch ]; then
			patch -s -p1 -d src/$IO_COMMIT < patches/$IO_COMMIT.patch
		else
			cd src/$IO_COMMIT
			prompt_changes
			cd ../..
		fi
	fi
done

chmod 000 .git
cargo package
chmod 755 .git
