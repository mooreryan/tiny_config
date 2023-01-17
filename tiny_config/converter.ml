open! Base
include Converter_intf

(* The reason we use Parser.P here instead of Parser directly is that we want NO
   mention of tiny_config in any of the child packages. (Even though implementor
   will use them...don't want it facing the user. *)
module Make (A : Accessor.S) (P : Parser.S) :
  S with type 'a accessor := 'a A.t and type ('a, 'b) parser := ('a, 'b) P.t =
struct
  type ('a, 'b) t = 'a A.t * ('a, 'b) P.t

  let v accessor parser = (accessor, parser)

  module Bool = struct
    type nonrec t = (bool, bool) t

    let return = (A.bool, P.bool)
  end

  module Float = struct
    type nonrec t = (float, float) t

    let return = (A.float, P.float)

    let non_negative = (A.float, P.Float.non_negative)

    let positive = (A.float, P.Float.positive)
  end

  module Int = struct
    type nonrec t = (int, int) t

    let return = (A.int, P.int)

    let non_negative = (A.int, P.Int.non_negative)

    let positive = (A.int, P.Int.positive)
  end

  module String = struct
    type nonrec t = (string, string) t

    let return = (A.string, P.string)

    let non_empty = (A.string, P.String.non_empty)
  end

  let bool = Bool.return

  let float = Float.return

  let int = Int.return

  let string = String.return
end
