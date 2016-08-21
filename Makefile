OCB_FLAGS := -tag bin_annot -use-menhir
OCB := ocamlbuild $(OCB_FLAGS)

TARGET := main

.PHONY: all
all: native

.PHONY: clean
clean:
	$(OCB) -clean

.PHONY: native
native:
	$(OCB) $(TARGET).native

.PHONY: byte
byte:
	$(OCB) $(TARGET).byte

.PHONY: profile
profile:
	$(OCB) -tag profile $(TARGET).native

.PHONY: debug
debug:
	$(OCB) -tag debug $(TARGET).byte

.PHONY: watch
watch:
	while true; do \
	  inotifywait $(SOURCES) && make; \
	done
