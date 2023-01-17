open! Base

module type Base = sig
  type 'a accessor

  type ('a, 'b) parser

  type ('a, 'b) t = 'a accessor * ('a, 'b) parser

  val v : 'a accessor -> ('a, 'b) parser -> ('a, 'b) t
end

module type S = sig
  include Base

  module Bool : sig
    type nonrec t = (bool, bool) t

    val return : t
  end

  module Float : sig
    type nonrec t = (float, float) t

    val return : t

    val non_negative : t

    val positive : t
  end

  module Int : sig
    type nonrec t = (int, int) t

    val return : t

    val non_negative : t

    val positive : t
  end

  module String : sig
    type nonrec t = (string, string) t

    val return : t

    val non_empty : t
  end

  val bool : Bool.t

  val float : Float.t

  val int : Int.t

  val string : String.t
end

module type Intf = sig
  module type Base = Base

  module type S = S

  module Make : functor (A : Accessor.S) (P : Parser.S) ->
    S with type 'a accessor := 'a A.t and type ('a, 'b) parser := ('a, 'b) P.t
end
