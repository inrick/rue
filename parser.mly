%{ open Ast %}

%token LPAR
%token RPAR
%token <int> INT
%token EXCL
%token PLUS
%token MULT
%token EOF

%start <Ast.expr option> expropt
%%

expropt:
  | expr EOF { Some $1 }
  | EOF { None }
  ;

lit:
  | INT { Int $1 }
  ;

expr:
  | expr2 { $1 }
  | PLUS e = expr { Unop (Flip, e) }
  | EXCL e = expr { Unop (Enum, e) }
  | e1 = expr2 MULT e2 = expr { Binop (e1, Mult, e2) }
  | e1 = expr2 PLUS e2 = expr { Binop (e1, Plus, e2) }
  ;

expr2:
  | lit { $1 }
  | LPAR expr RPAR { $2 }
  ;
