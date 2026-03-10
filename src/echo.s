global _start

extern print
extern exit_succ
extern exit_err
extern print_raw

section .data
newline db 10, 0
space db " "

section .bss
argc resq 1

section .text

argument_error:
    call exit_err

_start:
    cmp qword [rsp], 2
    jl argument_error

    mov rax, [rsp]                      ; Set argc
    mov [argc], rax

    xor r8, r8

    inc r8                              ; Start at argv[1]

    .loop:
        mov rsi, [rsp + 8 + r8 * 8]     ; print(argv)
        call print                      ;

        mov rsi, space
        mov rdx, 1
        call print_raw

        inc r8
        cmp [argc], r8

        jnz .loop
    .done:

    lea rsi, newline                    ; print("\n")
    call print                          ;

    call exit_succ
