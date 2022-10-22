\ BigTime watch code in Forth with extra features
\ Copyright (c) 2022 Rob Probin
\ Licensed under the MIT license
\
\ This does not use any of the code from the Arduino project
\ and instead runs everything on FlashForth

-testLED
marker -testLED

\ Tachyon/Picoforth-style extensions
: >> rshift ;
: << lshift ;


37 constant PORTB	\ Port B Data Register
40 constant PORTC	\ Port C Data Register
43 constant PORTD	\ Port D Data Register

\ Use:
\ PORTD %10000000 defPIN: PD7  ( define portD pin #7)
: defPIN: ( PORTx mask --- <word> | <word> --- mask port)
    create
        c, c,           \ compile PORT and min mask
    does>
        dup c@          \ push pin mask
        swap 1+ c@      \ push PORT
  ;

\ Turn a port pin on, dont change the others.
: high ( pinmask portadr -- )
    mset
  ;
\ Turn a port pin off, dont change the others.
: low ( pinmask portadr -- )
    mclr
  ;


\ Only for PORTx bits, 
\ because address of DDRx is one less than address of PORTx.
 
\ Set DDRx so its corresponding pin is output.
: output ( pinmask portadr -- )
    1- high
  ;
\ Set DDRx so its corresponding pin is input.
: input  ( pinmask portadr -- )   
    1- low
  ;

\ read the pins masked as input
: pin@  ( pinmask portaddr -- fl )
    2- mtst \ select PINx register as input
    if      true
    else    false   then
  ;


\ seven segment digits/numbers
\  _     A
\ |_|  F G B
\ |_|  E   C
\        D   +DP
\ Each of those A-G have a seperate select - which should taken LOW to turn it on.
\ Each digit has a digit select - which should be taken HIGH to turn it on.
\ The original code reverse biased the LEDs while running - should we do this? What about reverse
\ leakage? Too small?

\ On this display the colon time seperator and the AM/PM indicator are seperately controlled.
\ These should be turned HIGH to turn it on (same as the digits).
\
\ DP is not connected to the ATMEGA328P MCU.
: bit 1 swap << ;

PORTD 6 bit defPIN: segA
PORTB 0 bit defPIN: segB
PORTD 5 bit defPIN: segC
PORTB 3 bit defPIN: segD
PORTB 5 bit defPIN: segE
PORTD 4 bit defPIN: segF
PORTD 7 bit defPIN: segG
PORTB 1 bit defPIN: digit1
PORTB 2 bit defPIN: digit2
PORTC 0 bit defPIN: digit3
PORTC 1 bit defPIN: digit4
PORTB 4 bit defPIN: colon
PORTD 3 bit defPIN: am/pm

PORTD 2 bit defPIN: button


: seg    0 ;
: seg..| 1 ;
: seg._  2 ;
: seg._| 3 ;
: seg|   4 ;
: seg|.| 5 ; 
: seg|_  6 ;
: seg|_| 7 ;
: seg>n rot 0<> if 64 then + swap 8 * + ;


\ numbers - 0123456789
create seg_numbers
seg._ 
seg|.|
seg|_| seg>n ,
seg
seg..|
seg..| seg>n ,
seg._ 
seg._|
seg|_  seg>n ,
seg._
seg._|
seg._| seg>n ,
seg
seg|_|
seg..| seg>n ,
seg._
seg|_
seg._| seg>n ,
seg._
seg|_
seg|_| seg>n ,
seg._
seg..|
seg..| seg>n ,
seg._
seg|_|
seg|_| seg>n ,
seg._
seg|_|
seg..| seg>n ,

: segdigit ( 0>=n<=9 -- m )
  cells seg_numbers + @
;


\ letter - Aa bCc dEeF gHhiI JK Llm noOP qrStuvwxyz
create seg_letters
seg._ 
seg|_|
seg|.| seg>n ,
seg._
seg._|
seg|_|
0 , \ no B
seg 
seg|_
seg|_| seg>n ,
seg._ 
seg|
seg|_ seg>n ,
seg
seg._
seg|_ seg>n m
seg 
seg _|
seg|_| seg>n ,
0 , \ no D
seg._ 
seg|_
seg|_  seg>n ,
seg._  \ e is a bit rubbish, remove?
seg|_| 
seg|_  seg>n ,
seg._ 
seg|_
seg|   seg>n ,
0 , \ no f
0 , \ no G
seg._ 
seg|_|
seg._| seg>n ,
seg
seg|_|
seg|.| seg>n ,
seg  
seg|_ 
seg| | seg>n ,
seg 
seg| 
seg|   seg>n , 
seg
seg
seg|   seg>n ,
seg
seg..|
seg|_| seg>n ,
seg
seg..|
seg._| seg>n ,
seg    \ K is hard/impossible
seg|_|
seg|   seg>n ,
0 ,   \ no k
seg
seg|
seg|_ seg>n ,
0 ,   \ no l
seg._ \ M is impossible
seg._
seg._
0 ,   \ no m
0 ,   \ no N
seg
seg._
seg|.| seg>n , 
seg._
seg|.|
seg|_| seg>n ,
seg
seg._
seg|_| seg>n ,
seg._
seg|_|
seg|   seg>n ,
0 , no Q
seg._
seg|_|
seg..| seg>n ,
0 , no R
seg
seg._
seg|   seg>n ,
seg._
seg|_
seg._| seg>n ,
0 , \ no s
0 , \ no T
seg
seg|_
seg|_  seg>n ,
seg
seg|.|
seg|_| seg>n ,
seg
seg
seg|_| seg>n ,
seg    \ V is impossible
seg|.|
seg|.| seg>n ,
seg    \ v is impossible
seg
seg|.| seg>n ,
seg._  \ W is impossible
seg._
seg._ seg>n ,
0 , \ no w
seg    \ X is impossible
seg| |
seg| | seg>n ,
0 , \ no x
0 , \ no Y
seg
seg|_|
seg._| seg>n ,
seg._  \ Z is impossible
seg._
seg._
0 , \ no z

: (segaddr) ( 0>=n<26 -- addr )
  cells 2* seg_letters +
;

: (segletter) ( 0>=n<26 -- upper lower )
  (segaddr) dup @ swap 1+ @
;

: seglower ( a>=n<=z -- m )
  [char] a - (segletter)
  ?dup if nip then   \ I'd like to name this construct like select top if no zero
;
: segupper ( A>=n>=Z -- m )
  [char] A - (segletter) swap
  ?dup if nip then
;


seg
seg
seg._ seg>n constant seg_underscore
seg
seg._
seg   seg>n constant seg_dash

: isdigit ( char -- flag )
  0 10 within
;
: isupper ( char -- flag )
  [char] A [char] Z 1+ within
;
: islower ( char -- flag )
  [char] a [char] z 1+ within
;

: getsegchar ( char -- n )
  dup isdigit if [char] 0 - segdigit exit then
  dup isupper if segupper exit then
  dup islower if seglower exit then
  dup [char] '-' if drop seg_dash exit then
  dup [char] '_' if drop seg_underscore exit then
  drop 0
;

\  _     A       64
\ |_|  F G B  32 16 8
\ |_|  E   C   4    1
\        D       2

: setIO ( flag port -- ) swap if high else low then ;
: setsegIO ( n -- )
  dup 1 and segC setIO then
  dup 2 and segD setIO then
  dup 4 and segE setIO then
  dup 8 and segB setIO then
  dup 16 and segG setIO then
  dup 32 and segF setIO then
      64 and segA setIO then
;

: turn_off_digitIO ( -- )
  digit1 low
  digit2 low
  digit3 low
  digit4 low
;
: turn_off_indicators ( -- )
  am/pm low
  colon low
;

: setdigitIO ( n -- )
  dup 1 = if digit1 high exit then
  dup 2 = if digit2 high exit then
  dup 3 = if digit3 high exit then
  dup 4 = if digit4 high exit then
  \ otherwise turn them all off
  turn_off_digitIO
;


: (show4) ( am/pm-flag colon-flag c-addr -- )
  turn_off_digitIO
  4 for
    dup c@ getsegchar setsetIO
	r@ 3 = if swap colon setIO then
	r@ 2 = if swap am/pm setIO then
	4 r@ - setdigitIO 
    1+ 
    2 ms
    turn_off_indicators
    turn_off_digitIO
  next
;

: display4str ( am/pm-flag colon-flag c-addr -- )
  (show4)
;

variable minute 21 minute !
variable hour 10 hour !
create displaybuf 4 allot

: int>disbuf ( 0>=n<=9 offset -- )
  displaybuf + [char] 0 + swap c!
;
 
: (display24h) ( am/pm-flag colon-flag -- )
  hour @ 10 / int>disbuf
  hour @ 10 % 1 int>disbuf
  minute @ 10 / 2 int>disbuf
  minute @ 10 % 3 int>disbuf
;
: display24h (display24h) (show4) ;
: display12h ( am/pm-flag colon-flag -- )
  (display24h)
  displaybuf c@ [char] 0 = if bl displaybuf c! then
  (show4)
;

\ TO DO 
\ 
\ 1. test segment display functions
\ 2. set up show time 
\ 3. set up set time
\ 4. set up show colour
\ 5. set up modes (12/24 switch, date, year, brightness, message, set date)
\ 6. set up 32Khz clock
\ 7. set up button interrupt
\ 8. flash colon, flash am/pm, flash digits
\ 9. poll button mode (look for press and release, double press, and hold)
\ 10. power down peripherals
\ 11. figure out LED reverse - good or bad
\ 12. sleep modes (idle)
\ 13. sleep modes - after 2 seconds no activity
\ 14. measure current
\ 15. colour settings?
\ 16. system timer, and serial - idle those?
\ 17. finger release on initial press?

