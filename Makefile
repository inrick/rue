OCB_FLAGS :=
OCB := ocamlbuild $(OCB_FLAGS)

TARGET := main
BIN := rue

.PHONY: all
all: native

.PHONY: doc
doc:
	$(OCB) src/rue.docdir/index.html

.PHONY: clean
clean:
	$(OCB) -clean
	rm -f $(BIN)

.PHONY: native
native:
	$(OCB) $(TARGET).native
	cp -aL $(TARGET).native $(BIN)

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
	  inotifywait src/* && make; \
	done
