let bin = "rue"
let version = 0.1
let usage code =
  let open Printf in
  printf "%s version %F\n" bin version;
  exit code

let () =
  match Sys.argv with
  | [|_; "-h"|] -> usage 0
  | _ -> usage 1
