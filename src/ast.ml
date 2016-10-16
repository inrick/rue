open Util

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
  | Lit of V.t
  | Unop of unop * expr
  | Binop of expr * binop * expr

module String = struct
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

  let rec of_expr =
    let open Printf in
    function
    | Lit x -> sprintf "Lit(%s)" (V.show x)
    | Unop (op, e) -> sprintf "Unop(%s, %s)" (of_unop op) (of_expr e)
    | Binop (e1, op, e2) ->
        sprintf "Binop(%s, %s, %s)" (of_expr e1) (of_binop op) (of_expr e2)
end

let eval expr =
  let rec go x0 k = match x0 with
  | Lit x -> k x
  | Unop (Flip, e) -> go e k
  | Unop (Enum, e) -> go e (V.enum >> k)
  | Unop (Minus, e) -> go e (V.neg >> k)
  | Unop (Rev, e) -> go e (V.rev >> k)
  | Binop (e1, Divide, e2) -> go e1 (fun x -> go e2 (fun y -> k (V.div x y)))
  | Binop (e1, Minus, e2) -> go e1 (fun x -> go e2 (fun y -> k (V.sub x y)))
  | Binop (e1, Mult, e2) -> go e1 (fun x -> go e2 (fun y -> k (V.mult x y)))
  | Binop (e1, Plus, e2) -> go e1 (fun x -> go e2 (fun y -> k (V.add x y)))
  in
  go expr (fun x -> x)
