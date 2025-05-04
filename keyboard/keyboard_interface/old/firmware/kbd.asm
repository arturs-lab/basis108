; Keyboard converter XT -> Apple IIe
; send lower/uppercase chars and ctrl chars

; register usage:
; r0  pointer to user memory
; r1  
; r2  counter of chars in buffer
; r3  output buffer pointer
; r4  status register
;    0 shift
;     1 caps lock
;     2 ctrl
;     3 alt
;     4 prefix e0
;     5 break code
; r5  temporary scancode storage
; r6  general purpose, scratch
; r7  general purpose, scratch
; r0' pointer to user memory
; r1' interrupt handler
; r2' interrupt handler stores A here
; r3' input buffer pointer
; r4' 
; r5' 
; r6' 
; r7' 

bootd  equ     80h             ; delay after boot
delch  equ     80h             ; delay between chars
delck  equ     05h             ; delay between clock pulses
deltim equ     40h             ; inner loop length for delay procedure

; bitmasks for status register
shift  equ    01h
caps   equ    02h
ctrl   equ    04h
alt    equ    08h
ext    equ    10h
break  equ    20h

red    equ    0efh            ; red led
green  equ    0dfh            ; green led

       org     0
       jmp     start

       ORG     3
int:   jmp     inth            ; go to INT handler

       org     7
timr:  jmp     timrh           ; go to timer interrupt handler

start: call    init             ; initialize system
st1:   mov     a,r4             ; get status register
       jb2     lred             ; if ctrl flag on, turn on red led
       anl     a,#(shift+caps)  ; see if shift or caps is on
       jnz     lgreen           ; turn on green led if yes
       mov     a,#0ffh          ; turn off LEDs
       outl    p2,a
       jmp     stmain

lgreen:mov     a,#green         ; turn green led on
       outl    p2,a
       jmp     stmain

lred:  mov     a,#red           ; turn red led on
       outl    p2,a
       
stmain:mov     a,r2             ; check if data present in input buffer
       jz      stmain           ; if not, wait in an infinite loop


; send data received from kbd

st2:   dec     r2               ; decrement counter of codes in buffer
       mov     a,r4             ; get flags

       anl     a,#0dfh          ; reset break flag
       mov     r4,a

       mov     a,r3             ; get the buffer pointer
       anl     a,#0fh           ; limit buffer to 16 bytes
       inc     r3               ; point to next byte in buffer
       add     a,#20h           ; add offset to RAM
       mov     r0,a             ; store it in index register
       mov     a,@r0            ; retreive scancode

       mov     r5,a             ; store scancode for later

pfix:  xrl     a,#0e0h         ; is it a prefix?
       jnz     brkc            ; no, see if it is left Shift
       mov     a,#ext
       orl     a,r4             ; set prefix flag on
st0:   mov     r4,a
       jmp     st1              ; go back to main loop

brkc:  jb7     shft1           ; this is not a break code
brkc1: mov     a,r5
       anl     a,#7fh          ; yes, it is, strip MSB
       mov     r5,a            ; save scancode for later
       mov     a,#break        ; set break code flag
       orl     a,r4
       mov     r4,a

shft1: mov     a,r5            ; restore scancode
       xrl     a,#2ah          ; is it left Shift?
       jnz     shft3           ; no, see if it is right Shift
       mov     a,r4
       jb5     shft2           ; is it a break code?
       orl     a,#shift        ; no, turn on shift flag
       jmp     st0             ; save flags and go back to main loop
shft2: anl     a,#(0ffh-shift) ; turn off shift flag
       jmp     st0             ; save flags and go back to main loop

shft3: mov     a,r5            ; restore scancode
       xrl     a,#36h          ; is it left Shift?
       jnz     cps             ; no, see if it is Caps Lock
       mov     a,r4
       jb5     shft4           ; is it a break code?
       orl     a,#shift        ; no, turn on shift flag
       jmp     st0             ; save flags and go back to main loop
shft4: anl     a,#(0ffh-shift) ; turn off shift flag
       jmp     st0             ; save flags and go back to main loop

cps:   mov     a,r5            ; restore scancode
       xrl     a,#3ah          ; is it Caps Lock?
       jnz     ktrl            ; no, see if it is Control
       mov     a,r4            ; yes, now see if it is a break code
       jb5     cps1            ; yes, return
       mov     a,#caps
       xrl     a,r4             ; toggle caps flag
cps1:  jmp     st0             ; save flags and go back to main loop

