AS := nasm
ASFLAGS := -f elf64
LD := ld

BINS = dist/echo dist/cat dist/ls
UTILS = src/utilities.o

.PHONY: all clean love

all: $(BINS)

dist/cat: src/cat.o $(UTILS) | dist
	$(LD) $^ -o $@

dist/echo: src/echo.o $(UTILS) | dist
	$(LD) $^ -o $@

%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@

dist:
	mkdir -p dist/

clean:
	rm -f src/*.o
	rm -f dist/*



love:
	@echo "Not war"