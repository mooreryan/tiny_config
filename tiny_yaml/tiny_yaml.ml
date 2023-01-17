open! Base

module E = struct
  exception Type_error of string
end

module Accessor = struct
  include Tiny_config.Accessor.Make (struct
    type config = Yaml.value
  end)

  let type_error msg = raise (E.Type_error msg)

  let type_string = function
    | `A _ ->
        "array"
    | `Bool _ ->
        "bool"
    | `Float _ ->
        "float"
    | `Null ->
        "null"
    | `O _ ->
        "object"
    | `String _ ->
        "string"

  let bool = function
    | `Bool v ->
        v
    | v ->
        type_error ("value must be a bool, found " ^ type_string v)

  let float = function
    | `Float v ->
        v
    | v ->
        type_error ("value must be a float, found " ^ type_string v)

  let int = function
    | `Float v ->
        Int.of_float v
    | v ->
        type_error ("value must be int, found " ^ type_string v)

  let string = function
    | `String v ->
        v
    | v ->
        type_error ("value must be a string, found " ^ type_string v)
end

module Parser = struct
  include Tiny_config.Parser
end

module Converter = struct
  include Tiny_config.Converter.Make (Accessor) (Parser)
end

module Term = struct
  include Tiny_config.Term.Make (struct
    include Yaml

    type t = Yaml.value
  end)
end

module Value = struct
  (** Wrapper for [Or_error.tag] that makes more uniform error tags for config
      problems. *)
  let tag oe ~path =
    let msg = String.concat path ~sep:" -> " in
    let tag = "config error: " ^ msg in
    Or_error.tag oe ~tag

  let oe_to_internal_result = function Ok _ as v -> v | Error e -> Error [e]

  (* Yaml.Util.find_exn raises if the Yaml.value is not an object. Swallow that
     into the Or_error monad. *)
  let yaml_find_key yaml key =
    Or_error.try_with (fun () -> Yaml.Util.find_exn key yaml)

  let no_value_error ~k ~path =
    Or_error.errorf "key %s should have a value, but it did not" k
    |> tag ~path |> oe_to_internal_result

  let error ~e ~path = e |> tag ~path |> oe_to_internal_result

  let find path (accessor, parse) yaml =
    let find_intermediate_key ~k ~ks ~yaml ~path ~loop =
      match yaml_find_key yaml k with
      | Ok (Some v) ->
          loop ks v
      | Ok None ->
          no_value_error ~k ~path
      | Error _ as e ->
          error ~e ~path
    in
    let find_final_key ~yaml ~k ~path =
      match yaml_find_key yaml k with
      | Ok (Some v) ->
          Or_error.try_with (fun () -> v |> accessor)
          |> Or_error.bind ~f:parse |> tag ~path |> oe_to_internal_result
      | Ok None ->
          no_value_error ~k ~path
      | Error _ as e ->
          error ~e ~path
    in
    let rec loop keys yaml =
      match keys with
      | [k] ->
          find_final_key ~yaml ~k ~path
      | [] ->
          failwith "assertion failed: expected non-empty list"
      | k :: ks ->
          find_intermediate_key ~k ~ks ~yaml ~path ~loop
    in
    loop path yaml

  let find_or path (accessor, parse) ~default yaml =
    let find_intermediate_key ~k ~ks ~yaml ~path ~loop =
      match yaml_find_key yaml k with
      | Ok (Some v) ->
          loop ks v
      | Ok None ->
          default |> parse |> tag ~path |> oe_to_internal_result
      | Error _ as e ->
          error ~e ~path
    in
    let find_final_key ~yaml ~k ~path =
      match yaml_find_key yaml k with
      | Ok (Some v) ->
          Or_error.try_with (fun () -> v |> accessor)
          |> Or_error.bind ~f:parse |> tag ~path |> oe_to_internal_result
      | Ok None ->
          default |> parse |> tag ~path |> oe_to_internal_result
      | Error _ as e ->
          error ~e ~path
    in
    let rec loop keys yaml =
      match keys with
      | [k] ->
          find_final_key ~yaml ~k ~path
      | [] ->
          failwith "assertion failed: expected non-empty list"
      | k :: ks ->
          find_intermediate_key ~k ~ks ~yaml ~path ~loop
    in
    loop path yaml

  let find_opt path (accessor, parse) yaml =
    let find_intermediate_key ~k ~ks ~yaml ~path ~loop =
      match yaml_find_key yaml k with
      | Ok (Some v) ->
          loop ks v
      | Ok None ->
          Ok None |> oe_to_internal_result
      | Error _ as e ->
          error ~e ~path
    in
    let find_final_key ~yaml ~k ~path =
      match yaml_find_key yaml k with
      | Ok (Some v) ->
          Or_error.try_with (fun () -> v |> accessor)
          |> Or_error.bind ~f:parse |> Result.map ~f:Option.some |> tag ~path
          |> oe_to_internal_result
      | Ok None ->
          Ok None |> oe_to_internal_result
      | Error _ as e ->
          e |> tag ~path |> oe_to_internal_result
    in
    let rec loop keys yaml =
      match keys with
      | [k] ->
          find_final_key ~yaml ~k ~path
      | [] ->
          failwith "assertion failed: expected non-empty list"
      | k :: ks ->
          find_intermediate_key ~k ~ks ~yaml ~path ~loop
    in
    loop path yaml
end
