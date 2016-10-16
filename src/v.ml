open Util

type t = VI of int array | VF of float array

exception Type_error
exception Nyi_error
exception Dim_error

let of_ints xs = VI xs
let of_floats xs = VF xs

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

let add = lift (+) (+.)
let sub = lift (-) (-.)
let mult = lift ( * ) ( *. )
let div = lift (/) (/.)

let enum = function
  | VI [|x|] -> VI (Array.range 0 x)
  | VI _ -> raise Nyi_error (* TODO need multi dimensional arrays *)
  | VF _ -> raise Type_error

let rev = function
  | VI xs -> VI (Array.rev xs)
  | VF xs -> VF (Array.rev xs)

let neg = function
  | VI xs -> VI (Array.map (~-) xs)
  | VF xs -> VF (Array.map (~-.) xs)

let show =
  let print_arr show_elem =
    Array.map show_elem >> Array.to_list >> String.concat " " in
  function
  | VI xs -> print_arr string_of_int xs
  | VF xs -> print_arr string_of_float xs
