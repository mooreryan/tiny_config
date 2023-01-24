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
