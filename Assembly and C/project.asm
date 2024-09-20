
section .data
prompt  db 'Enter number: ', 0   ; null-terminated string for prompt
result  db 'The sum is: ', 0     ; null-terminated string for result
crlf    db 0x0D, 0x0A, 0         ; carriage return and line feed

section .bss
input_buffer resb 32     ; Buffer for user input, enough for 31 characters + null terminator
num1         resq 1      ; reserve space for num1
num2         resq 1      ; reserve space for num2
sum          resq 1      ; reserve space for sum

section .text
global _start

_start:
    ; Display prompt for num1
    mov rax, 0x1              ; sys_write syscall number
    mov rdi, 0x1              ; stdout
    mov rsi, prompt           ; address of prompt
    mov rdx, 14               ; length of prompt
    syscall

    ; Input num1
    mov rax, 0                ; sys_read syscall number
    mov rdi, 0                ; stdin
    lea rsi, [input_buffer]   ; buffer for num1
    mov rdx, 32               ; maximum number of bytes to read
    syscall
    call convert_string_to_int
    mov [num1], rax           ; store converted integer

    ; Display prompt for num2
    mov rax, 0x1              ; sys_write syscall number
    mov rdi, 0x1              ; stdout
    mov rsi, prompt           ; address of prompt
    mov rdx, 14               ; length of prompt
    syscall

    ; Input num2
    lea rsi, [input_buffer]   ; buffer for num2
    syscall
    call convert_string_to_int
    mov [num2], rax           ; store converted integer

    ; Add num1 and num2
    mov rax, [num1]
    add rax, [num2]           ; rax = num1 + num2
    mov [sum], rax            ; store the sum

    ; Display result prompt
    mov rax, 0x1              ; sys_write syscall number
    mov rdi, 0x1              ; stdout
    mov rsi, result           ; address of result prompt
    mov rdx, 14               ; length of result prompt
    syscall

    ; Display the sum
    mov rax, [sum]
    call display_number       ; display number in rax

    ; Newline
    mov rax, 0x1              ; sys_write syscall number
    mov rdi, 0x1              ; stdout
    mov rsi, crlf             ; carriage return and line feed
    mov rdx, 2                ; two characters
    syscall

    ; Exit program
    mov rax, 60               ; syscall number for exit
    xor rdi, rdi              ; status 0
    syscall

; Converts ASCII string in input_buffer to integer
convert_string_to_int:
    lea rsi, [input_buffer]   ; pointer to input buffer
    xor rax, rax              ; clear rax for the result
    xor rcx, rcx              ; clear rcx
    mov rcx, 10               ; decimal multiplier for positions

parse_loop:
    movzx rdx, byte [rsi]     ; load byte and zero-extend to 64-bit
    inc rsi                   ; increment buffer pointer
    sub rdx, '0'              ; convert ASCII to integer
    imul rax, rax, rcx        ; multiply current result by 10
    add rax, rdx              ; add new digit to result
    cmp byte [rsi], 0         ; check for null terminator
    jnz parse_loop            ; continue if not zero
    ret

; Display integer in RAX
display_number:
    mov rbp, rsp              ; save stack pointer
    sub rsp, 32               ; reserve space for string conversion
    mov rcx, 10               ; decimal base

    ; Convert integer to string in reverse order
    mov rdi, rsp              ; point to the conversion buffer
    test rax, rax             ; check if number is zero
    jnz convert_positive
    mov byte [rdi], '0'       ; handle zero explicitly
    jmp short print_number

convert_positive:
    cmp rax, 0                ; check if the number is positive
    jge converting            ; skip if it's non-negative
    neg rax                   ; negate to make positive if negative

converting:
    xor rcx, rcx              ; clear RCX for counting characters
convert_loop:
    xor rdx, rdx              ; clear RDX for 'div' operation
    div rcx                   ; divide RAX by 10, remainder in RDX
    add dl, '0'               ; convert remainder to ASCII
    mov [rdi + rcx], dl       ; store character
    inc rcx                   ; increment counter
    test rax, rax             ; check if quotient is zero
    jnz convert_loop          ; continue if not

    ; Reverse the string in the buffer
    mov rdx, rcx              ; RDX is the length of the number string
    dec rcx                   ; adjust RCX for 0-based index
reverse_loop:
    mov al, [rsp + rcx]       ; get character from end
    mov bl, [rsp + rdx - rcx - 1] ; get character from start
    mov [rsp + rcx], bl       ; swap characters
    mov [rsp + rdx - rcx - 1], al
    dec rcx                   ; decrement index
    jns reverse_loop          ; continue until index < 0

print_number:
    mov rax, 0x1              ; sys_write syscall number
    mov rdi, 0x1              ; stdout
    lea rsi, [rsp]            ; buffer address
    mov rdx, rdx              ; length of number string
    syscall                   ; write to stdout
    add rsp, 32               ; restore the stack pointer
    ret
