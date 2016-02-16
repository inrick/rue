open Ast
open Util

exception Type_error
exception Nyi_error
exception Dim_error

let unify x y = match x, y with
  | ArrayI _, ArrayI _ | ArrayF _, ArrayF _ -> x, y
  | ArrayI xs, ArrayF _ -> ArrayF (Array.map float_of_int xs), y
  | ArrayF _, ArrayI ys -> x, ArrayF (Array.map float_of_int ys)

let lift opi opf x0 y0 = match unify x0 y0 with
  | ArrayI [|x|], ArrayI ys -> ArrayI (Array.map (opi x) ys)
  | ArrayI xs, ArrayI [|y|] -> ArrayI (Array.map (flip opi y) xs)
  | ArrayI xs, ArrayI ys ->
      (try ArrayI (Array.map2 opi xs ys) with
       Invalid_argument _ -> raise Dim_error)
  | ArrayF [|x|], ArrayF ys -> ArrayF (Array.map (opf x) ys)
  | ArrayF xs, ArrayF [|y|] -> ArrayF (Array.map (flip opf y) xs)
  | ArrayF xs, ArrayF ys ->
      (try ArrayF (Array.map2 opf xs ys) with
       Invalid_argument _ -> raise Dim_error)
  | ArrayI _, ArrayF _ | ArrayF _, ArrayI _ ->
      assert false (* unify makes this impossible *)

let (+) = lift (+) (+.)
let (-) = lift (-) (-.)
let ( * ) = lift ( * ) ( *. )
let (%) = lift (/) (/.)

let enum = function
  | ArrayI [|x|] -> ArrayI (Array.range 0 x)
  | ArrayF [|x|] -> raise Type_error
  | ArrayI _ -> raise Nyi_error (* TODO need multi dimensional arrays *)
  | ArrayF _ -> raise Type_error

let rev = function
  | ArrayI xs -> ArrayI (Array.rev xs)
  | ArrayF xs -> ArrayF (Array.rev xs)

let neg = function
  | ArrayI xs -> ArrayI (Array.map (~-) xs)
  | ArrayF xs -> ArrayF (Array.map (~-.) xs)

let eval expr =
  let rec go x0 k = match x0 with
  | Lit x -> k x
  | Unop (Flip, e) -> go e k
  | Unop (Enum, e) -> go e (enum >> k)
  | Unop (Minus, e) -> go e (neg >> k)
  | Unop (Rev, e) -> go e (rev >> k)
  | Binop (e1, Divide, e2) -> go e1 (fun x -> go e2 (fun y -> k (x % y)))
  | Binop (e1, Minus, e2) -> go e1 (fun x -> go e2 (fun y -> k (x - y)))
  | Binop (e1, Mult, e2) -> go e1 (fun x -> go e2 (fun y -> k (x * y)))
  | Binop (e1, Plus, e2) -> go e1 (fun x -> go e2 (fun y -> k (x + y)))
  in
  go expr (fun x -> x)