ktrl:  mov     a,r5            ; restore scancode
       xrl     a,#1dh          ; is it Control?
       jnz     kalt            ; no, see if it is Alt
       mov     a,r4
       jb5     ctrl1           ; is it a break code?
       orl     a,#ctrl         ; no, turn on control flag
       jmp     st0             ; save flags and go back to main loop
ctrl1: anl     a,#(0ffh-ctrl)  ; turn off control flag
       jmp     st0             ; save flags and go back to main loop

kalt:  mov     a,r5            ; restore scancode
       xrl     a,#38h          ; is it Alt?
       jnz     brk             ; no, check if this was a break code
       mov     a,r4
       jb5     kalt1           ; is it a break code?
       orl     a,#alt          ; no, turn on alt flag
       jmp     st0             ; save flags and go back to main loop
kalt1: anl     a,#(0ffh-alt)   ; turn off alt flag
       jmp     st0             ; save flags and go back to main loop

brk:   mov     a,r4            ; was it a break code?
       jb5     st1             ; yes, go back to main loop

       anl     a,#(shift+caps)  ; is shift or caps flag on?
       jz      st4              ; no, keep going...
       mov     a,#(scan1 - 300h); put address of table for shifted codes in A
st4:   add     a,r5             ; add scancode
       movp3   a,@a             ; get ascii code from table
       jb7     special          ; this is not a normal letter
       mov     r5,a            ; store ascii for later

       mov     a,#ctrl         ; is Ctrl flag on?
       anl     a,r4
       jz      altf            ; no, check alt flag
       mov     a,#1fh          ; convert ascii to Ctrl code
       anl     a,r5
       jmp     send0

altf:  mov     a,#alt          ; is alt flag on?
       anl     a,r4
       jz      send1           ; no output char
       mov     a,#1fh          ; for now alt = ctrl
       anl     a,r5
       jmp     send0

send1: mov     a,r5
send0: call    send
       jmp     st1

; special char handler
; special chars are: 
; code make   name    result
; 80   47     Home    
; 81   48     up      05h
; 82   49     PG UP   12h
; 83   4b     left    13h
; 84   4d     right   04h
; 85   4f     End     
; 86   50     down    18h
; 87   51     PG DN   03h
; 88   52     Insert  
; 89   53     Delete  
;
special:
       anl     a,#7fh           ; strip 7-th bit
       jb6     func             ; if bit 6 is set, send text for function key
       mov     r5,a
       add     a,r5             ; multiply a by 3
       add     a,r5
       mov     r5,a             ; store a for later
       mov     a,#ext           ; check if this is prefixed code
       anl     a,r4
       jz      sp1              ; go on if not
       mov     a,r5             ; adjust table pointer if yes
       inc     a
       mov     r5,a             ; store a for later
sp1:   mov     a,#ctrl          ; check if Ctrl key is down
       anl     a,r4
       jz      sp2              ; go on if not
       mov     a,r5             ; adjust table pointer if yes
       inc     a
       jmp     sp3
sp2:   mov     a,r5
sp3:   add     a,#(sptab-300h)  ; calculate table address
       movp3   a,@a             ; get special code from table
       jmp     send0            ; and send it

func:  anl     a,#3fh           ; strip 6th bit
       mov     r5,a             ; setup counter
       mov     r0,#strings      ; setup pointer to begining of table
       jmp     f1
f2:    mov     a,r0
       movp3   a,@a             ; fetch data from table on page 3
       inc     r0               ; increment pointer
       jb7     f3               ; end of current string found
       jmp     f2               ; continue inner loop
f3:    dec     r5
f1:    mov     a,r5             ; check counter
       jnz     f2               ; continue outer loop
f4:    mov     a,r0
       movp3   a,@a             ; fetch code
       inc     r0               ; point to next char in string
       jb7     f5
       call    send
       jmp     f4
f5:    jmp     st1


;       org     100h

init:  dis     i                ; disable interrupts
       clr     a
       sel     rb1
       mov     r3,a             ; reset input buffer pointer
       sel     rb0
       mov     r4,a             ; reset status register
       mov     r3,a             ; reset output buffer pointer
       mov     r2,a             ; reset buffer size counter
       dec     a   
       outl    p1,a             ; initialize kbd port
       outl    p2,a             ; make sure that keyboard output is high
       mov     a,#0cfh          ; turn on both LEDs
       outl    p2,a
       mov     a,#bootd
       call    delay            ; wait a little before doing anything
       en      i                ; enable interrupts
       ret

