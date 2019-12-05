#!/bin/bash -e

# Old versions should come first so we go from oldest Cargo.lock version to
# newest when building.
RUST_VERSIONS=$(awk '{print $1}' <<EOF
    nightly-2016-03-11 # first supported version
    nightly-2016-07-07 # core_io release
    nightly-2016-10-28 # core_io release
    nightly-2016-12-05 # edge case: no unicode crate
    nightly-2017-01-18 # edge case: rustc_unicode crate
    nightly-2017-03-03 # edge case: rustc_unicode crate
    nightly-2017-03-04 # edge case: std_unicode crate
    nightly-2017-04-09 # core_io release
    nightly-2017-06-15 # edge case: collections crate
    nightly-2017-06-16 # edge case: no collections crate
    nightly-2018-01-01 # edge case: no memchr in core
    nightly-2018-01-02 # edge case: memchr in core
    nightly-2018-03-07 # core_io release
    nightly-2018-08-06 # edge case: old features allowed
    nightly-2018-08-14 # edge case: old features disallowed
    nightly-2018-08-15 # edge case: non_exhaustive feature
    nightly-2019-02-25 # edge case: bind_by_move_pattern_guards feature
    nightly-2019-07-01 # core_io release
    nightly-2019-12-01 # core_io release
EOF
)

if [ "$1" = "install" ]; then
    for v in $RUST_VERSIONS; do
        rustup install $v &
    done
    git clone https://github.com/rust-lang/rust/
    wait
    exit 0
fi

cut -d\" -f2 mapping.rs | GIT_DIR=$(readlink -f rust/.git) ./build-src.sh clean
for v in $RUST_VERSIONS; do
    echo '==> Version '$v
    cargo +$v build
    cargo +$v build --features alloc
    cargo +$v build --features collections
done
