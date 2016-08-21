module P = Printf

type lit =
  | VI of int array
  | VF of float array

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
    | VI xs ->
        xs |> Array.map string_of_int |> Array.to_list |> String.concat " "
    | VF xs ->
        xs |> Array.map string_of_float |> Array.to_list |> String.concat " "

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
