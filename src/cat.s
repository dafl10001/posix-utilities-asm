global _start

extern print
extern exit_succ
extern exit_err
extern print_raw
extern open
extern read

section .data
newline db 10

section .bss
buf resb 128
fd resq 1
argc resq 1
result resq 1

section .text

argument_error:
    call exit_err

_start:
    cmp qword [rsp], 2
    jl argument_error

    mov rax, [rsp]              ; Set argc
    mov [argc], rax

    xor rdi, rdi        ; set rdi to argv[1]
    mov rdi, [rsp+16]   ;

    mov rsi, 0          ; open(argv[1], "r")
    call open           ;

    mov [fd], rax

    .loop:
        lea rsi, buf        ; read(fd)
        mov rdi, [fd]       ;
        mov rdx, 128        ;
        call read           ;

        mov [result], rax

        lea rsi, buf        ; print(buf)
        mov rdx, [result]   ;
        call print_raw      ;

        mov rax, [result]

        test rax, rax
        jle .done

        jmp .loop

    .done:

    xor rsi, rsi

    lea rsi, newline    ; print newline
    mov rdx, 1          ;
    call print_raw      ;

    mov rax, 3          ; close(fd)
    mov rdi, [fd]       ;
    syscall             ;

    call exit_succ
