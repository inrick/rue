open Printf

let bin = "rue"
let version = "0.1"
let about = sprintf "%s version %s" bin version
let usage exit_code =
  print_endline about;
  exit exit_code
