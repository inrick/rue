open Ast
open Util

exception Type_error
exception Nyi_error
exception Dim_error

let unify x y = match x, y with
  | VI _, VI _ | VF _, VF _ -> x, y
  | VI xs, VF _ -> VF (Array.map float_of_int xs), y
  | VF _, VI ys -> x, VF (Array.map float_of_int ys)

let lift opi opf x0 y0 = match unify x0 y0 with
  | VI [|x|], VI ys -> VI (Array.map (opi x) ys)
  | VI xs, VI [|y|] -> VI (Array.map (flip opi y) xs)
  | VI xs, VI ys ->
      (try VI (Array.map2 opi xs ys) with
       Invalid_argument _ -> raise Dim_error)
  | VF [|x|], VF ys -> VF (Array.map (opf x) ys)
  | VF xs, VF [|y|] -> VF (Array.map (flip opf y) xs)
  | VF xs, VF ys ->
      (try VF (Array.map2 opf xs ys) with
       Invalid_argument _ -> raise Dim_error)
  | VI _, VF _ | VF _, VI _ -> assert false (* unify makes this impossible *)

let (+) = lift (+) (+.)
let (-) = lift (-) (-.)
let ( * ) = lift ( * ) ( *. )
let (%) = lift (/) (/.)

let enum = function
  | VI [|x|] -> VI (Array.range 0 x)
  | VF [|x|] -> raise Type_error
  | VI _ -> raise Nyi_error (* TODO need multi dimensional arrays *)
  | VF _ -> raise Type_error

let rev = function
  | VI xs -> VI (Array.rev xs)
  | VF xs -> VF (Array.rev xs)

let neg = function
  | VI xs -> VI (Array.map (~-) xs)
  | VF xs -> VF (Array.map (~-.) xs)

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
