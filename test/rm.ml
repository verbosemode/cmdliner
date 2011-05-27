(* Example from the documentation, this code is in public domain. *)

(* Implementation of the command, we just print the args. *)

type prompt = Always | Once | Never
let prompt_str = function 
  | Always -> "always" | Once -> "once" | Never -> "never"

let rm prompt recurse files =
  Printf.printf "prompt = %s\nrecurse = %b\nfiles = %s\n"
    (prompt_str prompt) recurse (String.concat ", " files)

(* Command line interface *)

open Cmdliner;;

let files = Arg.(non_empty & pos_all file [] & info [] ~docv:"FILE")
let prompt =
  let always = Always, Arg.info ["i"] 
      ~doc:"Prompt before every removal." in
  let never = Never, Arg.info ["f"; "force"]
      ~doc:"Ignore nonexistent files and never prompt." in
  let once = Once, Arg.info ["I"]
      ~doc:"Prompt once before removing more than three files, or when
            removing recursively. Less intrusive than $(b,-i), while 
	    still giving protection against most mistakes." in
  Arg.(last & vflag_all [Always] [always; never; once])

let recursive = Arg.(value & flag & info ["r"; "R"; "recursive"] 
		     ~doc:"Remove directories and their contents recursively.")

let rm_t = Term.(pure rm $ prompt $ recursive $ files)
let info = Term.info "rm" ~version:"1.6.1" ~doc:"remove files or directories"
    ~man:
    [`S "DESCRIPTION";
     `P "rm removes each specified $(i,FILE). By default it does not remove
         directories, to also remove them and their contents, use the
         option $(b,--recursive) ($(b,-r) or $(b,-R)).";
     `P "To remove a file whose name starts with a `-', for example
         `-foo', use one of these commands:";
     `P "> rm -- -foo"; `Noblank;
     `P "> rm ./-foo";
     `P "rm removes symbolic links, not the files referenced by the links.";
     `S "BUGS"; `P "Report bugs to <hehey at example.org>.";
     `S "SEE ALSO"; `P "rmdir(1), unlink(2)"]

let () = match Term.eval info rm_t with `Error _ -> exit 1 | _ -> exit 0