; send data in register a to Apple's Keyboard port
send:  mov     r5,a
       orl     a,#80h           ; set clk high
       outl    p1,a             ; send to keyboard port
       call    ckdel
       mov     a,r5             ; get char
       anl     a,#7fh           ; clk low
       outl    p1,a
       call    ckdel
       mov     a,r5             ; get char
       orl     a,#80h           ; clk high
       outl    p1,a
       mov     a,#0ffh          ; set kbd port to all high again
       outl    p1,a
       mov     a,r4             ; reset prefix flag for good-bye
       anl     a,#(0ffh-ext)
       mov     r4,a
       ret                      ; return to main loop

; delay between characters
chdel: mov     a,#delch
       jmp     delay

; delay between clock pulses
ckdel: mov     a,#delck        ; delay between clock pulses

; main delay procedure
delay: mov     r7,a            ; store delay time in counter
del2:  mov     a,#deltim       ; load inner loop delay time
del1:  dec     a               ; decrement inner delay counter
       jnz     del1            ; loop until zero
       dec     r7
       mov     a,r7
       jnz     del2            ; same here
       ret

; interrupt handler procedure
inth:  sel     rb1
       mov     r2,a             ; store contents of A
       clr     a                ; clear input
       jmp     ih2              ; you are here cause clk is low, so wait for it to go high
ih1:   jni     ih2
       jmp     ih1              ; wait for clock to go low
ih2:   jni     ih2              ; wait in loop for clock to go high
       clr     c                ; clear carry bit
       jnt0    ih3              ; jump if T0 (kbddata) = 0
       cpl     c                ; otherwise set CY=1
ih3:   rrc     a                ; rotate CY into A(7) and A(0) into CY
       jnc     ih1              ; if CY=0 more bits need to be received
       mov     r1,a             ; store scancode
       mov     a,r3
       anl     a,#0fh           ; limit buffer to 16 bytes
       inc     r3               ; point to next byte in buffer
       add     a,#20h           ; add offset to RAM
       mov     r0,a             ; store it in index register
       mov     a,r1             ; retrieve scancode
       mov     @r0,a            ; store it in RAM
       mov     a,r2             ; restore A
       sel     rb0
       inc     r2               ; increase counter of chars to be processed
       retr

timrh: retr

       org     0300h

scan:  db      '',27,'123456',       '7890-=',8,9                    ;00-0f
       db      'qwertyui',            'op[]',13,'as'                 ;10-1f
       db      'dfghjkl;',            39,'`\zxcv'                    ;20-2f
       db      'bnm,./*',            ' ',0c0h,0c1h,0c2h,0c3h,0c4h  ;30-3f
       db      'fffff',80h,         81h,82h,'-',83h,'5',84h,'+',85h ;40-4f
       db      86h,87h,88h,89h,'mf' 'f '                            ;50-58

; scancodes after shift
scan1: db      '',27,'!@#$%^'        '&*()_+',8,9                    ;00-0f
       db      'QWERTYUI'             'OP{}',13,'AS'                 ;10-1f
       db      'DFGHJKL:'             '"~|ZXCV'                      ;20-2f
       db      'BNM<>?*'             ' fffff'                      ;30-3f
       db      'fffff',80h,         81h,82h,'-',83h,'5',84h,'+',85h ;40-4f
       db      86h,87h,88h,89h,'mf' 'f '                            ;50-58

sptab:                     ; code make   name    result
       db      '7','7','7' ; 80   47     Home    '7','7','7'
       db      '8',05h,12h ; 81   48     up      '8',^E ,^R
       db      '9',12h,12h ; 82   49     PG UP   '9',^R ,^R
       db      '4',13h,01h ; 83   4b     left    '4',^S ,^A
       db      '6',04h,06h ; 84   4d     right   '6',^D ,^F
       db      '1','1','1' ; 85   4f     End     '1','1','1'
       db      '2',18h,03h ; 86   50     down    '2',^X ,^C
       db      '3',03h,03h ; 87   51     PG DN   '3',^C ,^C
       db      '0','0','0' ; 88   52     Insert  '0','0','0'
       db      '.',08h,08h ; 89   53     Delete  '.',^H ,^H
                                               ; |   |   ctrl
                                               ; |   prefixed
                                               ; no modifiers
strings:
       db      'dir'0a0h
       db      'pip'0a0h
       db      'turbo'0a0h
       db      'masm'0a0h
       db      'stat'0a0h

       end

