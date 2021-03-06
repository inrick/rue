open Util

let lex = Lexer.tokens >> List.map Lexer.to_string >> String.concat " "
let lex_ch = Lexing.from_channel >> lex
let lex_string = Lexing.from_string >> lex

let parse = Parser.expropt Lexer.read
let parse_ch = Lexing.from_channel >> parse
let parse_string = Lexing.from_string >> parse

let eval = Option.map Ast.eval >> Option.maybe "" V.show

let run () =
  (* input handlers *)
  let eval_input = parse_string >> eval in
  let lex_input = lex_string in
  let parse_input = parse_string >> Option.maybe "" Ast.show_expr in
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
      | V.Domain_error -> "Domain error"
      | V.Type_error -> "Type error"
      | V.Nyi_error -> "Not yet implemented"
      | V.Dim_error -> "Dimension mismatch"
  in
  print_endline Version.about;
  print_endline "\\h for help";
  Sys.catch_break true; (* raise Sys.Break on ^C *)
  while true do
    try
      print_string "> ";
      read_line () |> hook |> print_endline
    with
    | Sys.Break -> print_endline "Interrupted (^D to exit)"
    | End_of_file -> exit 0
  done
