open! Base
include Parser_intf

type ('a, 'b) t = 'a -> 'b Or_error.t

let return x = Or_error.return x

let v f = f

module Bool = struct
  type nonrec t = (bool, bool) t

  let return = return
end

module Float = struct
  type nonrec t = (float, float) t

  let return = return

  let non_negative x =
    if Float.(x >= 0.0) then Or_error.return x
    else Or_error.errorf "expected a float >= 0.0, but got %f" x

  let positive x =
    if Float.(x > 0.0) then Or_error.return x
    else Or_error.errorf "expected a float > 0.0, but got %f" x
end

module Int = struct
  type nonrec t = (int, int) t

  let return = return

  let non_negative x =
    if Int.(x >= 0) then Or_error.return x
    else Or_error.errorf "expected an int >= 0, but got %d" x

  let positive x =
    if Int.(x > 0) then Or_error.return x
    else Or_error.errorf "expected an int > 0, but got %d" x
end

module String = struct
  type nonrec t = (string, string) t

  let return = return

  let non_empty = function
    | "" ->
        Or_error.error_string "expected a non-empty string"
    | s ->
        Or_error.return s
end

let bool = Bool.return

let float = Float.return

let int = Int.return

let string = String.return
