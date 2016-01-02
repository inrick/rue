open Util
module P = Printf

let bin = "rue"
let version = 0.1
let version_str = P.sprintf "%s version %F" bin version
let usage exit_code =
  print_endline version_str;
  exit exit_code

let lex = Lexer.tokens >> List.map Lexer.to_string >> String.concat " "
let lex_ch = Lexing.from_channel >> lex
let lex_string = Lexing.from_string >> lex

let parse = Parser.expropt Lexer.read >> Option.map Ast.normalize
let parse_ch = Lexing.from_channel >> parse
let parse_string = Lexing.from_string >> parse

let eval = Option.maybe (Ast.Int 0) Eval.eval >> Ast.String.of_lit

let repl () =
  (* input handlers *)
  let eval_input = parse_string >> eval in
  let lex_input = lex_string in
  let parse_input = parse_string >> Option.maybe "" Ast.String.of_expr in
  let handler = ref eval_input in
  let hook s =
    if String.length s > 0 && s.[0] = '\\' then
      match s with
      | "\\e" -> handler := eval_input; "Print evaluated expr"
      | "\\l" -> handler := lex_input; "Print lexemes"
      | "\\p" -> handler := parse_input; "Print AST"
      | "\\h" -> "Known commands: \\e, \\l, \\p, \\h"
      | _ -> "Unknown command: " ^ s
    else
      try !handler s with
      | Lexer.Syntax_error err -> err
      | Parser.Error -> "Parse error"
      | Division_by_zero -> "Division by zero"
      | Stack_overflow -> "Stack overflow"
      | Eval.Type_error -> "Type error"
      | Eval.Nyi_error -> "Not yet implemented"
      | Eval.Dim_error -> "Dimension mismatch"
  in
  print_endline version_str;
  print_endline "\\h for help";
  try
    while true do
      print_string "> ";
      read_line () |> hook |> print_endline
    done
  with End_of_file -> exit 0

let () =
  match Sys.argv with
  | [|_|] -> repl ()
  | [|_; "-h"|] -> usage 0
  | [|_; "lex"|] -> lex_ch stdin |> print_endline
  | [|_; "eval"|] -> parse_ch stdin |> eval |> print_endline
  | [|_; "parse"|] ->
      parse_ch stdin
        |> Option.map Ast.String.of_expr
        |> Option.iter print_endline
  | _ -> usage 1
