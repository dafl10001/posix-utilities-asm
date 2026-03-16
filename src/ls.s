global _start

extern print
extern exit_succ
extern exit_err
extern getdents64
extern sort_lines

section .bss
textbuf resb 4096
filename resb 512

pointer resq 1

section .text
; Input:  rdi = path string
;         rsi = buffer to fill
;         rdx = buffer size
; Output: rax = total bytes written to string
section .text.list_dir exec nowrite progbits
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
