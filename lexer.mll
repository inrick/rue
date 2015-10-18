{
open Lexing
open Parsing

type token =
  | LPAR
  | RPAR
  | INT of int
  | EOF

exception Syntax_error of string

let next_line lexbuf =
  let pos = lexbuf.lex_curr_p in
  lexbuf.lex_curr_p <-
    { pos with
      pos_bol = lexbuf.lex_curr_pos;
      pos_lnum = pos.pos_lnum + 1 }
}

let digit = ['0'-'9']
let int = '-'? digit digit*

let ws = [' ' '\t']+
let nl = '\n' | '\r' | "\r\n"
let id = ['A'-'Z' 'a'-'z' '_']['A'-'Z' 'a'-'z' '_' '0'-'9']*

rule read = parse
  | ws { read lexbuf }
  | nl { next_line lexbuf; read lexbuf }
  | int { INT (int_of_string (lexeme lexbuf)) }
  | '(' { LPAR }
  | ')' { RPAR }
  | _ { raise (Syntax_error ("Unknown character:" ^ lexeme lexbuf)) }
  | eof { EOF }
