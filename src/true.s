global _start

section .text
_start:
    mov rax, 60
    xor rdi, rdi
    syscall

section .note.GNU-stack noalloc noexec nowrite progbits