global print
global exit_succ
global exit_err
global print_raw
global open
global read

section .text
exit_succ:
    mov rax, 60
    mov rdi, 0
    syscall

exit_err:
    mov rax, 60
    mov rdi, 1
    syscall

print:
    ; prints the contents of rsi. Assumes the string rsi is pointing to is null-terminated
    push rax
    push rdi
    push rsi
    push rdx

    xor rdx, rdx

    .loop:                              ; Set rdx to the length of the null-terminated string
        inc rdx
        cmp byte [rsi+rdx], 0
        jnz .loop
        jmp .done

    .done:

    mov rax, 1                          ; print(rsi, len=rdx)
    mov rdi, 1                          ;
    syscall                             ;

    pop rdx
    pop rsi
    pop rdi
    pop rax

    ret

print_raw:
    ; Assumes pointer to the string in rsi with the length in rdx
    push rax
    push rdi

    mov rax, 1      ; print(rsi, len=rdx)
    mov rdi, 1      ;
    syscall         ;

    pop rax
    pop rdi

    ret

open:
    ; Assumes the file name in rdi and puts the output in rax.
    ; The mode in rsi should be 0 for READ, 1 for Write, 2 for Read/Write and 64 for create.
    ; Permissions should be put in rdx when creating a file.
    mov rax, 2      ; open(filename, mode)
    syscall         ;

    ret

read:
    ; Read rdx bytes of file descriptor in rdi into buffer in rsi.
    mov rax, 0      ; read()
    syscall         ;
    
    ret