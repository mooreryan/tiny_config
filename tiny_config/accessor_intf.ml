open! Base

module type Config = sig
  type config
end

module type Base = sig
  type config

  type 'a t = config -> 'a
end

module type S = sig
  include Base

  val bool : bool t

  val float : float t

  val int : int t

  val string : string t
end

module type Intf = sig
  module type Base = Base

  module type S = S

  module Make : functor (M : Config) -> Base with type config = M.config
end
