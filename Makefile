OCAMLC := ocamlc
OCAMLC_OPTS := -warn-error +A -annot
OCAMLC_LINK :=

OCAMLOPT := ocamlopt
OCAMLOPT_OPTS := -warn-error +A -annot
OCAMLOPT_LINK :=

OCAMLLEX := ocamllex
OCAMLYACC := menhir

sources := ast.ml lexer.mll main.ml

ml_files := $(filter %.ml, $(sources:.mll=.ml))
cmo_files := $(ml_files:.ml=.cmo)
cmx_files := $(ml_files:.ml=.cmx)

result := rue

%.cmi: %.mli
	$(OCAMLC) -c $(OCAMLC_OPTS) $<

%.cmo: %.ml
	$(OCAMLC) -c $(OCAMLC_OPTS) $<

%.cmx: %.ml
	$(OCAMLOPT) -c $(OCAMLOPT_OPTS) $<

.PHONY: all
all: native

.PHONY: native
native: $(cmx_files)
	$(OCAMLOPT) -o $(result) $(OCAMLOPT_OPTS) $(OCAMLOPT_LINK) $(cmx_files)

.PHONY: bytecode
bytecode: $(cmo_files)
	$(OCAMLC) -o $(result) $(OCAMLC_OPTS) $(OCAMLC_LINK) $(cmo_files)

lexer.ml: lexer.mll
	$(OCAMLLEX) $<

.PHONY: clean
clean:
	rm -f *.cma *.cmxa *.cmo *.cmi *.annot *.cmx *.o *.a $(result)

.depend: $(sources)
	ocamldep $(sources) >.depend

ifneq ($(MAKECMDGOALS), clean)
  -include .depend
endif
