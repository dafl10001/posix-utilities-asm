global _start

extern print
extern exit_succ
extern exit_err
extern getdents64
extern list_dir
extern sort_lines

section .bss
textbuf resb 4096
filename resb 512

pointer resq 1

section .text
error:
    call exit_err

dot_name:
    mov byte [filename], '.'
    mov byte [filename+1], 0
    lea rdi, [filename]      ; rdi points to our buffer
    jmp _start.resume

set_name:
    mov rdi, [rsp + 16]
    jmp _start.resume

_start:
    mov rax, [rsp]           ; Check argc
    cmp rax, 2
    jb dot_name
    jmp set_name

    .resume:
    mov rsi, textbuf
    mov rdx, 1023
    call list_dir

    cmp rax, 0          ; Jump on error
    jb error            ;

    mov byte [textbuf+1023], 0

    lea rdi, textbuf    ; sort()
    call sort_lines     ;

    lea rsi, textbuf    ; print()
    call print          ;

    call exit_succ      ; exit

section .note.GNU-stack noalloc noexec nowrite progbits
