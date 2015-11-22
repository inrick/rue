{
open Parser
module L = Lexing

exception Syntax_error of string

let to_string =
  let open Printf in
  function
  | LPAR -> "LPAR"
  | RPAR -> "RPAR"
  | INT d -> sprintf "INT(%d)" d
  | EXCL -> "EXCL"
  | MINUS -> "MINUS"
  | MULT -> "MULT"
  | PERCENT -> "PERCENT"
  | PIPE -> "PIPE"
  | PLUS -> "PLUS"
  | EOF -> "EOF"
}

let digit = ['0'-'9']
let int = digit digit*

let ws = [' ' '\t']+
let nl = '\n' | '\r' | "\r\n"
let id = ['A'-'Z' 'a'-'z' '_']['A'-'Z' 'a'-'z' '_' '0'-'9']*

rule read = parse
  | ws { read lexbuf }
  | nl { L.new_line lexbuf; read lexbuf }
  | int { INT (int_of_string (L.lexeme lexbuf)) }
  | '(' { LPAR }
  | ')' { RPAR }
  | '!' { EXCL }
  | '-' { MINUS }
  | '*' { MULT }
  | '|' { PIPE }
  | '+' { PLUS }
  | '%' { PERCENT }
  | _ { raise (Syntax_error ("Unknown character: " ^ L.lexeme lexbuf)) }
  | eof { EOF }

{
let tokens lexbuf =
  let rec go xs = function
    | EOF -> List.rev (EOF :: xs)
    | x -> go (x :: xs) (read lexbuf) in
  go [] (read lexbuf)
}
