(lang dune 3.5)

(generate_opam_files true)

(cram enable)

(name tiny_config)

(maintainers "Ryan M. Moore")

(authors "Ryan M. Moore")

(homepage "https://github.com/mooreryan/tiny_config")

(source
 (github mooreryan/tiny_config))

(documentation "https://mooreryan.github.io/tiny_config/")

(bug_reports "https://github.com/mooreryan/tiny_config/issues")

(package
 (name tiny_config_dev)
 (allow_empty)
 (synopsis "Dev package for tiny_config")
 (depends
  (ocaml
   (>= "4.10.2"))
  bisect_ppx
  (ocamlformat
   (= "0.23.0"))
  (otoml
   (and
    (>= "1.0.0")))
  (ppx_expect
   (and
    (>= "v0.15.0")
    (< "v0.16.0")))
  (ppx_inline_test
   (and
    (>= "v0.15.0")
    (< "v0.16.0")))
  (ppx_sexp_conv
   (and
    (>= "v0.15.0")
    (< "v0.16.0")))
  (ppx_let
   (and
    (>= "v0.15.0")
    (< "v0.16.0")))
  (stdio
   (and
    (>= "v0.15.0")
    (< "v0.16.0")))
  tiny_config
  tiny_toml
  tiny_yaml
  (yaml
   (and
    (>= "3.0.0")))))

(package
 (name tiny_config)
 (synopsis "A tiny library for config files")
 (version 0.0.1)
 (depends
  (ocaml
   (>= "4.10.2"))
  (base
   (and
    (>= "v0.15.0")
    (< "v0.16.0")))))

(package
 (name tiny_toml)
 (synopsis "A tiny library for TOML config files")
 (version 0.0.1)
 (depends
  (ocaml
   (>= "4.10.2"))
  (base
   (and
    (>= "v0.15.0")
    (< "v0.16.0")))
  (otoml
   (and
    (>= "1.0.0")))
  (tiny_config
   (= "0.0.1"))))

(package
 (name tiny_yaml)
 (synopsis "A tiny library for YAML config files")
 (version 0.0.1)
 (depends
  (ocaml
   (>= "4.10.2"))
  (base
   (and
    (>= "v0.15.0")
    (< "v0.16.0")))
  (tiny_config
   (= "0.0.1"))
  (yaml
   (and
    (>= "3.0.0")))))
