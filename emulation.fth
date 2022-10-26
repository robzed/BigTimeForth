\ This file allows the watch.fth to run on gForth
\ input / output is via the terminal
\
\ Mostly it emulates FlashForth (which this code runs on), the ATMega328P microncontroller
\ and the BitTime watch PCB hardware.
\
\ Copyright (c) 2022 Rob Probin
\ Licensed under the MIT license

\ this is purposely underdefined on first run - but on Flashforth erases previous code from this point.
: -testLED ;

\ marker defintion in FlashForth - we don't use this here
: marker ;
cr

\ Set bits in file register with mask c. ( c addr — ) For PIC24-30-33, the mask is 16 bits.
: mset
  ." Set( *" . ." =" . ." )" cr
  2drop
;

\ Clear bits in file register with mask c. ( c addr — )
: mclr
  ." Clear( *" . ." =" . ." )" cr
;

\ AND file register byte with mask c. ( c addr — x )
: mtst
  ." Test( *" . ." =" . ." )" cr
  2drop 0
;

\ Subtract 2 from n. ( n — n1 )
: 2- 2 - ;


\ finally load watch.fth
include watch.fth
include unit_tests.fth

." Turn off Digits"
turn_off_digitIO
." Turn off indicators"
turn_off_indicators

." Turn "
\ 1 setsegIO
