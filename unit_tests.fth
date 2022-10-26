

include ttester.fth

t{ 0 (segaddr) -> seg_letters }t

t{ char a isdigit -> 0 }t
t{ char 0 isdigit -> -1 }t
t{ char 1 isdigit -> -1 }t
t{ char 8 isdigit -> -1 }t
t{ char 9 isdigit -> -1 }t
t{     32 isdigit -> 0 }t

t{ char a isupper -> 0 }t
t{ char z isupper -> 0 }t
t{ char A isupper -> -1 }t
t{ char B isupper -> -1 }t
t{ char Y isupper -> -1 }t
t{ char Z isupper -> -1 }t
t{ char 0 isupper -> 0 }t
t{     32 isupper -> 0 }t

t{ char A islower -> 0 }t
t{ char Z islower -> 0 }t
t{ char a islower -> -1 }t
t{ char b islower -> -1 }t
t{ char y islower -> -1 }t
t{ char z islower -> -1 }t
t{ char 0 islower -> 0 }t
t{     32 islower -> 0 }t

t{ char 0 getsegchar -> seg_numbers @ }t
t{ char 1 getsegchar -> seg_numbers CELL+ @ }t
t{ char A getsegchar -> seg_letters @ }t
t{ char _ getsegchar -> seg_underscore }t
t{ char - getsegchar -> seg_dash }t
t{ char a getsegchar -> seg_letters CELL+ @ }t
t{ char $ getsegchar -> 0 }t

\ only has lower case b
t{ char B getsegchar -> seg_letters 3 CELLS + @ }t
t{ char b getsegchar -> seg_letters 3 CELLS + @ }t

