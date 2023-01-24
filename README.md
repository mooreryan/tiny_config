# Tiny Config

A tiny library for config file parsing.

Multiple packages are included in this repository:

- tiny_config
    - Parent library defining types, functors, and parsers used by specific implementations
- tony_toml
    - Library for parsing TOML files
	- Uses [OTOML](https://opam.ocaml.org/packages/otoml/)
- tiny_yaml
    - Library for parsing YAML files
	- Uses [YAML](https://opam.ocaml.org/packages/yaml/)

## Install

These packages are not yet on Opam.  You will have to pin from the git repository or a release.

You need to pin `tiny_config` first, as the other packages depend on it.

```shell
$ opam pin add tiny_config https://github.com/mooreryan/tiny_config/archive/refs/tags/0.0.1.tar.gz
```

Then depending on your needs, pin the other packages.

```shell
# If you want to parse TOML files
$ opam pin add tiny_toml https://github.com/mooreryan/tiny_config/archive/refs/tags/0.0.1.tar.gz

# If you want to parse YAML files
$ opam pin add tiny_yaml https://github.com/mooreryan/tiny_config/archive/refs/tags/0.0.1.tar.gz

# If you want to run the tests or work on development
$ opam pin add tiny_config_dev https://github.com/mooreryan/tiny_config/archive/refs/tags/0.0.1.tar.gz
```

Of course, you may rather pin from the git repository directly.

```shell
$ git clone https://github.com/mooreryan/tiny_config.git
$ cd tiny_config
$ opam pin add tiny_config .
$ opam pin add tiny_toml .
$ opam pin add tiny_yaml .
$ opam pin add tiny_config_dev .
```

## Quick start

Here is a simple example that gets the value of `threads` from a TOML file.

```ocaml
open! Base

(* Get file_name from CLI arguments. *)
let file_name = (Sys.get_argv ()).(1)

(* Parse the file into an Otoml.t. *)
let config = Otoml.Parser.from_file file_name

(* Get the value of threads from then config file. *)
let threads =
  Tiny_toml.(Term.eval ~config @@ Value.find ["threads"] Converter.Int.positive)

(* Print the result. *)
let () = Stdio.print_s @@ [%sexp_of: int Or_error.t] threads
```

## Examples

You can find more interesting (and tested) usage examples [here](https://github.com/mooreryan/tiny_config/tree/main/tiny_config_dev/examples).

## Docs

For more examples, API, and other usage info, see the [docs](https://mooreryan.github.io/tiny_config/).

## License

[![license MIT or Apache
2.0](https://img.shields.io/badge/license-MIT%20or%20Apache%202.0-blue)](https://github.com/mooreryan/bio_io)

Licensed under the Apache License, Version 2.0 or the MIT license, at your option. This program may not be copied, modified, or distributed except according to those terms.
