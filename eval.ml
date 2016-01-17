open Ast
open Util

exception Type_error
exception Nyi_error
exception Dim_error

let lift opi opf x0 y0 = match x0, y0 with
  | Int x, Int y -> Int (opi x y)
  | Int x, ArrayI ys -> ArrayI (Array.map (opi x) ys)
  | ArrayI xs, Int y -> ArrayI (Array.map (flip opi y) xs)
  | ArrayI xs, ArrayI ys ->
      (try ArrayI (Array.map2 opi xs ys) with
       Invalid_argument _ -> raise Dim_error)
  | Float x, Float y -> Float (opf x y)
  | Float x, ArrayF ys -> ArrayF (Array.map (opf x) ys)
  | ArrayF xs, Float y -> ArrayF (Array.map (flip opf y) xs)
  | ArrayF xs, ArrayF ys ->
      (try ArrayF (Array.map2 opf xs ys) with
       Invalid_argument _ -> raise Dim_error)
  | Int x, Float y -> Float (opf (float_of_int x) y)
  | Float x, Int y -> Float (opf x (float_of_int y))
  | Int x, ArrayF ys -> ArrayF (Array.map (opf (float_of_int x)) ys)
  | Float x, ArrayI ys -> ArrayF (Array.map (float_of_int >> opf x) ys)
  | ArrayI xs, Float y -> ArrayF (Array.map (float_of_int >> flip opf y) xs)
  | ArrayF xs, Int y -> ArrayF (Array.map (flip opf (float_of_int y)) xs)
  | ArrayF xs, ArrayI ys ->
      (try ArrayF (Array.map2 opf xs (Array.map float_of_int ys)) with
       Invalid_argument _ -> raise Dim_error)
  | ArrayI xs, ArrayF ys ->
      (try ArrayF (Array.map2 opf (Array.map float_of_int xs) ys) with
       Invalid_argument _ -> raise Dim_error)

let (+) = lift (+) (+.)
let (-) = lift (-) (-.)
let ( * ) = lift ( * ) ( *. )
let (%) = lift (/) (/.)

let enum = function
  | Int x -> ArrayI (Array.range 0 x)
  | Float x -> raise Type_error
  | ArrayI _ -> raise Nyi_error (* TODO need multi dimensional arrays *)
  | ArrayF _ -> raise Type_error

let rev = function
  | Int _ | Float _ as x -> x
  | ArrayI xs -> ArrayI (Array.rev xs)
  | ArrayF xs -> ArrayF (Array.rev xs)

let neg = function
  | Int x -> Int (-x)
  | Float x -> Float (-.x)
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
