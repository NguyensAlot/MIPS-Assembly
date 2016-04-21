#include <xc.h>

.global main

.data
var_a:      .word 0x7fffffff
var_b:      .space 4
var_c:      .space 4

.text
.set noreorder

.ent main
main:

LI      t0, 0x10000000      //load a constant in register
LA      t2, var_b           //load a label into register
SW      t0, 0(t2)           //store constant into label 'var_b'

LA      t9, var_a           //load address for 'var_a'
LW      t1, 0(t9)           //load var_a into register

LA      t9, var_c           //load address for 'var_c'
LW      t3, 0(t9)           //load var_c into register

ADDU    t3, t2, t1          //unsigned addition of var_a + var_b = var_c
SW      t3, var_c           //store summation result into 'var_c'

endless:
    j       endless
    nop

.end main
