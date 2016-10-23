rue
===

Initial fragments of K inspired interpreter. Currently only supports scalars
and one dimensional arrays with a limited set of operators: `-+*%|!#^`.

Need a multi dimensional array representation before progress can be made.

Examples
========

```
$ rlwrap ./rue
rue version 0.1
\h for help
> !10
0 1 2 3 4 5 6 7 8 9
> 1+!10
1 2 3 4 5 6 7 8 9 10
> |1+!10
10 9 8 7 6 5 4 3 2 1
> (1+!10)*|1+!10
10 18 24 28 30 30 28 24 18 10
> 5*(1+!10)*|1+!10
50 90 120 140 150 150 140 120 90 50
> 900.%5*(1+!10)*|1+!10
18. 10. 7.5 6.42857142857 6. 6. 6.42857142857 7.5 10. 18.
> \h
Known commands: \e, \l, \p, \h
> \l
Print lexemes
> 900.%5*(1+!10)*|1+!10
FLOAT(900.000000) PERCENT INT(5) MULT LPAR INT(1) PLUS EXCL INT(10) RPAR MULT PIPE INT(1) PLUS EXCL INT(10) EOF
> \p
Print AST
> 900.%5*(1+!10)*|1+!10
Binop(Lit(900.), %, Binop(Lit(5), *, Binop(Binop(Lit(1), +, Unop(!, Lit(10))), *, Unop(|, Binop(Lit(1), +, Unop(!, Lit(10)))))))
> \e
Print evaluated expr
> 900.%5*(1+!10)*|1+!10
18. 10. 7.5 6.42857142857 6. 6. 6.42857142857 7.5 10. 18.
> (3#2)#7
7 7 7 7 7 7 7 7
> ^(3#2)#7
2 2 2
```

Dependencies
============

Requires `menhir`.
