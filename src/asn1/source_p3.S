#include <xc.h>

.global main

.data

var_a:      .word 0x7fffffff
var_b:      .word 0x10000000
var_c:      .space 4

.text
.set noreorder

.ent main
main:

LA      t9, var_a
LW      t0, 0(t9)

LA      t9, var_b
LW      t1, 0(t9)

LA      t9, var_c
LW      t2, 0(t9)

ADD     t2, t1, t0


endless:
    j       endless
    nop

.end main
