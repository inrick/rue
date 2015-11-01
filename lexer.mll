{
module L = Lexing

type token =
  | LPAR
  | RPAR
  | INT of int
  | EOF

exception Syntax_error of string
}

let digit = ['0'-'9']
let int = '-'? digit digit*

let ws = [' ' '\t']+
let nl = '\n' | '\r' | "\r\n"
let id = ['A'-'Z' 'a'-'z' '_']['A'-'Z' 'a'-'z' '_' '0'-'9']*

rule read = parse
  | ws { read lexbuf }
  | nl { L.new_line lexbuf; read lexbuf }
  | int { INT (int_of_string (L.lexeme lexbuf)) }
  | '(' { LPAR }
  | ')' { RPAR }
  | _ { raise (Syntax_error ("Unknown character:" ^ L.lexeme lexbuf)) }
  | eof { EOF }
