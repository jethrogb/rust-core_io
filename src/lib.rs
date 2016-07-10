//! <p id="core_io-show-docblock"></p>
//! This is just a listing of the functionality available in this crate. See
//! the [std documentation](https://doc.rust-lang.org/nightly/std/io/index.html)
//! for a full description of the functionality.
#![allow(stable_features,unused_features)]
#![feature(question_mark,const_fn,collections,alloc,unicode,copy_from_slice,str_char)]
#![no_std]

#[macro_use]
extern crate collections;
extern crate alloc;
extern crate rustc_unicode;

include!(concat!(env!("OUT_DIR"), "/io.rs"));
pub use io::*;
