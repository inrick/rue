OCAMLC := ocamlc.opt
OCAMLC_OPTS := -warn-error +A -annot
OCAMLC_LINK :=

OCAMLOPT := ocamlopt.opt
OCAMLOPT_OPTS := -warn-error +A -annot
OCAMLOPT_LINK :=

OCAMLLEX := ocamllex
OCAMLYACC := menhir

SOURCES := util.ml parser.mly lexer.mll ast.ml eval.ml main.ml

RESULT := rue

MLSTMP1 := $(SOURCES:.mll=.ml)
MLSTMP2 := $(MLSTMP1:.mly=.ml)
MLS := $(filter %.ml, $(MLSTMP2))
OBJS := $(MLS:.ml=.cmo)
OBJSOPT := $(MLS:.ml=.cmx)

MLLS := $(filter %.mll, $(SOURCES))
MLYS := $(filter %.mly, $(SOURCES))

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

.PHONY: doc
doc: $(OBJS)
	mkdir -p doc
	ocamldoc -html -d doc $(MLS)

.PHONY: clean
clean:
	rm -fr doc
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

.PHONY: watch
watch:
	while true; do \
	  inotifywait $(SOURCES) && make; \
	done

.depend: $(MLS)
	ocamldep $(MLS) >.depend

ifneq ($(MAKECMDGOALS), clean)
  -include .depend
endif
