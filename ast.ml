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

module String = struct
  let rec of_lit = function
    | Int d -> string_of_int d
    | Array xs ->
        List.map string_of_int xs
        |> String.concat " "

  let of_unop = function
    | Enum -> "!"
    | Flip -> "+"
    | Rev -> "|"

  let of_binop = function
    | Divide -> "%"
    | Mult -> "*"
    | Minus -> "-"
    | Plus -> "+"

  let rec of_expr = function
    | Lit x -> P.sprintf "Lit(%s)" (of_lit x)
    | Unop (op, e) -> P.sprintf "Unop(%s, %s)" (of_unop op) (of_expr e)
    | Binop (e1, op, e2) ->
        P.sprintf "Binop(%s, %s, %s)"
          (of_expr e1) (of_binop op) (of_expr e2)
end

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
