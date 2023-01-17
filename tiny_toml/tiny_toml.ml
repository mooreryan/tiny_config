open! Base

module Accessor = struct
  include Tiny_config.Accessor.Make (struct
    type config = Otoml.t
  end)

  let bool = Otoml.get_boolean ~strict:true

  let float = Otoml.get_float ~strict:true

  let int = Otoml.get_integer ~strict:true

  let string = Otoml.get_string ~strict:true
end

module Parser = struct
  include Tiny_config.Parser
end

module Converter = struct
  include Tiny_config.Converter.Make (Accessor) (Parser)
end

module Term = struct
  include Tiny_config.Term.Make (Otoml)
end

module Value = struct
  (** Wrapper for [Or_error.tag] that makes more uniform error tags for config
      problems. *)
  let tag oe ~path =
    let msg = String.concat path ~sep:" -> " in
    let tag = "config error: " ^ msg in
    Or_error.tag oe ~tag

  let oe_to_internal_result = function Ok _ as v -> v | Error e -> Error [e]

  let find path (accessor, parse) toml =
    Or_error.try_with (fun () -> Otoml.find toml accessor path)
    |> Or_error.bind ~f:parse |> tag ~path |> oe_to_internal_result

  let find_or path (accessor, parse) ~default toml =
    Or_error.try_with (fun () -> Otoml.find_or ~default toml accessor path)
    |> Or_error.bind ~f:parse |> tag ~path |> oe_to_internal_result

  let find_opt path (accessor, parse) toml =
    let result =
      Or_error.try_with (fun () -> Otoml.find_opt toml accessor path)
    in
    match result with
    | Ok maybe -> (
      match maybe with
      | None ->
          Ok None
      | Some v -> (
        match parse v with Ok v -> Ok (Some v) | Error e -> Error [e] ) )
    | Error e ->
        Error [e]
end
