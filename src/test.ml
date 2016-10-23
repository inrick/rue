open Util

let eval = Repl.(parse_string >> eval)

let assert_raise exn expr =
  assert (match expr () with
  | exception x when x = exn -> true
  | exception _ -> false
  | _ -> false)

let () =
  assert (eval "1+1 2 3" = "2 3 4");
  assert (eval "!5" = "0 1 2 3 4");
  assert (eval "8 5 3 2 1 7 9 + |!7" = "14 10 7 5 3 8 9");
  assert (eval "(1+!10)*|1+!10" = "10 18 24 28 30 30 28 24 18 10");
  assert (eval "900.%5*(1+!10)*|1+!10" =
    "18. 10. 7.5 6.42857142857 6. 6. 6.42857142857 7.5 10. 18.");
  assert_raise V.Dim_error (fun () -> eval "1 2 3+!4");
  assert_raise V.Type_error (fun () -> eval "!7.");
  assert (eval "1 2 3+3 2 3#6" = "7 8 9 7 8 9 7 8 9 7 8 9 7 8 9 7 8 9");
  assert (eval "(2 2#5 4 3 2)+2 2 3#1" = "6 5 4 3 6 5 4 3 6 5 4 3");
  assert (eval "(3#2)#7" = "7 7 7 7 7 7 7 7");
  assert_raise V.Dim_error (fun () -> eval "1 1 1+1 1 3#5");
  assert_raise V.Dim_error (fun () -> eval "(5 5#1)#1");
  assert_raise V.Dim_error (fun () -> eval "(1 1#1)#1");
  assert_raise V.Type_error (fun () -> eval "5. 7.#1");
  assert (eval "^7 8 2#1 2" = "7 8 2");
  assert (eval "^1 2 3+3 2 3#6" = "3 2 3");
