open! Base
open Tiny_toml
open Stdio

let%expect_test "find gives an error if key is not present" =
  let a = Value.find ["a"; "b"] Converter.int in
  let config = Otoml.Parser.from_string {|
[y]
z = 1
|} in
  print_s @@ [%sexp_of: int Or_error.t] @@ Term.eval a ~config ;
  [%expect
    {|
    (Error
     ("config error: a -> b"
      ("Otoml__Common.Key_error(\"Failed to retrieve a value at a.b: field a not found\")"))) |}]

let%expect_test "find gives an error if nested key is not present" =
  let a = Value.find ["a"; "b"] Converter.int in
  let config = Otoml.Parser.from_string {|
[a]
z = 1
|} in
  print_s @@ [%sexp_of: int Or_error.t] @@ Term.eval a ~config ;
  [%expect
    {|
    (Error
     ("config error: a -> b"
      ("Otoml__Common.Key_error(\"Failed to retrieve a value at a.b: field b not found\")"))) |}]

let%expect_test "find gives an error if value is wrong type" =
  let a = Value.find ["a"; "b"] Converter.int in
  let config = Otoml.Parser.from_string {|
[a]
b = "apple"
|} in
  print_s @@ [%sexp_of: int Or_error.t] @@ Term.eval a ~config ;
  [%expect
    {|
    (Error
     ("config error: a -> b"
      ("Otoml__Common.Type_error(\"Unexpected TOML value type at key a.b: value must be an integer, found string\")"))) |}]

let%expect_test "find_opt returns Ok None if the key is missing" =
  let a = Value.find_opt ["a"; "b"] Converter.int in
  let config = Otoml.Parser.from_string {|
[y]
z = 1
|} in
  print_s @@ [%sexp_of: int option Or_error.t] @@ Term.eval a ~config ;
  [%expect {| (Ok ()) |}]

let%expect_test "find_opt returns Ok None if the nested key is missing" =
  let a = Value.find_opt ["a"; "b"] Converter.int in
  let config = Otoml.Parser.from_string {|
[a]
z = 1
|} in
  print_s @@ [%sexp_of: int option Or_error.t] @@ Term.eval a ~config ;
  [%expect {| (Ok ()) |}]

let%expect_test "find_opt returns Error if the value is the wrong type" =
  let a = Value.find_opt ["a"; "b"] Converter.int in
  let config = Otoml.Parser.from_string {|
[a]
b = "apple"
|} in
  print_s @@ [%sexp_of: int option Or_error.t] @@ Term.eval a ~config ;
  [%expect
    {|
    (Error
     ("Otoml__Common.Type_error(\"Unexpected TOML value type at key a.b: value must be an integer, found string\")")) |}]

let%expect_test "find_or returns (Ok default) if the key is missing" =
  let a = Value.find_or ~default:111 ["a"; "b"] Converter.int in
  let config = Otoml.Parser.from_string "z = 1" in
  print_s @@ [%sexp_of: int Or_error.t] @@ Term.eval a ~config ;
  [%expect {| (Ok 111) |}]

let%expect_test "find_or returns Error if the key is present, but the value is \
                 the wrong type" =
  let a = Value.find_or ~default:111 ["a"; "b"] Converter.int in
  let config = Otoml.Parser.from_string {|a.b = "apple"|} in
  print_s @@ [%sexp_of: int Or_error.t] @@ Term.eval a ~config ;
  [%expect
    {|
    (Error
     ("config error: a -> b"
      ("Otoml__Common.Type_error(\"Unexpected TOML value type at key a.b: value must be an integer, found string\")"))) |}]

let%expect_test "find_or returns an error (and not the default value) if the \
                 parser returns an error" =
  let a = Value.find_or ~default:111 ["a"; "b"] Converter.Int.positive in
  let config = Otoml.Parser.from_string {|a.b = 0|} in
  print_s @@ [%sexp_of: int Or_error.t] @@ Term.eval a ~config ;
  [%expect
    {| (Error ("config error: a -> b" "expected an int > 0, but got 0")) |}]

let%expect_test "you shouldn't have an accessor that returns a result" =
  let acc = Otoml.get_result (Otoml.get_integer ~strict:true) in
  let parser = Parser.return in
  let conv = (acc, parser) in
  let a = Value.find ["a"] conv in
  let config = Otoml.Parser.from_string {|a = "yo"|} in
  let y = Term.eval a ~config in
  print_s @@ [%sexp_of: (int, string) Result.t Or_error.t] y ;
  [%expect {| (Ok (Error "value must be an integer, found string")) |}]

let%expect_test "you shouldn'd have an accessor that returns an Or_error.t" =
  let acc otoml =
    Or_error.try_with (fun () -> Otoml.get_integer ~strict:true otoml)
  in
  let parser = Parser.return in
  let conv = (acc, parser) in
  let a = Value.find ["a"] conv in
  let config = Otoml.Parser.from_string {|a = "yo"|} in
  let y = Term.eval a ~config in
  print_s @@ [%sexp_of: int Or_error.t Or_error.t] y ;
  [%expect
    {|
    (Ok
     (Error
      ("Otoml__Common.Type_error(\"value must be an integer, found string\")"))) |}]

