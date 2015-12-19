let (>>) f g x = f x |> g

let flip f = fun x y -> f y x

module Array = struct
  include Array

  let map2 f xs ys =
    let len = length xs in
    if len <> length ys then
      raise (Invalid_argument "Array.map2");
    init len (fun i -> f xs.(i) ys.(i))

  let range i j = init (j-i) (fun k -> k+i)

  let rev xs =
    let len = length xs in
    init len (fun i -> xs.(len-1-i))
end

module List = struct
  include List

  let range i j =
    let rec go ns = function
      | k when k < i -> ns
      | k -> go (k :: ns) (k-1) in
    go [] (j-1)
end

module Option = struct
  type 'a t = 'a option

  let map f = function
    | Some x -> Some (f x)
    | None -> None

  let iter f = function
    | Some x -> f x
    | None -> ()

  let maybe default f = function
    | Some x -> f x
    | None -> default

  let (>>=) x f = match x with
    | Some y -> f y
    | None -> None

  let return x = Some x
end
