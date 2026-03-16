AS := nasm
LD := ld
CC := gcc

CCFLAGS := -nostdlib -fno-stack-protector -c
ASFLAGS := -f elf64

DIST_DIR := dist

AS_SRCS := $(filter-out src/utilities.s src/ls.s, $(wildcard src/*.s))
AS_BINS := $(patsubst src/%.s, $(DIST_DIR)/%, $(AS_SRCS))

C_BINS := $(DIST_DIR)/ls
UTILS := src/utilities.o

.PHONY: all clean love

all: $(DIST_DIR) $(AS_BINS) $(C_BINS)
	rm -f src/*.o

$(DIST_DIR)/ls: src/ls_c.o src/ls_asm.o $(UTILS)
	$(LD) $^ -o $@

src/ls_c.o: src/ls.c
	$(CC) $(CCFLAGS) $< -o $@

src/ls_asm.o: src/ls.s
	$(AS) $(ASFLAGS) $< -o $@

$(AS_BINS): $(DIST_DIR)/%: src/%.o $(UTILS)
	$(LD) $^ -o $@

%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@

$(DIST_DIR):
	mkdir -p $(DIST_DIR)

clean:
	rm -f src/*.o
	rm -f $(DIST_DIR)/*


love:
	@echo "Not war"