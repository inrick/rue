TARGET := src/main
BIN := rue

BCONTEXT := _build/default

.PHONY: all
all: native

.PHONY: doc
doc: native
	mkdir -p doc
	ocamldoc -html -d doc -I $(BCONTEXT)/src/ src/*.ml{,i}

.PHONY: clean
clean:
	-rm -rf _build
	-rm -rf doc
	-rm -f $(BIN)
	-rm -f $(BIN).bc

.PHONY: native
native:
	jbuilder build $(TARGET).exe
	cp -aL $(BCONTEXT)/$(TARGET).exe $(BIN)

.PHONY: byte
byte:
	jbuilder build $(TARGET).bc
	cp -aL $(BCONTEXT)/$(TARGET).bc $(BIN).bc

.PHONY: test
test:
	jbuilder runtest

.PHONY: watch
watch:
	while true; do \
	  inotifywait src/* && make; \
	done
