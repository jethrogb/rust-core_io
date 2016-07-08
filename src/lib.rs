#![allow(stable_features,unused_features)]
#![feature(question_mark,const_fn,collections,alloc,unicode,copy_from_slice,str_char)]
#![no_std]

#[macro_use]
extern crate collections;
extern crate alloc;
extern crate rustc_unicode;

mod io;
pub use io::*;
