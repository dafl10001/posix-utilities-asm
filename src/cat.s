global _start

extern print
extern exit_succ
extern exit_err
extern print_raw
extern open
extern read

section .data
filename db "src/utilities.s", 0
newline db 10

section .bss
buf resb 128
fd resq 1
result resq 1

section .text

_start:
    lea rdi, filename   ; open("test.txt", "r")
    mov rsi, 0          ;
    call open           ;

    mov [fd], rax

    .loop:
        lea rsi, buf        ; read()
        mov rdi, [fd]       ;
        mov rdx, 128        ;
        call read           ;

        mov [result], rax

        lea rsi, buf
        call print          ; print()

        cmp qword [result], 0
        jnz .loop

    xor rsi, rsi

    lea rsi, newline    ; print newline
    mov rdx, 1
    call print_raw

    call exit_succ
