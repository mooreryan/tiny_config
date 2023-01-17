open! Base

module type S = sig
  type ('a, 'b) converter

  type 'a term

  val find : string list -> ('a, 'b) converter -> 'b term

  val find_or : string list -> ('a, 'b) converter -> default:'a -> 'b term

  val find_opt : string list -> ('a, 'b) converter -> 'b option term
end

module type Intf = sig
  module type S = S
end
