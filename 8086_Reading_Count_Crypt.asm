.MODEL small
.STACK

.DATA
first_line DB 50 DUP(?)
second_line DB 50 DUP(?)
third_line DB 50 DUP(?) 
fourth_line DB 50 DUP(?)

occurence_first DB 52 DUP (?)
occurence_second DB 52 DUP (?)
occurence_third DB 52 DUP (?)
occurence_fourth DB 52 DUP (?)

max_msg DB "Max character: A (01)",13,10,"Max/2 characters: $"
max_half_msg DB "A (01) $"
caesar_msg DB "Caesar cryptography: $"

.CODE
.STARTUP


MOV AH,1 ;set the int 21h to read inputs
MOV DI,0 ;set the index of the memory to the first address
MOV CX,4

reading: PUSH CX
    MOV CX,20
        reading_1_20: INT 21h ;reads the first 20 characters without interrupting
            MOV first_line(DI),AL                          
            INC DI
            LOOP reading_1_20
                         
        MOV CX,30
            reading_21_50: INT 21h ;reads the remaining 30 characters checking for enter
                
                CMP AL,13
                    JNE no_enter
                    
                    MOV AH,2
                    MOV DL,10
                    INT 21h
                    MOV AH,1
                    
                    ADD DI,CX
                    ;SUB DI,1 ;readjusting the pointer when an enter is detected
                    MOV CX,1 ;set to 1 so that the loop will exit                
                    JMP next_reading
                    
            no_enter: MOV first_line(DI),AL
                INC DI
            next_reading:LOOP reading_21_50

POP CX
LOOP reading


MOV AH,2    ;prints in the console a new line 
MOV DL,10
INT 21h
    
MOV AH,2
MOV DL,13
INT 21h
    
       
MOV CX,4
MOV DI,0
MOV DX,0

counting:PUSH CX
        MOV CX,50
        line_counting:MOV AL,first_line(DI)
            INC DI
            SUB AL,'A'
            
            JC skip_char  ;jumps if the ascii is lower than 'A'
                CMP AL,'Z'-'A'
                JA lower_case
                    MOV BX,DX   ;|
                    ADD BL,AL   ;adjust the buffer of the line          
                    INC occurence_first(BX)
                    JMP skip_char
        
                lower_case:SUB AL,6
                CMP AL,25
                JB skip_char
                    CMP AL,51
                    JA skip_char
                        MOV BX,DX
                        ADD BL,AL
                        INC occurence_first(BX)                         
        
        skip_char:LOOP line_counting
            
    ADD DX,52 ;used to move to the next line occurences buffer  
        
    POP CX
    LOOP counting 
    
MOV DI,0
MOV CX,4

max_loop:PUSH CX
    MOV BX,0
    MOV CX,52
    max_check:MOV BH,occurence_first(DI)
        CMP BL,BH
        JA next_max
            MOV BL,BH
            
            POP DX    ;algorithm to subtract the current line 
            PUSH DX   ;value to save in the array
            MOV AX,4
            SUB AX,DX
            MOV DH,52
            MUL DH
            MOV DX,DI
            SUB DX,AX
            
        next_max: INC DI
        LOOP max_check
    
    MOV BH,DL
    
    CMP BH,26
    JB upper_case_max      ;transform the value from the array (0 to 52) to ascii
        ADD BH,6
    upper_case_max:ADD BH,'A'
        
    MOV BYTE PTR[max_msg+15],BH ;writes in the msg in memory
    
    MOV AL,BL  ;transform the occurences number into two ascii tens and unity
    MOV AH,0
    MOV BH,10
    DIV BH
    
    ADD AH,48
    ADD AL,48
    
    MOV BYTE PTR[max_msg+18],AL  ;writes the converted number in the msg
    MOV BYTE PTR[max_msg+19],AH
    
    LEA DX,max_msg
        
    MOV AH,9  ;write to the console
    INT 21h
    
    MOV BH,0  ;divide by two and add the carry out to take 
    SHR BX,1  ;only the top half with odd number
    ADC BX,0
    
    MOV CX,52
    
    POP AX  ;calculate the correct DI for the current line
    PUSH AX
    MOV AH,4
    SUB AH,AL
    MOV AL,AH
    MOV AH,0
    MUL CX
    MOV DI,AX
    
    max_half:   
    
        MOV AH,0
        MOV AL,occurence_first(DI)
        CMP AX,BX
        JB next_half
            
            POP DX   ;algorithm to subtract the current 
            PUSH DX  ;line value to save in the array
            MOV AX,4
            SUB AX,DX
            MOV DH,52
            MUL DH
            MOV DX,DI
            SUB DX,AX
            
            CMP DL,26    ;array to ascii conversion
            JB upper_case_half
                ADD DL,6
            upper_case_half:ADD DL,'A'
            
            MOV BYTE PTR[max_half_msg],DL  ;write in the msg
            
            MOV AL,occurence_first(DI)  ;convert number to ascii (tens and unity)
            MOV DL,10
            
            DIV DL
            ADD AH,48
            ADD AL,48
            
            MOV BYTE PTR[max_half_msg+3],AL
            MOV BYTE PTR[max_half_msg+4],AH
            
            LEA DX,max_half_msg
            MOV AH,9           
            INT 21h      
            
        
        next_half:INC DI
        LOOP max_half
    
    MOV AH,2    ;prints in the console a new line 
    MOV DL,10
    INT 21h
    
    MOV AH,2
    MOV DL,13
    INT 21h
    
    MOV AH,9
    LEA DX,caesar_msg
    INT 21h
    
    POP CX  ;calculate the correct DI for the current line
    PUSH CX ;and retreive the caesar 'k'
    
    MOV BX,5
    MOV AX,4
    
    SUB AX,CX
    SUB BX,CX
    
    MOV CX,50
    MUL CX
    MOV DI,AX
        
    caesar_loop:
 
        MOV AL,first_line(DI)
        CMP AL,0      ;exit the cycle if NULL char
        JE next_caesar
        
        CMP AL,'A'   ;do not modify chars under 'A'
        JB print_char
        
        CMP AL,'z'   ;do not modify chars above 'z'
        JA print_char
        
        ADD AL,BL
        
        MOV DL,26
        SUB AL,'A'
        CMP AL,26 ;checks if the char is over 'Z'
            JA caesar_lower
            DIV DL
            MOV AL,AH
            ADD AL,'A'
            JMP  print_char
            caesar_lower:SUB AL,26
                CMP AL,6   ;checks if the char is lower than 'a' 
                JB in_between_char
                
                    SUB AL,6
                    DIV DL
                    MOV AL,AH
                    ADD AL,'a'
                    JMP print_char
                    
        in_between_char: ADD AL,'Z' 
        print_char: MOV DL,AL
        
        MOV AH,2
        INT 21h   
           
        next_caesar:INC DI
        MOV AH,0
        LOOP caesar_loop
    
    MOV AH,2    ;prints in the console a new line 
    MOV DL,10
    INT 21h
    
    MOV AH,2
    MOV DL,13
    INT 21h
    
    MOV AH,2    ;prints in the console a new line 
    MOV DL,10
    INT 21h
    
    MOV AH,2
    MOV DL,13
    INT 21h
     
    POP CX
    LOOP max_loop
       
    
.EXIT
END