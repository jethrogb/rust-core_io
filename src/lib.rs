//! <p id="core_io-show-docblock"></p>
//! This is just a listing of the functionality available in this crate. See
//! the [std documentation](https://doc.rust-lang.org/nightly/std/io/index.html)
//! for a full description of the functionality.
#![allow(stable_features,unused_features)]
#![feature(question_mark,const_fn,collections,alloc,unicode,copy_from_slice,str_char,try_from,str_internals,slice_internals)]
#![no_std]

#[cfg_attr(all(feature="collections", not(collections_in_alloc)), macro_use)]
#[cfg(all(feature="collections", not(collections_in_alloc)))] extern crate collections;

#[cfg_attr(all(feature="collections", collections_in_alloc), macro_use)]
#[cfg(any(all(feature="collections", collections_in_alloc), feature="alloc"))]
extern crate alloc;

#[cfg(all(feature="collections", collections_in_alloc))]
use alloc as collections;

#[cfg(rustc_unicode)]
extern crate rustc_unicode;
#[cfg(std_unicode)]
extern crate std_unicode;

#[cfg(not(feature="collections"))]
pub type ErrorString = &'static str;

// Provide Box::new wrapper
#[cfg(not(feature="alloc"))]
struct FakeBox<T>(core::marker::PhantomData<T>);
#[cfg(not(feature="alloc"))]
impl<T> FakeBox<T> {
	fn new(val: T) -> T {
		val
	}
}

// Needed for older compilers, to ignore vec!/format! macros in tests
#[cfg(not(feature="collections"))]
#[allow(unused)]
macro_rules! vec (
	( $ elem : expr ; $ n : expr ) => { () };
	( $ ( $ x : expr ) , * ) => { () };
	( $ ( $ x : expr , ) * ) => { () };
);
#[cfg(not(feature="collections"))]
#[allow(unused)]
macro_rules! format {
	( $ ( $ arg : tt ) * ) => { () };
}

include!(concat!(env!("OUT_DIR"), "/io.rs"));
pub use io::*;
