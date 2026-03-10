AS := nasm
LD := ld

build: clean
	$(AS) src/echo.s -f elf64
	$(AS) src/cat.s -f elf64
	$(AS) src/utilities.s -f elf64

	$(LD) src/echo.o src/utilities.o -o dist/echo
	$(LD) src/cat.o src/utilities.o -o dist/cat

.PHONY: clean
clean:
	rm -f src/*.o
	rm -f dist/*