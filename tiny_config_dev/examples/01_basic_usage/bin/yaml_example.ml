open! Base

(* Stick all config logic in this module. *)
module Config = struct
  open Tiny_yaml

  type t = {a: int; b: string; c: float} [@@deriving sexp_of]

  (* Define the terms *)

  let a : int Term.t = Value.find ["a"] Converter.int

  let b : string Term.t = Value.find ["b"] Converter.string

  let c : float Term.t = Value.find ["c"] Converter.float

  (* Let-operator style *)
  let term : t Term.t =
    let open Term.Let_syntax in
    let%map a = a and b = b and c = c in
    {a; b; c}

  (* Applicative style, if you prefer that instead. *)
  let _term : t Term.t =
    let v a b c = {a; b; c} in
    Term.(return v <*> a <*> b <*> c)

  (* Parse the file path into an Yaml.value, or fail. *)
  let yaml_of_file name =
    match Yaml.of_string @@ Stdio.In_channel.read_all name with
    | Ok config ->
        config
    | Error (`Msg msg) ->
        failwith msg

  (* Pretty print the config or_error *)
  let print config = Stdio.print_s @@ [%sexp_of: t Or_error.t] config

  let of_file_name name = Tiny_yaml.Term.eval term ~config:(yaml_of_file name)
end

(* Get the path of the toml config file, or fail. *)
let parse_argv () =
  match Sys.get_argv () with
  | [|_; config|] ->
      config
  | _ ->
      failwith "usage: yaml_example.exe <config.toml>"

(* Print config *)
let () = Config.print @@ Config.of_file_name @@ parse_argv ()
