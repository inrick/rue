open Util
module P = Printf

type lit =
  | Int of int
  | Array of int list

type unop =
  | Enum
  | Flip
  | Rev

type binop =
  | Mult
  | Divide
  | Plus
  | Minus

type expr =
  | Lit of lit
  | Unop of unop * expr
  | Binop of expr * binop * expr

let rec string_of_lit = function
  | Int d -> P.sprintf "Int(%d)" d
  | Array xs ->
      List.map string_of_int xs
      |> String.concat " "
      |> P.sprintf "Array(%s)"

let string_of_unop = function
  | Enum -> "!"
  | Flip -> "+"
  | Rev -> "|"

let string_of_binop = function
  | Divide -> "%"
  | Mult -> "*"
  | Minus -> "-"
  | Plus -> "+"

let rec to_string = function
  | Lit x -> P.sprintf "Lit(%s)" (string_of_lit x)
  | Unop (op, e) -> P.sprintf "Unop(%s, %s)" (string_of_unop op) (to_string e)
  | Binop (e1, op, e2) ->
      P.sprintf "Binop(%s, %s, %s)"
        (to_string e1) (string_of_binop op) (to_string e2)

let print = Option.maybe "no expression" to_string >> print_endline

let rec normalize = function
  | Lit (Array [x]) -> Lit (Int x)
  | Lit _ as x -> x
  | Unop (op, e) -> Unop (op, normalize e)
  | Binop (e1, op, e2) -> Binop (normalize e1, op, normalize e2)

let lift op x0 y0 = match x0, y0 with
  | Int x, Int y -> Int (op x y)
  | Int x, Array ys -> Array (List.map (op x) ys)
  | Array xs, Int y -> Array (List.map (flip op y) xs)
  | Array xs, Array ys ->
      assert (List.length xs = List.length ys);
      Array (List.map2 op xs ys)

let (+) = lift (+)
let (-) = lift (-)
let ( * ) = lift ( * )
let (%) = lift (/)

let enum = function
  | Int x -> Array (range 0 x)
  | Array _ as xs -> xs (* TODO need multi dimensional arrays *)

let rev = function
  | Int _ as x -> x
  | Array xs -> Array (List.rev xs)

let rec eval = function (* TODO rewrite with continuations *)
  | Lit x -> x
  | Unop (Flip, e) -> eval e
  | Unop (Enum, e) -> enum (eval e)
  | Unop (Rev, e) -> rev (eval e)
  | Binop (e1, Divide, e2) -> (eval e1) % (eval e2)
  | Binop (e1, Minus, e2) -> (eval e1) - (eval e2)
  | Binop (e1, Mult, e2) -> (eval e1) * (eval e2)
  | Binop (e1, Plus, e2) -> (eval e1) + (eval e2)
