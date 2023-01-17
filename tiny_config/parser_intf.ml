open! Base

module type S = sig
  type ('a, 'b) t = 'a -> 'b Or_error.t

  val v : ('a -> 'b Or_error.t) -> ('a, 'b) t

  val return : ('a, 'a) t

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
  module type S = S

  include S
end
