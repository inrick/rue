open Util

let eval = Repl.(parse_string >> eval)

let () =
  assert (eval "1+1 2 3" = "2 3 4");
  assert (eval "!5" = "0 1 2 3 4");
  assert (eval "8 5 3 2 1 7 9 + |!7" = "14 10 7 5 3 8 9");
  assert (eval "(1+!10)*|1+!10" = "10 18 24 28 30 30 28 24 18 10");
  assert (eval "900.%5*(1+!10)*|1+!10" =
    "18. 10. 7.5 6.42857142857 6. 6. 6.42857142857 7.5 10. 18.");
  assert (
    match eval "1 2 3+!4" with
    | exception Eval.Dim_error -> true
    | _ -> false
  );
  assert (
    match eval "!7." with
    | exception Eval.Type_error -> true
    | _ -> false
  );
