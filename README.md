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

## Examples

You can find (tested) usage examples [here](https://github.com/mooreryan/tiny_config/tree/main/tiny_config_dev/examples).

## Docs

For more examples, API, and other usage info, see the [docs](https://mooreryan.github.io/tiny_config/).

## License

[![license MIT or Apache
2.0](https://img.shields.io/badge/license-MIT%20or%20Apache%202.0-blue)](https://github.com/mooreryan/bio_io)

Licensed under the Apache License, Version 2.0 or the MIT license, at your option. This program may not be copied, modified, or distributed except according to those terms.
