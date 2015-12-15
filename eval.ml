open Ast
open Util

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

let neg = function
  | Int x -> Int (-x)
  | Array xs -> Array (List.map (fun x -> -x) xs)

let rec eval = function (* TODO rewrite with continuations *)
  | Lit x -> x
  | Unop (Flip, e) -> eval e
  | Unop (Enum, e) -> enum (eval e)
  | Unop (Minus, e) -> neg (eval e)
  | Unop (Rev, e) -> rev (eval e)
  | Binop (e1, Divide, e2) -> (eval e1) % (eval e2)
  | Binop (e1, Minus, e2) -> (eval e1) - (eval e2)
  | Binop (e1, Mult, e2) -> (eval e1) * (eval e2)
  | Binop (e1, Plus, e2) -> (eval e1) + (eval e2)
