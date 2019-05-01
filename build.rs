extern crate rustc_version;

use std::env;
use std::fs::File;
use std::io::Write;
use std::path::PathBuf;

struct Mapping(&'static str,&'static str);

fn parse_mappings(mut mappings: &'static str) -> Vec<Mapping> {
	// FIXME: The format used here used to be parsed directly by rustc, which
	// is why it's kind of weird. It should be changed to a saner format.

	const P1: &'static str = r#"-Mapping(""#;
	const P2: &'static str = r#"",""#; ;
	const P3: &'static str = "\")\n";

	trait TakePrefix: Sized {
		fn take_prefix(&mut self, mid: usize) -> Self;
	}

	impl<'a> TakePrefix for &'a str {
		fn take_prefix(&mut self, mid: usize) -> Self {
			let prefix = &self[..mid];
			*self = &self[mid..];
			prefix
		}
	}

	let mut result = Vec::with_capacity( mappings.len() / (P1.len()+40+P2.len()+40+P3.len()) );

	while mappings.len() != 0 {
		match (
			mappings.take_prefix(P1.len()),
			mappings.take_prefix(40),
			mappings.take_prefix(P2.len()),
			mappings.take_prefix(40),
			mappings.take_prefix(P3.len()),
		) {
			(P1, hash1, P2, hash2, P3) => result.push(Mapping(hash1, hash2)),
			_ => panic!("Invalid input in mappings"),
		}
	}

	result
}

fn main() {
	let ver=rustc_version::version_meta();

	let io_commit=match env::var("CORE_IO_COMMIT") {
		Ok(c) => c,
		Err(env::VarError::NotUnicode(_)) => panic!("Invalid commit specified in CORE_IO_COMMIT"),
		Err(env::VarError::NotPresent) => {
			let mappings=parse_mappings(include_str!("mapping.rs"));

			let compiler=ver.commit_hash.expect("Couldn't determine compiler version");
			mappings.iter().find(|&&Mapping(elem,_)|elem==compiler).expect("Unknown compiler version, upgrade core_io?").1.to_owned()
		}
	};

	if ver.commit_date.as_ref().map_or(false,|d| &**d>="2018-01-01") {
		println!("cargo:rustc-cfg=core_memchr");
	}

	if ver.commit_date.as_ref().map_or(false,|d| &**d>="2017-06-15") {
		println!("cargo:rustc-cfg=no_collections");
	}

	if ver.commit_date.as_ref().map_or(false,|d| &**d<"2016-12-15") {
		println!("cargo:rustc-cfg=rustc_unicode");
	} else if ver.commit_date.as_ref().map_or(false,|d| &**d<"2017-03-03") {
		println!("cargo:rustc-cfg=std_unicode");
	}

	let mut dest_path=PathBuf::from(env::var_os("OUT_DIR").unwrap());
	dest_path.push("io.rs");
	let mut f=File::create(&dest_path).unwrap();
	
	let mut target_path=PathBuf::from(env::var_os("CARGO_MANIFEST_DIR").unwrap());
	target_path.push("src");
	target_path.push(io_commit);
	target_path.push("mod.rs");

	f.write_all(br#"#[path=""#).unwrap();
	f.write_all(target_path.into_os_string().into_string().unwrap().replace("\\", "\\\\").as_bytes()).unwrap();
	f.write_all(br#""] mod io;"#).unwrap();
}
