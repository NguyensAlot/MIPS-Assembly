// Anthony Nguyen
// CST250 - Lab 8

#include <xc.h>

.global main

.data
byteArray:      .space 40
heading:        .asciiz "Address    F  E  D  C  B  A  9  8    7  6  5  4  3  2  1  0"
newLine:        .asciiz "\n"
separator:      .asciiz "========  =======================   ======================="
lowAddress:     .asciiz "A00000A4"
upAddress:      .asciiz "A00001FC"

.text
.set noreorder
//=================================
// Macro: prt
// Description:
//      outputs a number using
//      byteArray as the source
// Arguements:
//      printLoop - name of loop
// Registers:
//      a0 - value of t3 as param
//      t3 - address of byteArray
//      v0 - number of digits/loops
//=================================
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
//=================================
// Macro: prtS
// Description:
//      outputs a literal string
// Arguments:
//      string - address of string
// Registers:
//      a0 - value of t3 as param
//      t3 - address of string constant
//=================================
.macro prtS string
la      t3, \string
move    a0, t3
jal     output_string
nop
.endm
// main routine ===================
.ent main
main:
addiu   sp, sp, -8
sw      ra, 4(sp)
sw      fp, 0(sp)
// configure UART TX
la      t9, U1MODESET
li      t0, 0x8000
sw      t0, 0(t9)
la      t9, U1STASET
li      t0, 0x1400
sw      t0, 0(t9)

prtS    heading
prtS    newLine
prtS    separator
prtS    newLine


la      t0, upAddress
lb      t1, 0(t0)
move    a0, t1          // first value of ascii string
move    a1, t0          // address of ascii string
jal     asciihex_to_binary
nop

move    a0, v0
jal     binary_to_asciihex
nop


end:
j       end
nop
.end main
//=================================
// Subroutine: asciihex_to_binary
// Description:
//      does stuff
// Registers:
//=================================
.ent asciihex_to_binary
asciihex_to_binary:
addiu   sp, sp, -36
sw      ra, 32(sp)
sw      fp, 28(sp)
move    fp, sp
sw      s2, 24(fp)
sw      s1, 20(fp)
sw      s0, 16(fp)

move    s0, a0
move    s1, a1
la      s2, byteArray
loop:
move    a0, s0
jal     errorCheck
nop
blt     v0, 1, leaveFunc
nop
move    a0, s0
jal     asciidigit_to_binary
nop
li      t0, 16
multu   t0, s2
mflo    t0
addu    s2, t0, v0

nextDgt:
addiu   s1, s1, 1
lb      s0, 0(s1)
j       loop
nop

leaveFunc:
move    v0, s2

lw      s2, 24(fp)
lw      s1, 20(fp)
lw      s0, 16(fp)
move    sp, fp
lw      ra, 32(sp)
lw      fp, 28(sp)
addiu   sp, sp, 36

jr      ra
nop
.end asciihex_to_binary
//=================================
// Subroutine: asciidigit_to_binary
// Description:
//      does stuff
// Registers:
//=================================
.ent asciidigit_to_binary
asciidigit_to_binary:
// 0x30-0x39 = 0-9
// 0x41-0x46 = A-F
// 0x61-0x66 = a-f
addiu   sp, sp, -8
sw      ra, 4(sp)
sw      fp, 0(sp)
move    fp, sp

// upper check
blt     a0, 0x40, lowNum
nop
blt     a0, 0x47, lowCap
nop
blt     a0, 0x67, lowLow
nop
j       leaveFunc2
nop
// lower check
lowNum:
addiu   t0, a0, -0x30           // 0-9 check
bltz    t0, leaveFunc2
nop
addiu   v0, a0, -0x30
j       leaveFunc2
nop
lowCap:
addiu   t0, a0, -0x41           // A-F check
bltz    t0, leaveFunc2
nop
addiu   v0, a0, -0x37
j       leaveFunc2
nop
lowLow:
addiu   t0, a0, -0x61           // a-f check
bltz    t0, leaveFunc2
nop
addiu   v0, a0, -0x57

leaveFunc2:
move    sp, fp
lw      ra, 4(sp)
lw      fp, 0(sp)
addiu   sp, sp, 8

jr      ra
nop
.end asciidigit_to_binary
//=================================
// Subroutine: binary_to_asciihex
// Description:
//      does stuff
// Registers:
//=================================
.ent binary_to_asciihex
binary_to_asciihex:
addiu   sp, sp, -12
sw      ra, 8(sp)
sw      fp, 4(sp)
move    fp, sp
sw      s0, 0(fp)

la      s0, byteArray
li      t9, 15
li      t5, 1
convert2:
beqz    a0, popAndPrint
nop
and     t2, a0, t9
srl     a0, a0, 4
addiu   t5, t5, 1
bgt     t2, 9, toHexLetter
nop

// toNumber
addiu   t2, t2, 0x30
sb      t2, 0(s0)
addiu   s0, s0, 4
j       convert2
nop

toHexLetter:
addiu   t2, t2, 0x37
sb      t2, 0(s0)
addiu   s0, s0, 4
j       convert2
nop

popAndPrint:
beqz    t5, goHome
nop
move    a0, s0
jal     output_string
nop
addiu   s0, s0, -4
addiu   t5, t5, -1
beqz    t5, goHome
nop
j       popAndPrint
nop

goHome:
move    v0, s0

lw      s0, 0(fp)
move    sp, fp
lw      ra, 8(sp)
lw      fp, 4(sp)
addiu   sp, sp, 12

jr      ra
nop
.end binary_to_asciihex
//=================================
// Subroutine: errorCheck
// Description:
//      does stuff
// Registers:
//=================================
.ent errorCheck
errorCheck:
// 0x30-0x39 = 0-9
// 0x41-0x46 = A-F
// 0x61-0x66 = a-f
addiu   sp, sp, -8
sw      ra, 4(sp)
sw      fp, 0(sp)
move    fp, sp

// upper check
blt     a0, 0x40, lowNum2
nop
blt     a0, 0x47, lowCap2
nop
blt     a0, 0x67, lowLow2
nop
j       outBad
nop
// lower check
lowNum2:
addiu   t0, a0, -0x30           // 0-9 check
bltz    t0, outBad
nop
j       outGood
nop
lowCap2:
addiu   t0, a0, -0x41           // A-F check
bltz    t0, outBad
nop
j       outGood
nop
lowLow2:
addiu   t0, a0, -0x61           // a-f check
bltz    t0, outBad
nop
j       outGood
nop

outBad:
li      v0, -1
j       leaveFunc4
nop
outGood:
li      v0, 1
j       leaveFunc4
nop

leaveFunc4:
move    sp, fp
lw      ra, 4(sp)
lw      fp, 0(sp)
addiu   sp, sp, 8

jr      ra
nop
.end errorCheck
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
//=================================
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
//=================================
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
