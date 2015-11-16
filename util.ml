let (>>) f g x = f x |> g

let flip f = fun x y -> f y x

let range i j =
  let rec go ns = function
    | k when k < i -> ns
    | k -> go (k :: ns) (k-1) in
  go [] (j-1)

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
