AS := nasm
LD := ld
CC := gcc

CCFLAGS := -nostdlib -fno-stack-protector -c
ASFLAGS := -f elf64
LDFLAGS := --no-warn-rwx-segments --gc-sections -s -n

DIST_DIR := dist

# Get all potential assembly bins
ALL_AS_SRCS := $(wildcard src/*.s)
# Identify the ones we want to treat specially
SPECIAL_SRCS := src/utilities.s src/ls.s src/true.s

# AS_BINS should ONLY be the "generic" ones (cat, echo, etc.)
AS_SRCS := $(filter-out $(SPECIAL_SRCS), $(ALL_AS_SRCS))
AS_BINS := $(patsubst src/%.s, $(DIST_DIR)/%, $(AS_SRCS))

# Explicitly define our special targets
TRUE_BIN := $(DIST_DIR)/true
LS_BIN   := $(DIST_DIR)/ls
UTILS    := src/utilities.o

.PHONY: all clean love

all: $(DIST_DIR) $(AS_BINS) $(LS_BIN) $(TRUE_BIN)
	rm -f src/*.o

# Special Rule: true (The "diet" version)
$(TRUE_BIN): src/true.o
	$(LD) $(LDFLAGS) $< -o $@
	strip --strip-unneeded $@

# Special Rule: ls (C + ASM mix)
$(LS_BIN): src/ls_c.o src/ls_asm.o $(UTILS)
	$(LD) $(LDFLAGS) $^ -o $@
	strip --strip-unneeded $@

# Generic Rule: For everything else (cat, echo, etc.)
$(AS_BINS): $(DIST_DIR)/%: src/%.o $(UTILS)
	$(LD) $(LDFLAGS) $^ -o $@
	strip --strip-unneeded $@

# Pattern rules for objects
src/ls_c.o: src/ls.c
	$(CC) $(CCFLAGS) $< -o $@

src/ls_asm.o: src/ls.s
	$(AS) $(ASFLAGS) $< -o $@

%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@

$(DIST_DIR):
	mkdir -p $(DIST_DIR)

clean:
	rm -f src/*.o
	rm -f $(DIST_DIR)/*

love:
	@echo "Not war"