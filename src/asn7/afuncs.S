// Anthony Nguyen
// CST250 - Lab 7
// *can't make call to flipSign

#include <xc.h>

// is this right?
.global output_result           // prototype in C file
.global output_line1_from_asm   // prototype in C file
.global output_line2_from_asm   // prototype in C file

.data
byteArray:      .space 40

.text
.set noreorder
//=================================
// Macro: prt
// Description:
//      outputs a number
// Arguements:
//      printLoop - name of loop
// Registers:
//      a0 - value of t3 as param
//      t3 - address of byteArray
//      v0 - number of digits/loops
// =================================
.macro prt printLoop
jal     b_to_a              // convert binary to ascii
nop
la      t3, byteArray       // load address of ascii
\printLoop:
move    a0, t3
jal     output_string       // output single digit
nop
addiu   t3, t3, 4
addiu   v0, v0, -1
bnez    v0, \printLoop      // loop if >1 digits
nop
.endm
// =================================
// Macro: prtS
// Description:
//      outputs a literal string
// Arguments:
//      string - address of string
// Registers:
//      a0 - value of t3 as param
//      t3 - address of string constant
// =================================
.macro prtS string
la      t3, \string
move    a0, t3
jal     output_string
nop
.endm

// =================================
// Subroutine: output_result
// Description:
//      does stuff
// =================================
.ent output_result
output_result:
addiu   sp, sp, -28
sw      ra, 24(sp)
sw      fp, 20(sp)
move    fp, sp
sw      s7, 16(fp)

move    s7, a0              // store F somewhere

jal     output_line1_from_asm
nop
move    a0, s7
jal     output_line2_from_asm
nop

lw      s7, 16(fp)
move    sp, fp
lw      ra, 24(sp)
lw      fp, 20(sp)
addiu   sp, sp, 28
jr      ra
nop
.end output_result
// =================================
// Subroutine: output_line1_from_asm
// Description:
//      does stuff
// =================================
.ent output_line1_from_asm
output_line1_from_asm:
addiu   sp, sp, -28
sw      ra, 24(sp)
sw      fp, 20(sp)
move    fp, sp
sw      s2, 16(fp)

move    s2, a0
bgt     s2, -1, abvZero
nop

li      t1, 0xFFFFFFFF
xor     a0, a0, t1          // flip the bits
addi    s2, a0, 1           // add 1
prtS    negSign

abvZero:
move    a0, s2
prt     printLoop
prtS    dfLiteral
prtS    newLine

lw      s1, 16(fp)
move    sp, fp
lw      ra, 24(sp)
lw      fp, 20(sp)
addiu   sp, sp, 28
jr      ra
nop
.end output_line1_from_asm
// =================================
// Subroutine: output_line2_from_asm
// Description:
//      does stuff
// =================================
.ent output_line2_from_asm
output_line2_from_asm:
addiu   sp, sp, -24
sw      ra, 20(sp)
sw      fp, 16(sp)
move    fp, sp

jal     get_celcius_int
nop
move    a0, v0
prt     printLoop1
prtS    period
move    a0, v1
prt     printLoop2
prtS    dcLiteral

move    sp, fp
lw      ra, 20(sp)
lw      fp, 16(sp)
addiu   sp, sp, 24

jr      ra
nop
.end output_line2_from_asm

// =================================
// Subroutine: get_celcius_int
// Description:
//      converts from degrees
//      fahrenheit to celcius
// Registers:
//      a0 - temp in fahrenheit/celcius frac
//      s0 - celcius int
//      t1 - bit mask
//      t2 - 5, for conversion
//      t3 - 100, for conversion
//      v0 - celcius int
//      v1 - celcius frac
// =================================
.ent get_celcius_int
get_celcius_int:
addiu   sp, sp, -28
sw      ra, 24(sp)
sw      fp, 20(sp)
move    fp, sp
sw      s0, 16(fp)

addi    s0, a0, -32         // s0 = F - 32

bgt     a0, 31, normal      // check if neg
nop

prtS    negSign
li      t1, 0xFFFFFFFF
xor     s0, s0, t1          // flip the bits
addi    s0, s0, 1           // add 1

normal:
li      t2, 5
li      t3, 100

mult    s0, t3              // s0 * 100 to make things easier
mflo    s0                  
mult    s0, t2              // s0 * 5
mflo    s0

div     s0, 9               // s0 / 9
div     s0, t3              // s0 / 100
mflo    s0                  // s0 = C
mfhi    a0                  // a0 = remainder

move    v0, s0
move    v1, a0

lw      s0, 16(fp)
move    sp, fp
lw      ra, 24(sp)
lw      fp, 20(sp)
addiu   sp, sp, 28

jr      ra
nop
.end get_celcius_int

// =================================
// Subroutine: flipSign
// Description:
//      converts unsigned binary int
//      to signed binary int
// Registers:
//      a0 - number to be flipped
//      t1 - bit mask
//      v0 - final answer
// =================================
.ent flipSign
flipSign:
addiu   sp, sp, -8
sw      ra, 4(sp)
sw      fp, 0(sp)
move    fp, sp

li      t1, 0xFFFFFFFF
xor     v0, a0, t1              // flip the bits
addi    v0, v0, 1               // add 1
prtS    negSign

move    sp, fp
lw      ra, 4(sp)
lw      sp, 0(sp)
addiu   sp, sp, 8
jr      ra
nop
.end flipSign

// =================================
// Subroutine: b_to_a
// Description:
//      converts binary valued
//      characters to ascii and stores
//      it into a byte array
// Registers:
//      a0 - number to be converted
//      t0 - digit converted to ascii
//      t1 - remainder of 'a0 / 10'
//      t8 - number of digits
//      t9 - address of byteArray
//      v0 - number of digits
// =================================
.ent b_to_a
b_to_a:
addiu   sp, sp, -8
sw      ra, 4(sp)
sw      fp, 0(sp)
move    fp, sp

la      t9, byteArray
li      t8, 0
convert:
divu    a0, 10
mfhi    t0
addiu   t0, t0, 0x30
addiu   fp, fp, -4
sw      t0, 0(fp)
mflo    t1
addiu   t8, t8, 1           // record number of digits
bnez    t1, convert         // keep dividing if quotient is non-zero
nop

move    v0, t8              // return number of digits
popAndStore:
// store values from stack frame onto byteArray
lb      t0, 0(fp)
addiu   fp, fp, 4
beqz    t8, leave
nop
sb      t0, 0(t9)
addiu   t9, t9, 4
addiu   t8, t8, -1
j       popAndStore
nop

leave:
move    fp, sp
lw      ra, 4(sp)
lw      fp, 0(sp)
addiu   sp, sp, 8

jr       ra
nop
.end b_to_a
// =================================
// Subroutine: output_string
// Description:
//      enables simulator to
//      display characters to the
//      "UART 1 Output"
// Registers:
//      a0 - address of desired output value
//      t0 - copy of a0
//      t1 - something
//      t9 - something2
// =================================
.ent output_string
output_string:
get_byte:
lb      t0, 0(a0)
beq     t0, zero, done
nop
send:
// send TX data
la      t9, U1TXREG
sw      t0, 0(t9)
la      t9, U1STA
wait_tx:
lw      t1, 0(t9)
andi    t1, t1, 0x100
beq     t1, zero, wait_tx
nop
next:
addu    a0, a0, 1
j       get_byte
nop
done:
j       ra
nop
.end output_string

dfLiteral:      .asciiz " degrees Fahrenheit is:"
newLine:        .asciiz "\n"
negSign:        .asciiz "-"
period:         .asciiz "."
dcLiteral:      .asciiz " degrees Celsius"

