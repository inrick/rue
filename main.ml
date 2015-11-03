open Util
module P = Printf

let bin = "rue"
let version = 0.1
let usage exit_code =
  P.printf "%s version %F\n" bin version;
  exit exit_code

let lex_and_print =
  Lexing.from_channel
    >> Lexer.tokens
    >> List.map Lexer.to_string
    >> String.concat " "
    >> print_endline

let () =
  match Sys.argv with
  | [|_; "-h"|] -> usage 0
  | _ -> lex_and_print stdin