let%expect_test "if you have an accessor that returns an Or_error, you must \
                 manually join them. Yuck!" =
  let acc otoml =
    Or_error.try_with (fun () -> Otoml.get_integer ~strict:true otoml)
  in
  let parser = Parser.return in
  let conv = (acc, parser) in
  let a = Value.find ["a"] conv in
  let config = Otoml.Parser.from_string {|a = "yo"|} in
  let y = Term.eval a ~config |> Or_error.join in
  print_s @@ [%sexp_of: int Or_error.t] y ;
  [%expect
    {|
    (Error
     ("Otoml__Common.Type_error(\"value must be an integer, found string\")")) |}]

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
  let otoml =
    Otoml.Parser.from_string
      {|
a = 1
b = "yo"
c = 3.3
d = 10
e = "yoooo"
f = 33.33
|}
  in
  let t = Term.eval Config.x ~config:otoml in
  t |> [%sexp_of: Config.t Or_error.t] |> print_s ;
  [%expect {|
      (Ok ((a 1) (b yo) (c 3.3) (d 10) (e yoooo) (f 33.33))) |}]

let%expect_test "find" =
  let otoml =
    Otoml.Parser.from_string
      {|
a = 1
b = "yo"
c = 3.3
d = 10
e = "yoooo"
f = 33.33
    |}
  in
  let t = Term.eval Config.y ~config:otoml in
  t |> [%sexp_of: Config.t Or_error.t] |> print_s ;
  [%expect {|
      (Ok ((a 1) (b yo) (c 3.3) (d 10) (e yoooo) (f 33.33))) |}]

let%expect_test "find" =
  let otoml =
    Otoml.Parser.from_string
      {|
aa = 1
bb = "yo"
cc = 3.3
dd = 10
ee = "yoooo"
ff = 33.33
    |}
  in
  let t = Term.eval Config.y ~config:otoml in
  t |> [%sexp_of: Config.t Or_error.t] |> print_s ;
  [%expect
    {|
      (Error
       (("config error: a"
         ("Otoml__Common.Key_error(\"Failed to retrieve a value at a: field a not found\")"))
        ("config error: b"
         ("Otoml__Common.Key_error(\"Failed to retrieve a value at b: field b not found\")"))
        ("config error: c"
         ("Otoml__Common.Key_error(\"Failed to retrieve a value at c: field c not found\")"))
        ("config error: d"
         ("Otoml__Common.Key_error(\"Failed to retrieve a value at d: field d not found\")"))
        ("config error: e"
         ("Otoml__Common.Key_error(\"Failed to retrieve a value at e: field e not found\")"))
        ("config error: f"
         ("Otoml__Common.Key_error(\"Failed to retrieve a value at f: field f not found\")")))) |}]

let%expect_test "find" =
  let otoml =
    Otoml.Parser.from_string
      {|
a = 1
bb = "yo"
cc = 3.3
dd = 10
ee = "yoooo"
ff = 33.33
    |}
  in
  let t = Term.eval Config.y ~config:otoml in
  t |> [%sexp_of: Config.t Or_error.t] |> print_s ;
  [%expect
    {|
      (Error
       (("config error: b"
         ("Otoml__Common.Key_error(\"Failed to retrieve a value at b: field b not found\")"))
        ("config error: c"
         ("Otoml__Common.Key_error(\"Failed to retrieve a value at c: field c not found\")"))
        ("config error: d"
         ("Otoml__Common.Key_error(\"Failed to retrieve a value at d: field d not found\")"))
        ("config error: e"
         ("Otoml__Common.Key_error(\"Failed to retrieve a value at e: field e not found\")"))
        ("config error: f"
         ("Otoml__Common.Key_error(\"Failed to retrieve a value at f: field f not found\")")))) |}]

let%expect_test "find" =
  let otoml =
    Otoml.Parser.from_string
      {|
a = 1
b = "yo"
cc = 3.3
dd = 10
ee = "yoooo"
ff = 33.33
    |}
  in
  let t = Term.eval Config.y ~config:otoml in
  t |> [%sexp_of: Config.t Or_error.t] |> print_s ;
  [%expect
    {|
      (Error
       (("config error: c"
         ("Otoml__Common.Key_error(\"Failed to retrieve a value at c: field c not found\")"))
        ("config error: d"
         ("Otoml__Common.Key_error(\"Failed to retrieve a value at d: field d not found\")"))
        ("config error: e"
         ("Otoml__Common.Key_error(\"Failed to retrieve a value at e: field e not found\")"))
        ("config error: f"
         ("Otoml__Common.Key_error(\"Failed to retrieve a value at f: field f not found\")")))) |}]
