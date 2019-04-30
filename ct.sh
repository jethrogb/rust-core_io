#!/bin/bash -e
RUST_VERSIONS=$(awk '{print $1}' <<EOF
    nightly-2019-04-27 # core_io release
    nightly-2018-08-14 # edge case: old features disallowed
    nightly-2018-08-06 # edge case: old features allowed
    nightly-2018-03-07 # core_io release
    nightly-2018-01-02 # edge case: memchr in core
    nightly-2018-01-01 # edge case: no memchr in core
    nightly-2017-06-16 # edge case: no collections crate
    nightly-2017-06-15 # edge case: collections crate
    nightly-2017-04-09 # core_io release
    nightly-2017-03-04 # edge case: std_unicode crate
    nightly-2017-03-03 # edge case: rustc_unicode crate
    nightly-2017-01-18 # edge case: rustc_unicode crate
    nightly-2016-12-05 # edge case: no unicode crate
    nightly-2016-10-28 # core_io release
    nightly-2016-07-07 # core_io release
    nightly-2015-05-01 # some old version
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
