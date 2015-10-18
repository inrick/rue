%{ open Ast %}

%token LPAR
%token RPAR
%token <int> INT
%token EOF

%start <Ast.expr option> expropt
%%

expropt:
  | e = expr { Some e }
  | EOF { None }
  ;

expr:
  | i = INT { Int i }
  ;
