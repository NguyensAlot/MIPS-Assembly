#include <xc.h>

.global main

.data
var_a:      .word 0x7fffffff
var_b:      .word 0x10000000
var_c:      .space 4
var_d:      .space 4

.text
.set noreorder

.ent main
main:

LI      t0, 0x20000000
LA      t1, var_c
SW      t0, 0(t1)

LA      t9, var_a
LW      t1, 0(t9)       //load var_a into t1

LA      t9, var_b
LW      t2, 0(t9)       //load var_b into t2

LA      t9, var_c
LW      t3, 0(t9)       //load var_c into t3

LA      t9, var_d
LW      t4, 0(t9)       //load var_d into t4

ADDU     t4, t1, t2      //addition of var_a + var_b
SUBU     t4, t4, t3      //subtration of var_c from abv result
SW      t4, var_d

endless:
    j       endless
    nop

.end main
