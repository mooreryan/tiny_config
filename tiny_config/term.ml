open! Base
include Term_intf

module Make (Config : T) :
  S
    with type config := Config.t
     and type 'a t = Config.t -> ('a, Error.t list) Result.t = struct
  module T0 = struct
    (* Internally, we use an error list to not drop any erros. *)
    type 'a t = Config.t -> ('a, Error.t list) Result.t

    let return : 'a -> 'a t = fun v _otoml -> Ok v

    (* f is a morphism, and v is the functorial value. *)
    let apply : ('a -> 'b) t -> 'a t -> 'b t =
     fun f v otoml ->
      match (f otoml, v otoml) with
      | Ok f', Ok v' ->
          Ok (f' v')
      | (Error _ as e), Ok _ ->
          e
      | Ok _, (Error _ as e) ->
          e
      | Error f_errors, Error v_errors ->
          Error (List.append f_errors v_errors)

    (* Eval returns Or_error to the user. *)
    let eval : 'a t -> config:Config.t -> 'a Or_error.t =
     fun v ~config ->
      match v config with
      | Ok _ as v ->
          v
      | Error errors ->
          Error (Error.of_list errors)

    let map = `Define_using_apply
  end

  module T = struct
    include T0
    include Applicative.Make (T0)
  end

  include T

  module Open_on_rhs_intf = struct
    module type S = Applicative.S
  end

  include Applicative.Make_let_syntax (T) (Open_on_rhs_intf) (T)
end
