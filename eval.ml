open Ast
open Util

exception Type_error
exception Nyi_error
exception Dim_error

let lift opi opf x0 y0 = match x0, y0 with
  | Int x, Int y -> Int (opi x y)
  | Int x, ArrayI ys -> ArrayI (List.map (opi x) ys)
  | ArrayI xs, Int y -> ArrayI (List.map (flip opi y) xs)
  | ArrayI xs, ArrayI ys ->
      if List.length xs <> List.length ys then raise Dim_error;
      ArrayI (List.map2 opi xs ys)
  | Float x, Float y -> Float (opf x y)
  | Float x, ArrayF ys -> ArrayF (List.map (opf x) ys)
  | ArrayF xs, Float y -> ArrayF (List.map (flip opf y) xs)
  | ArrayF xs, ArrayF ys ->
      if List.length xs <> List.length ys then raise Dim_error;
      ArrayF (List.map2 opf xs ys)
  | Int x, Float y -> Float (opf (float_of_int x) y)
  | Float x, Int y -> Float (opf x (float_of_int y))
  | Int x, ArrayF ys -> ArrayF (List.map (opf (float_of_int x)) ys)
  | Float x, ArrayI ys -> ArrayF (List.map (float_of_int >> opf x) ys)
  | ArrayI xs, Float y -> ArrayF (List.map (float_of_int >> flip opf y) xs)
  | ArrayF xs, Int y -> ArrayF (List.map (flip opf (float_of_int y)) xs)
  | ArrayF xs, ArrayI ys ->
      if List.length xs <> List.length ys then raise Dim_error;
      ArrayF (List.map2 opf xs (List.map float_of_int ys))
  | ArrayI xs, ArrayF ys ->
      if List.length xs <> List.length ys then raise Dim_error;
      ArrayF (List.map2 opf (List.map float_of_int xs) ys)

let (+) = lift (+) (+.)
let (-) = lift (-) (-.)
let ( * ) = lift ( * ) ( *. )
let (%) = lift (/) (/.)

let enum = function
  | Int x -> ArrayI (List.range 0 x)
  | Float x -> raise Type_error
  | ArrayI _ -> raise Nyi_error (* TODO need multi dimensional arrays *)
  | ArrayF _ -> raise Type_error

let rev = function
  | Int _ as x -> x
  | Float _ as x -> x
  | ArrayI xs -> ArrayI (List.rev xs)
  | ArrayF xs -> ArrayF (List.rev xs)

let neg = function
  | Int x -> Int (-x)
  | Float x -> Float (-.x)
  | ArrayI xs -> ArrayI (List.map (fun x -> -x) xs)
  | ArrayF xs -> ArrayF (List.map (fun x -> -.x) xs)

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
