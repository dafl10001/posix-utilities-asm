global print
global exit_succ
global exit_err
global print_raw
global open
global read
global list_dir

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

close:
    ; Close file descriptor
    mov rax, 3      ; close()
    syscall         ;

    ret

; Input:  rdi = path string
;         rsi = buffer to fill
;         rdx = buffer size
; Output: rax = total bytes written to string
list_dir:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rsi        ; r12 = Base of user buffer
    mov r13, rdx        ; r13 = Total capacity
    mov r14, rsi        ; r14 = Write pointer

    mov rsi, 0x10000    ; O_DIRECTORY | O_RDONLY
    mov rax, 2          ; sys_open
    syscall
    test rax, rax
    js .error_exit
    mov rbx, rax        ; rbx = FD

    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    mov rax, 217        ; sys_getdents64
    syscall
    test rax, rax
    jle .close_and_exit
    
    mov r15, rax        ; r15 = bytes read from syscall
    xor rcx, rcx        ; rcx = current read offset

.parse_loop:
    ; Identify file type at (buffer + offset + 18)
    movzx r9, byte [r12 + rcx + 18] ; r9 = d_type
    
    ; Calculate address of d_name (offset 19)
    lea r8, [r12 + rcx + 19] 
    
.copy_name:
    mov al, [r8]
    test al, al
    jz .check_folder
    mov [r14], al
    inc r8
    inc r14
    jmp .copy_name

.check_folder:
    ; If d_type == 4 (DT_DIR), append '/'
    cmp r9, 4
    jne .add_newline
    mov byte [r14], '/'
    inc r14

.add_newline:
    mov byte [r14], 10  ; Newline
    inc r14

    ; Advance read offset using d_reclen (offset 16)
    movzx rax, word [r12 + rcx + 16]
    add rcx, rax
    cmp rcx, r15
    jl .parse_loop

    mov byte [r14], 0   ; Null terminate string
    mov rax, r14
    sub rax, r12        ; Return string length

.close_and_exit:
    mov rdi, rbx
    mov rax, 3          ; sys_close
    syscall

.error_exit:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

section .note.GNU-stack noalloc noexec nowrite progbits