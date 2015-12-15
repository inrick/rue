%{ open Ast %}

%token LPAR
%token RPAR
%token <int> INT
%token <float> FLOAT
%token EXCL
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
  | list(INT) { ArrayI $1 }
  | nonempty_list(FLOAT) { ArrayF $1 }
  ;

expr:
  | expr2 { $1 }
  | PLUS e = expr { Unop (Flip, e) }
  | MINUS e = expr { Unop (Minus, e) }
  | EXCL e = expr { Unop (Enum, e) }
  | PIPE e = expr { Unop (Rev, e) }
  | e1 = expr2 PERCENT e2 = expr { Binop (e1, Divide, e2) }
  | e1 = expr2 MINUS e2 = expr { Binop (e1, Minus, e2) }
  | e1 = expr2 MULT e2 = expr { Binop (e1, Mult, e2) }
  | e1 = expr2 PLUS e2 = expr { Binop (e1, Plus, e2) }
  ;

expr2:
  | lit { Lit $1 }
  | LPAR expr RPAR { $2 }
  ;
