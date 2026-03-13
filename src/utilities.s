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


getdents64:
    ; ---------------------------------------------------------
    ; list_dir: Reads directory entries into a buffer
    ; Inputs:
    ;   rdi - Pointer to directory path string (null-terminated)
    ;   rsi - Pointer to buffer to store entries
    ;   rdx - Size of buffer
    ; Returns:
    ;   rax - Number of bytes read, or negative on error
    ; ---------------------------------------------------------

    push rbx
    push rdi
    push rsi
    push rdx

    ; rax = 2 (open), rdi = path, rsi = O_RDONLY | O_DIRECTORY (0x10000)
    mov rsi, 0x10000    ; open() 
    call open           ;
    
    test rax, rax
    js .error           ; If rax < 0, open failed

    mov rbx, rax        ; Save FD in rbx

    ; rax = 217, rdi = fd, rsi = buf, rdx = buf_len
    pop rdx             ; Restore original rdx (len)    ; getdents64()
    pop rsi             ; Restore original rsi (buf)    ;
    mov rdi, rbx        ; Move FD to rdi                ;
    mov rax, 217        ; sys_getdents64                ;
    syscall

    push rax            ; Save result of getdents64

    mov rdi, rbx        ; close()
    call close          ;

    pop rax             ; Restore getdents64 result to return it
    jmp .done

    .error:
        ; Clean up stack if we errored out early
        pop rdx
        pop rsi
        pop rdi

    .done:
        pop rbx
        ret