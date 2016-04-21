#include <xc.h>

#define size 20

.global main

.data
x:          .space 4 * size
y:          .space 4 * size
MAC_ACC:    .space 4
n:          .space 4
product:    .space 4

.text
.set noreorder

.ent main
main:
la          t9, n_input         //load n addresses into reg
la          t1, n

la          t8, x_input         //load x addresses into reg
la          t2, x

la          t7, y_input         //load y addresses into reg
la          t3, y

lw          t4, 0(t9)           //load n_input word into 4
sw          t4, 0(t1)           //store t4 value into n word
lw          t4, 0(t1)           //load n word into t4

firstLoop:
bgtz        t4, setValue
nop

setValue:                       //seting values into array
//storing values from x_input to x
lw          t5, 0(t8)
sw          t5, 0(t2)
addiu       t8, t8, 4
addiu       t2, t2, 4
//storing values from y_input to y
lw          t6, 0(t7)
sw          t6, 0(t3)
addiu       t7, t7, 4
addiu       t3, t3, 4
//iterator, branch and jump
addiu       t4, t4, -1
bgtz        t4, setValue        //branches when loading is finished
nop

// load/reload labels into registers
la          t9, MAC_ACC         //load MAC_ACC into reg 't0'
lw          t0, 0(t9)
la          t9, n               //load n into reg 't1'
lw          t1, 0(t9)
la          t2, x               //address of x is in reg 't2'
la          t3, y               //address of y is in reg 't3'
la          t9, product         //load product into reg 't4'
lw          t4, 0(t9)
secondLoop:
bltz        t1, endless
nop


mathOuter:
addu        t4, zero, zero     //set 'product' back to 0
lw          t5, 0(t2)
lw          t6, 0(t3)
beqz        t5, ifZero         //leaves if x value is 0
nop
beqz        t6, ifZero         //leaves if y value is 0
nop

mathInner:
addu        t4, t4, t5          //add 'x' 'y' number of times
addiu       t6, t6, -1
bgtz        t6, mathInner       //branch when 'y' > 0
nop

ifZero:
addu        t0, t0, t4          //add MAC_ACC with product
addiu       t2, t2, 4           //change address of 'x'
addiu       t3, t3, 4           //change address of 'y'
addiu       t1, t1, -1          //change counter 'n'
bgtz        t1, mathOuter
nop

endless:
j       endless
nop

.end main
n_input:    .word 4
x_input:    .word 0,2,3,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
y_input:    .word 4,5,6,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5