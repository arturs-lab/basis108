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

bootd  equ     00h             ; delay after boot
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

start: dis     i                ; disable interrupts
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
       mov     a,#0ffh          ; turn off LEDs
       outl    p2,a
       en      i                ; enable interrupts
st1:   mov     a,r2             ; check if data present in input buffer
       jz      st1


; send data received from kbd

st2:   dec     r2               ; decrement counter of codes in buffer
       mov     a,r3             ; get the buffer pointer
       anl     a,#0fh           ; limit buffer to 16 bytes
       inc     r3               ; point to next byte in buffer
       add     a,#20h           ; add offset to RAM
       mov     r0,a             ; store it in index register
       mov     a,@r0            ; retreive scancode
       mov     r5,a             ; store scancode for later
       xrl     a,#0e0h          ; is it a prefix?
       jnz     st3              ; no, keep crunching
       mov     a,#ext
       orl     a,r4             ; set prefix flag on
       mov     r4,a
       jmp     st1              ; and work on next byte
st3:   mov     a,r5
       jb7     breakc           ; this is a break code!
       anl     a,#7fh           ; clear MSB
       mov     r5,a
       mov     a,r4             ; get flag register
       anl     a,#03h           ; is shift or caps flag on?
       jz      st4              ; no, keep going...
       mov     a,#(scan1 - 300h); put address of table for shifted codes in A
st4:   add     a,r5             ; add scancode
       movp3   a,@a             ; get ascii code from table
       jb7     special          ; this is not a normal letter
       call    sendch           ; send the code
exit:
       mov     a,#0c5h         ; clear all flags except CTRL and Shift for now
       anl     a,r4
       mov     r4,a
       jmp     st1              ; return to main loop

breakc:mov     a,#break
       orl     a,r4             ; mention this fact in the status register
       mov     r4,a
       mov     a,r5             ; get scancode again
       anl     a,#7fh            ; reset msb
       movp3   a,@a             ; get ascii code from table
       jb7     special          ; this is not a normal letter
       jmp     exit

special:
       anl     a,#7fh             ; strip 7-th bit
       call    s0
       jmp     exit

s0:    jnz     s1               ; Is it SHIFT?
       mov     a,#green         ; turn green led on
       outl    p2,a
       mov     a,r4             ; get status register
       jb5     s0a              ; is this a break code?
       orl     a,#shift         ; no, set SHIFT flag
       mov     r4,a
       ret
s0a:   anl     a,#0feh          ; yes, reset SHIFT flag
       mov     r4,a
       mov     a,#0ffh          ; turn off LEDs
       outl    p2,a
       ret

s1:    dec     a                ; Is it Caps Lock?
       jnz     s2

s2:    dec     a                ; Is it Ctrl?
       jnz     s1               ; not CTRL ( code 82 )
       mov     a,#red           ; turn red led on
       outl    p2,a
       mov     a,r4             ; get status register
       jb5     s2a              ; is this a break code?
       orl     a,#ctrl          ; no, set CTRL flag
       mov     r4,a
       ret
s2a:   anl     a,#0fbh          ; yes, reset CTRL flag
       mov     r4,a
       mov     a,#0ffh
       outl    p2,a
       ret

s3:    dec     a
       jnz     s4
s4:    dec     a
       jnz     s5
s5:    dec     a
       jnz     s6
s6:    dec     a
       jnz     s7
s7:    dec     a
       jnz     s8
s8:    dec     a
       jnz     s9
s9:    


sendch:mov     r6,a             ; store char for later
       mov     a,#ctrl          ; is ctrl flag on?
       anl     a,r4
       jz      sc1              ; no, just send the char
       mov     a,r6             ; yes, get the ascii code again
       anl     a,#1fh           ; and convert to ctrl code
       mov     r6,a
sc1:   
       orl     a,#80h           ; set clk high
       outl    p1,a             ; send to keyboard port
       call    ckdel
       mov     a,r6             ; get char
       anl     a,#7fh           ; clk low
       outl    p1,a
       call    ckdel
       mov     a,r6             ; get char
       orl     a,#80h           ; clk high
       outl    p1,a
       mov     a,#0ffh          ; set kbd port to all high again
       outl    p1,a
;       mov     a,#0e0h         ; clear all flags for now
;       anl     a,r4
;       mov     r4,a
       ret

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

scan:  db      '',27,'123456',  '7890-=',8,9        ; 00 - 0f
       db      'qwertyui',       'op[]',13,82h,'as'  ; 10 - 1f
       db      'dfghjkl;',       39,'`',80h,'\zxcv'  ; 20 - 2f
       db      'bnm,./',80h,'*', 'a kfffff'          ; 30 - 3f
       db      'fffffnl7',       '89-456+1'          ; 40 - 4f
       db      '230',8,'mf'    'f '                ; 50 - 58

scan1: db      '',27,'!@#$%^',  '&*()_+',8,9        ; 00 - 0f
       db      'QWERTYUI',       'OP{}',13,82h,'AS'  ; 10 - 1f
       db      'DFGHJKL:',       '"~',80h,'|ZXCV'    ; 20 - 2f
       db      'BNM<>?',80h,'*', 'a kfffff'          ; 30 - 3f
       db      'fffffnl7',       '89-456+1'          ; 40 - 4f
       db      '230',8,'mf'    'f '                ; 50 - 58

       end

