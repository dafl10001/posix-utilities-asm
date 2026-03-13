AS := nasm
LD := ld

.PHONY: clean love

build: clean
	$(AS) src/echo.s -f elf64
	$(AS) src/cat.s -f elf64
	$(AS) src/utilities.s -f elf64

	$(LD) src/echo.o src/utilities.o -o dist/echo
	$(LD) src/cat.o src/utilities.o -o dist/cat

clean:
	rm -f src/*.o
	rm -f dist/*



love:
	@echo "Not war"