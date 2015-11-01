module P = Printf

let bin = "rue"
let version = 0.1
let usage exit_code =
  P.printf "%s version %F\n" bin version;
  exit exit_code

let () =
  match Sys.argv with
  | [|_; "-h"|] -> usage 0
  | _ -> usage 1
