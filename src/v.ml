open Util

type elt = VI of int array | VF of float array
type t = {shape : int list; v : elt}

exception Domain_error
exception Type_error
exception Nyi_error
exception Dim_error

let of_array c xs =
  let len = Array.length xs in
  let shape = if len = 1 then [] else [len] in (* scalar is special *)
  {shape; v = c xs}

let of_ints = of_array (fun x -> VI x)
let of_floats = of_array (fun x -> VF x)

let compat_shape xs ys =
  if List.is_prefix_of xs ys then ys
  else if List.is_prefix_of ys xs then xs
  else raise Dim_error

let length = function
  | VI xs -> Array.length xs
  | VF xs -> Array.length xs

let unify x y = match x.v, y.v with
  | VI _, VI _ | VF _, VF _ -> x, y
  | VI xs, VF _ -> {x with v = VF (Array.map float_of_int xs)}, y
  | VF _, VI ys -> x, {y with v = VF (Array.map float_of_int ys)}

let lift opi opf x0 y0 =
  let shape = compat_shape x0.shape y0.shape in
  let x, y = unify x0 y0 in
  let xlen = length x.v in
  let ylen = length y.v in
  let len = max xlen ylen in
  let init op xs ys =
    Array.init len (fun i -> op xs.(i mod xlen) ys.(i mod ylen)) in
  match x.v, y.v with
  | VI xs, VI ys -> {shape; v = VI (init opi xs ys)}
  | VF xs, VF ys -> {shape; v = VF (init opf xs ys)}
  | VI _, VF _ | VF _, VI _ -> assert false (* unify makes this impossible *)

let add = lift (+) (+.)
let sub = lift (-) (-.)
let mult = lift ( * ) ( *. )
let div = lift (/) (/.)

let enum x0 = match x0.v with
  | VI [|x|] ->
      if x < 0 then raise Domain_error
      else {shape = [x]; v = VI (Array.range 0 x)}
  | VI _ -> raise Nyi_error (* TODO need multi dimensional arrays *)
  | VF _ -> raise Type_error

let rev x0 = match x0.v with
  | VI xs -> {x0 with v = VI (Array.rev xs)}
  | VF xs -> {x0 with v = VF (Array.rev xs)}

let neg x0 = match x0.v with
  | VI xs -> {x0 with v = VI (Array.map (~-) xs)}
  | VF xs -> {x0 with v = VF (Array.map (~-.) xs)}

let count x = match x.shape with
  | [] -> of_ints [|1|]
  | y::_ -> of_ints [|y|]

let take s x =
  if List.length s.shape > 1 then raise Dim_error;
  match s.v with
  | VF _ -> raise Type_error
  | VI shape ->
    let shape = Array.to_list shape in
    let xlen = length x.v in
    let len = List.fold_left ( * ) 1 shape in
    let create xs = Array.init len (fun i -> xs.(i mod xlen)) in
    let v = match x.v with
    | VI xs -> VI (create xs)
    | VF xs -> VF (create xs) in
    {shape; v}

let shape_of x = of_ints (Array.of_list x.shape)

(* TODO pretty print higher dimensional arrays *)
let show x =
  let print_arr show_elem =
    Array.map show_elem >> Array.to_list >> String.concat " " in
  match x.v with
  | VI xs -> print_arr string_of_int xs
  | VF xs -> print_arr string_of_float xs
