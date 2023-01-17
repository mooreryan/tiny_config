open! Base

module type S = sig
  type config

  type 'a t

  include Applicative.S with type 'a t := 'a t

  include Applicative.Let_syntax with type 'a t := 'a t

  val eval : 'a t -> config:config -> 'a Or_error.t
end

module type Intf = sig
  module type S = S

  module Make : functor (Config : T) ->
    S
      with type config := Config.t
       and type 'a t = Config.t -> ('a, Error.t list) Result.t
end
