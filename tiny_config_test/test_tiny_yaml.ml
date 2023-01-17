open! Base
open Tiny_yaml
open Stdio

let%expect_test "smoke test" =
  let y = Yaml.of_string_exn {|
a:
  b: "yo"
|} in
  let result = Value.find ["a"; "b"] Converter.string |> Term.eval ~config:y in
  print_s @@ [%sexp_of: string Or_error.t] result ;
  [%expect {| (Ok yo) |}]

let%expect_test "find gives an error if nested key is not present" =
  let y = Yaml.of_string_exn {|
a:
  c: 1
|} in
  let result = Term.eval ~config:y @@ Value.find ["a"; "b"] Converter.int in
  print_s @@ [%sexp_of: int Or_error.t] result ;
  [%expect
    {| (Error ("config error: a -> b" "key b should have a value, but it did not")) |}]

let%expect_test "find gives an error if key is not present" =
  let y = Yaml.of_string_exn {|
z:
  c: 1
|} in
  let result = Term.eval ~config:y @@ Value.find ["a"; "b"] Converter.int in
  print_s @@ [%sexp_of: int Or_error.t] result ;
  [%expect
    {| (Error ("config error: a -> b" "key a should have a value, but it did not")) |}]

let%expect_test "find gives an error if value is the wrong type" =
  let y = Yaml.of_string_exn {|
a:
  b: "yo"
|} in
  let result = Term.eval ~config:y @@ Value.find ["a"; "b"] Converter.int in
  print_s @@ [%sexp_of: int Or_error.t] result ;
  [%expect
    {|
    (Error
     ("config error: a -> b"
      ("Tiny_yaml.E.Type_error(\"value must be int, found string\")"))) |}]

let%expect_test "find_opt gives (Ok None) if nested key is not present" =
  let y = Yaml.of_string_exn {|
a:
  c: 1
|} in
  let result = Term.eval ~config:y @@ Value.find_opt ["a"; "b"] Converter.int in
  print_s @@ [%sexp_of: int option Or_error.t] result ;
  [%expect {| (Ok ()) |}]

let%expect_test "find_opt gives (Ok None) if key is not present" =
  let y = Yaml.of_string_exn {|
z:
  c: 1
|} in
  let result = Term.eval ~config:y @@ Value.find_opt ["a"; "b"] Converter.int in
  print_s @@ [%sexp_of: int option Or_error.t] result ;
  [%expect {| (Ok ()) |}]

let%expect_test "find_opt gives an error if value is the wrong type" =
  let y = Yaml.of_string_exn {|
a:
  b: "yo"
|} in
  let result = Term.eval ~config:y @@ Value.find_opt ["a"; "b"] Converter.int in
  print_s @@ [%sexp_of: int option Or_error.t] result ;
  [%expect
    {|
    (Error
     ("config error: a -> b"
      ("Tiny_yaml.E.Type_error(\"value must be int, found string\")"))) |}]

let%expect_test "find_or gives default if nested key is not present and \
                 default parses properly" =
  let y = Yaml.of_string_exn {|
a:
  c: 1
|} in
  let result =
    Term.eval ~config:y @@ Value.find_or ~default:111 ["a"; "b"] Converter.int
  in
  print_s @@ [%sexp_of: int Or_error.t] result ;
  [%expect {| (Ok 111) |}]

let%expect_test "find_or gives default if key is not present and default \
                 parses properly" =
  let y = Yaml.of_string_exn {|
z:
  c: 1
|} in
  let result =
    Term.eval ~config:y @@ Value.find_or ~default:111 ["a"; "b"] Converter.int
  in
  print_s @@ [%sexp_of: int Or_error.t] result ;
  [%expect {| (Ok 111) |}]

(* TODO: test when default fails to parse *)

