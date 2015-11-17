open Util
module P = Printf

let bin = "rue"
let version = 0.1
let version_str = P.sprintf "%s version %F" bin version
let usage exit_code =
  print_endline version_str;
  exit exit_code

let lex =
  Lexer.tokens
  >> List.map Lexer.to_string
  >> String.concat " "
let lex_ch = Lexing.from_channel >> lex
let lex_string = Lexing.from_string >> lex

let parse =
  Parser.expropt Lexer.read
  >> Option.map Ast.normalize

let parse_ch =
  Lexing.from_channel >> parse

let parse_string =
  Lexing.from_string >> parse

let eval_and_print = Ast.(
  Option.maybe (Int 0) eval
    >> String.of_lit
    >> print_endline)

let () =
  match Sys.argv with
  | [|_; "-h"|] -> usage 0
  | [|_; "lex"|] -> lex_ch stdin |> print_endline
  | [|_; "eval"|] -> parse_ch stdin |> eval_and_print
  | [|_; "parse"|] ->
      parse_ch stdin
      |> Option.map Ast.String.of_expr
      |> Option.iter print_endline
  | _ ->
      print_endline version_str;
      try
        while true do
          output_string stdout "> ";
          flush stdout;
          input_line stdin |> parse_string |> eval_and_print
        done
      with
      | End_of_file -> exit 0
