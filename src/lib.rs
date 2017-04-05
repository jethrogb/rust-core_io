//! <p id="core_io-show-docblock"></p>
//! This is just a listing of the functionality available in this crate. See
//! the [std documentation](https://doc.rust-lang.org/nightly/std/io/index.html)
//! for a full description of the functionality.
#![allow(stable_features,unused_features)]
#![feature(question_mark,const_fn,collections,alloc,unicode,copy_from_slice,str_char,try_from,str_internals)]
#![no_std]

#[cfg_attr(feature="collections",macro_use)]
#[cfg(feature="collections")] extern crate collections;
#[cfg(feature="alloc")] extern crate alloc;
extern crate std_unicode;

#[cfg(not(feature="collections"))]
pub type ErrorString = &'static str;

// Provide Box::new wrapper
#[cfg(not(feature="alloc"))]
#[derive(Debug)]
#[cfg(not(feature="alloc"))]
struct FakeBox<T>(T);
impl<T> FakeBox<T> {
	fn new(val: T) -> Self {
		FakeBox(val)
	}
}

#[cfg(not(feature="alloc"))]
impl<T> ::core::ops::Deref for FakeBox<T> {
    type Target = T;
    fn deref(&self) -> &T {
        &self.0
    }
}

#[cfg(not(feature="alloc"))]
impl<T> ::core::ops::DerefMut for FakeBox<T> {
    fn deref_mut(&mut self) -> &mut T {
        &mut self.0
    }
}

// Needed for older compilers, to ignore vec!/format! macros in tests
#[cfg(not(feature="collections"))]
macro_rules! vec (
	( $ elem : expr ; $ n : expr ) => { () };
	( $ ( $ x : expr ) , * ) => { () };
	( $ ( $ x : expr , ) * ) => { () };
);
#[cfg(not(feature="collections"))]
macro_rules! format {
	( $ ( $ arg : tt ) * ) => { () };
}

include!(concat!(env!("OUT_DIR"), "/io.rs"));
pub use io::*;
