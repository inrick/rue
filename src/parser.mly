%{ open Ast %}

%token LPAR
%token RPAR
%token <int> INT
%token <float> FLOAT
%token CIRCUMFLEX
%token EXCL
%token HASH
%token MINUS
%token MULT
%token PIPE
%token PLUS
%token PERCENT
%token EOF

%start <Ast.expr option> expropt
%%

expropt:
  | expr EOF { Some $1 }
  | EOF { None }
  ;

lit:
  | nonempty_list(INT) { V.of_ints (Array.of_list $1) }
  | nonempty_list(FLOAT) { V.of_floats (Array.of_list $1) }
  ;

expr:
  | expr2 { $1 }
  | PLUS e = expr { Unop (Flip, e) }
  | MINUS e = expr { Unop (Minus, e) }
  | EXCL e = expr { Unop (Enum, e) }
  | PIPE e = expr { Unop (Rev, e) }
  | HASH e = expr { Unop (Count, e) }
  | CIRCUMFLEX e = expr { Unop (Shape_of, e) }
  | e1 = expr2 PERCENT e2 = expr { Binop (e1, Divide, e2) }
  | e1 = expr2 MINUS e2 = expr { Binop (e1, Minus, e2) }
  | e1 = expr2 MULT e2 = expr { Binop (e1, Mult, e2) }
  | e1 = expr2 PLUS e2 = expr { Binop (e1, Plus, e2) }
  | e1 = expr2 HASH e2 = expr { Binop (e1, Take, e2) }
  ;

expr2:
  | lit { Lit $1 }
  | LPAR expr RPAR { $2 }
  ;
