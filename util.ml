let (>>) f g x = f x |> g

let range i j =
  let rec go ns = function
    | k when k < i -> ns
    | k -> go (k :: ns) (k-1) in
  go [] j
