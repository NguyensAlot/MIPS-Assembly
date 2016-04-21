//Anthony Nguyen
//CST250 Lab 3

#include <xc.h>

.global main

.data
EXPR:   .word 2
        .word 3
        .word 0x80000000 + '*'

RESULT: .word 0

.text
.set noreorder
MULT_CONST:     .word 0x80000000 + '*'
ADD_CONST:      .word 0x80000000 + '+'
SUB_CONST:      .word 0x80000000 + '-'
EQU_CONST:      .word 0x80000000 + '='

.ent main
main:
la      s0, EXPR        //initialize pointer with array address
lw      s1, 0(s0)

initialize:
blez    s1, operator    //check if value is an operator
nop
//push value onto stack
addiu   sp, sp, -4
sw      s1, 0(sp)
//increment pointer address and load word
addiu   s0, s0, 4
lw      s1, 0(s0)
j       initialize
nop

operator:
lw      t0, MULT_CONST
lw      t1, ADD_CONST
lw      t2, SUB_CONST
lw      t3, EQU_CONST

beq     t0, s1, multStuff
nop
beq     t1, s1, addStuff
nop
beq     t2, s1, subStuff
nop

multStuff:
//pop from stack
lw      t9, 4(sp)
lw      t8, 0(sp)
addiu   sp, sp, 8

move      a0, t9
move      a1, zero
move      a2, t8
jal     multiply
nop
j       exit
nop
multiply:
addu    a1, a1, a0      //add 'x' 'y' number of times
addiu   a2, a2, -1
bgtz    a2, multiply
nop
sw      a1, 0(v0)
jr      ra
nop

addStuff:
//pop from stack
lw      t6, 4(sp)
lw      t7, 0(sp)
addiu   sp, sp, 8

//add then store
addu    v0, t6, t7
addiu   sp, sp, -4
sw      v0, 0(sp)
j       exit
nop

subStuff:
//pop from stack
lw      t6, 4(sp)
lw      t7, 0(sp)
addiu   sp, sp, 8

//sub then store
sub     v0, t6, t7
addiu   sp, sp, -4
sw      v0, 0(sp)
j       exit
nop

exit:
lw      t9, 0(sp)
addiu   sp, sp, 4
sw      t9, RESULT

ending_loop:
j       ending_loop
nop

.end main
