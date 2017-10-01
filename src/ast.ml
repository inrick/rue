open Util

type unop =
  | Count
  | Enum
  | Flip
  | Minus
  | Rev
  | Shape_of
  [@@deriving show {with_path = false}]

type binop =
  | Mult
  | Divide
  | Plus
  | Minus
  | Take
  [@@deriving show {with_path = false}]

type expr =
  | Lit of V.t [@printer fun fmt v -> fprintf fmt "Lit(%s)" (V.show v)]
  | Unop of unop * expr
  | Binop of expr * binop * expr
  [@@deriving show {with_path = false}]

let eval expr =
  let rec go x0 k = match x0 with
  | Lit x -> k x
  | Unop (Count, e) -> go e (V.count >> k)
  | Unop (Flip, e) -> go e k (* TODO *)
  | Unop (Enum, e) -> go e (V.enum >> k)
  | Unop (Minus, e) -> go e (V.neg >> k)
  | Unop (Rev, e) -> go e (V.rev >> k)
  | Unop (Shape_of, e) -> go e (V.shape_of >> k)
  | Binop (e1, Divide, e2) -> go e1 (fun x -> go e2 (fun y -> k (V.div x y)))
  | Binop (e1, Minus, e2) -> go e1 (fun x -> go e2 (fun y -> k (V.sub x y)))
  | Binop (e1, Mult, e2) -> go e1 (fun x -> go e2 (fun y -> k (V.mult x y)))
  | Binop (e1, Plus, e2) -> go e1 (fun x -> go e2 (fun y -> k (V.add x y)))
  | Binop (e1, Take, e2) -> go e1 (fun x -> go e2 (fun y -> k (V.take x y)))
  in
  go expr (fun x -> x)
