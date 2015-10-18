OCAMLC := ocamlc
OCAMLC_OPTS := -warn-error +A -annot
OCAMLC_LINK :=

OCAMLOPT := ocamlopt
OCAMLOPT_OPTS := -warn-error +A -annot
OCAMLOPT_LINK :=

OCAMLLEX := ocamllex
OCAMLYACC := menhir

SOURCES := ast.ml lexer.mll main.ml parser.mly

RESULT := rue

MLLS := $(filter %.mll, $(SOURCES))
MLYS := $(filter %.mly, $(SOURCES))
MLS := $(filter %.ml, $(SOURCES)) $(MLLS:.mll=.ml) $(MLYS:.mly=.ml)
OBJS := $(MLS:.ml=.cmo)
OBJSOPT := $(MLS:.ml=.cmx)

%.cmi: %.mli
	$(OCAMLC) -c $(OCAMLC_OPTS) $<

%.cmo: %.ml
	$(OCAMLC) -c $(OCAMLC_OPTS) $<

%.cmx: %.ml
	$(OCAMLOPT) -c $(OCAMLOPT_OPTS) $<

%.ml: %.mll
	$(OCAMLLEX) $<

%.ml: %.mly
	$(OCAMLYACC) $<

.PHONY: all
all: native

.PHONY: native
native: .depend $(OBJSOPT)
	$(OCAMLOPT) -o $(RESULT) $(OCAMLOPT_OPTS) $(OCAMLOPT_LINK) $(OBJSOPT)

.PHONY: bytecode
bytecode: .depend $(OBJS)
	$(OCAMLC) -o $(RESULT) $(OCAMLC_OPTS) $(OCAMLC_LINK) $(OBJS)

.PHONY: clean
clean:
	rm -f \
	  *.cma \
	  *.cmxa \
	  *.cmo \
	  *.cmi \
	  *.annot \
	  *.cmx \
	  *.o \
	  *.a \
	  .depend \
	  $(MLLS:.mll=.ml) \
	  $(MLYS:.mly=.ml) \
	  $(MLYS:.mly=.mli) \
	  $(RESULT)

.depend: $(MLS)
	ocamldep $(MLS) >.depend

ifneq ($(MAKECMDGOALS), clean)
  -include .depend
endif
