global _start

section .text
_start:
    mov rax, 60
    mov rdi, 1
    syscall

section .note.GNU-stack noalloc noexec nowrite progbits