let%expect_test "find_or gives an error if value is the wrong type" =
  let y = Yaml.of_string_exn {|
a:
  b: "yo"
|} in
  let result =
    Term.eval ~config:y @@ Value.find_or ~default:111 ["a"; "b"] Converter.int
  in
  print_s @@ [%sexp_of: int Or_error.t] result ;
  [%expect
    {|
    (Error
     ("config error: a -> b"
      ("Tiny_yaml.E.Type_error(\"value must be int, found string\")"))) |}]

(* ****************************************************** *)

module Config = struct
  type t = {a: int; b: string; c: float; d: int; e: string; f: float}
  [@@deriving sexp]

  let v a b c d e f = {a; b; c; d; e; f}

  let a = Value.find ["a"] Converter.int

  let b = Value.find ["b"] Converter.string

  let c = Value.find ["c"] Converter.float

  let d = Value.find ["d"] Converter.int

  let e = Value.find ["e"] Converter.string

  let f = Value.find ["f"] Converter.float

  let x = Term.(return v <*> a <*> b <*> c <*> d <*> e <*> f)

  let y : t Term.t =
    let open Term.Let_syntax in
    let%map a = a and b = b and c = c and d = d and e = e and f = f in
    {a; b; c; d; e; f}
end

let%expect_test "find" =
  let config =
    Yaml.of_string_exn {|
a: 1
b: "yo"
c: 3.3
d: 10
e: "yoooo"
f: 33.33
|}
  in
  let t = Term.eval Config.x ~config in
  t |> [%sexp_of: Config.t Or_error.t] |> print_s ;
  [%expect {|
      (Ok ((a 1) (b yo) (c 3.3) (d 10) (e yoooo) (f 33.33))) |}]

let%expect_test "find" =
  let config =
    Yaml.of_string_exn {|
a: 1
b: "yo"
c: 3.3
d: 10
e: "yoooo"
f: 33.33
    |}
  in
  let t = Term.eval Config.y ~config in
  t |> [%sexp_of: Config.t Or_error.t] |> print_s ;
  [%expect {|
      (Ok ((a 1) (b yo) (c 3.3) (d 10) (e yoooo) (f 33.33))) |}]

let%expect_test "find" =
  let config =
    Yaml.of_string_exn
      {|
aa: 1
bb: "yo"
cc: 3.3
dd: 10
ee: "yoooo"
ff: 33.33
    |}
  in
  let t = Term.eval Config.y ~config in
  t |> [%sexp_of: Config.t Or_error.t] |> print_s ;
  [%expect
    {|
      (Error
       (("config error: a" "key a should have a value, but it did not")
        ("config error: b" "key b should have a value, but it did not")
        ("config error: c" "key c should have a value, but it did not")
        ("config error: d" "key d should have a value, but it did not")
        ("config error: e" "key e should have a value, but it did not")
        ("config error: f" "key f should have a value, but it did not"))) |}]

let%expect_test "find" =
  let config =
    Yaml.of_string_exn
      {|
a: 1
bb: "yo"
cc: 3.3
dd: 10
ee: "yoooo"
ff: 33.33
    |}
  in
  let t = Term.eval Config.y ~config in
  t |> [%sexp_of: Config.t Or_error.t] |> print_s ;
  [%expect
    {|
      (Error
       (("config error: b" "key b should have a value, but it did not")
        ("config error: c" "key c should have a value, but it did not")
        ("config error: d" "key d should have a value, but it did not")
        ("config error: e" "key e should have a value, but it did not")
        ("config error: f" "key f should have a value, but it did not"))) |}]

let%expect_test "find" =
  let config =
    Yaml.of_string_exn
      {|
a: 1
b: "yo"
cc: 3.3
dd: 10
ee: "yoooo"
ff: 33.33
    |}
  in
  let t = Term.eval Config.y ~config in
  t |> [%sexp_of: Config.t Or_error.t] |> print_s ;
  [%expect
    {|
      (Error
       (("config error: c" "key c should have a value, but it did not")
        ("config error: d" "key d should have a value, but it did not")
        ("config error: e" "key e should have a value, but it did not")
        ("config error: f" "key f should have a value, but it did not"))) |}]
