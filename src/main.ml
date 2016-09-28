let () =
  match Sys.argv with
  | [|_|] -> Repl.run ()
  | [|_; "-h"|] -> Version.usage 0
  | _ -> Version.usage 1
