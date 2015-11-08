open Util

type unop =
  | Enum
  | Flip

type binop =
  | Mult
  | Plus

type expr =
  | Int of int
  | Unop of unop * expr
  | Binop of expr * binop * expr

let string_of_unop = function
  | Enum -> "!"
  | Flip -> "+"

let string_of_binop = function
  | Mult -> "*"
  | Plus -> "+"

let rec to_string =
  let open Printf in
  function
  | Int d -> sprintf "Int(%d)" d
  | Unop (op, e) -> sprintf "Unop(%s, %s)" (string_of_unop op) (to_string e)
  | Binop (e1, op, e2) ->
      sprintf "Binop(%s, %s, %s)"
        (to_string e1) (string_of_binop op) (to_string e2)

let print = Option.maybe "no expression" to_string >> print_endline

let rec eval = function (* TODO rewrite with continuations *)
  | Int i -> i
  | Unop (Flip, e) -> eval e
  | Unop (Enum, e) -> List.fold_left (+) 0 (range 0 (eval e))
  | Binop (e1, Mult, e2) -> (eval e1) * (eval e2)
  | Binop (e1, Plus, e2) -> (eval e1) + (eval e2)
