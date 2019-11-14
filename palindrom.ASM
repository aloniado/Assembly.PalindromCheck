;EX5 Pal Class 42_2
;Alon Laniado 


; Palindrom exercise
; code gets a string from user and checks if it is a palindrom.
; empty or 1-char string defined as a palindrom
; code uses string operations

dseg segment
        OUT_WELCOME1      db 'Welcome to PalinromCheck! $'
        OUT_WELCOME2      db 0Ah, 0Dh, 'To exit type "exit" $',0Ah, 0Dh
        OUT_START         db 0Ah, 0Dh, 0Ah, 0Dh, 'Enter a string: $'
        OUT_PALINDROM     db 0Ah, 0Dh, 'String is a Palinrom.$'
        OUT_NOT_PALINDROM db 0Ah, 0Dh, 'String is NOT a palindrom.$'
        OUT_END           db 0Ah, 0Dh, 'Exiting...$'
                
        ST_EXIT           db 'EXIT$'
        ST_INPUT          db 30 dup(?)  ;input string
        ST_INPUT_rev      db 30 dup(?)  ;reversed input string
        
        exit_flag         db 0          ;when 1 : program will quit
        palindrom_flag    db 1          ;palindrom flag for answer printing
dseg ends

sseg segment stack
        dw 100h dup(?)
sseg ends

cseg segment
assume  ds:dseg,cs:cseg,ss:sseg
start:  mov ax,dseg                                           
        mov ds,ax
        mov es,ax
        
        
        ;----------------------------------
        mov dx, offset OUT_WELCOME1
        call printString
        mov dx, offset OUT_WELCOME2
        call printString
        
        infiniteLoop:
        mov palindrom_flag,1        ;initializing flag with 1
        mov dx, offset OUT_START
        call printString
        call readString             ;reads string from user
        call isExit                 ;compares string to 'EXIT'
        cmp exit_flag,1
        je SOF
        
        call reverseString          ;reversing string in ST_INPUT to ST_INPUT_rev
        call compareStrings         ;compares strings (first half)
        
        cmp palindrom_flag,1        ;chacks answer
        je PositiveAns
        
        ;prints answer:
        mov dx, offset OUT_NOT_PALINDROM
        jmp printAnswer
        PositiveAns:
        mov dx, offset OUT_PALINDROM
        printAnswer:
        call printString
        
        jmp infiniteLoop
        
        SOF:
        mov dx, offset OUT_END
        call printString
        mov ah,4ch
        int 21h
        ;----------------------------------  
        printString proc
            mov ah,9
            int 21h
            ret
        printString endp
        
        readString proc
            ;reads string from user. stops with ENTER key or 30 chars
            ;SI holds length of string entered after procedure.
            mov si,0
            
            nextCharRead:
            mov ah,1
            int 21h     ;char read
            cmp al,0Dh  ;comparing to ENTER (end of input)
            je endStringInput
            mov ST_INPUT[si],al ;saving char in ST_INPUT
            call toUpperCase
            inc si
            cmp si,30
            je endStringInput
            jmp nextCharRead

            endStringInput: ;checking length of string entered. 0 or 1 is palindrom.
            cmp si,0
            je PositiveAns
            cmp si,1
            je PositiveAns

            ret
        readString endp
        
        toUpperCase proc
            ;turns a char stored in ST_INPUT[si] to uppercase
            cmp ST_INPUT[si],61h
            jb charOK
            cmp ST_INPUT[si],7Ah
            ja charOK
            sub ST_INPUT[si],20h
            charOK:
            ret
        toUpperCase endp
        
        isExit proc
            ;changes exit_flag to 1 if 'exit' in input string
            push si
            mov cx,4
            isExitNext:
            mov si, offset ST_INPUT
            mov di, offset ST_EXIT
            cmpsb           ;comparing strings by bytes
            jne isExitNo
            loop isExitNext
            
            mov exit_flag,1
            
            isExitNo:
            pop si
            ret
        isExit endp
        
        reverseString proc
            mov cx,si
            push si
            mov bx,0
            dec si
            add si,offset ST_INPUT
            std         ;pointer will dcrease
            revLoop:
            lodsb
            mov ST_INPUT_rev[bx], al
            inc bx
            loop revLoop
            pop si
            cld         ;pointer will increase
            ret           
        reverseString endp
        
        compareStrings proc
            mov ax,si
            mov bl,2
            div bl      ;al holds string_length / 2
            mov ah,0
            mov cx,ax
            cmp cx,0
            
            
            compareLoop:
            mov si, offset ST_INPUT
            mov di, offset ST_INPUT_rev
            cmpsb       ;comparing strings by bytes
            jne NOT_PAL
            loop compareLoop
            ret
            
            NOT_PAL:
            mov palindrom_flag,0
            ret
        compareStrings endp
        ;---------------------------------- 

        
cseg ends
end start

