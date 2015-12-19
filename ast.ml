module P = Printf

type lit =
  | Int of int
  | Float of float
  | ArrayI of int array
  | ArrayF of float array

type unop =
  | Enum
  | Flip
  | Minus
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
    | Float f -> string_of_float f
    | ArrayI xs ->
        Array.to_list xs |> List.map string_of_int |> String.concat " "
    | ArrayF xs ->
        Array.to_list xs |> List.map string_of_float |> String.concat " "

  let of_unop = function
    | Enum -> "!"
    | Flip -> "+"
    | Minus -> "-"
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
  | Lit (ArrayI [|x|]) -> Lit (Int x)
  | Lit (ArrayF [|x|]) -> Lit (Float x)
  | Lit _ as x -> x
  | Unop (op, e) -> Unop (op, normalize e)
  | Binop (e1, op, e2) -> Binop (normalize e1, op, normalize e2)
