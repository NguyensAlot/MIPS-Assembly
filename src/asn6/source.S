// Anthony Nguyen
// CST250 - Lab 6

#include <xc.h>

.global main

.data
num:            .word 256
guess:          .space 8
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
add     sp, sp, -32
sw      ra, 28(sp)
sw      fp, 24(sp)
sw      s0, 20(sp)
sw      s1, 16(sp)
// configure UART TX
la      t9, U1MODESET
li      t0, 0x8000
sw      t0, 0(t9)
la      t9, U1STASET
li      t0, 0x1400
sw      t0, 0(t9)
// load num and guess
la      t3, num
lw      s0, 0(t3)
la      t3, guess
lw      s1, 0(t3)
srl     s1, s0, 1
// check if guess = 0
bgt     s1, 0, normal
nop
addiu   s1, s1, 1

normal:
prtS    numStr              // print string
move    a0, s0              // print num to be sqrted
prt     printLoop
prtS    newLine
prtS    newLine
// get square root
move    a0, s0              // move num into param
move    a1, s1              // move guess into param
jal     isqrt
nop
move    s1, v0

prtS    newLine
// output final line
prtS    finalStr            // "The isqrt of "
move    a0, s0              // ~num to be sqrted~
prt     printLoop2
prtS    finalStr2           // " is "
// check
move    a1, s1
jal     add_shift_mult
nop
blt     v0, s0, good
nop

addiu   s1, s1, -1

good:
move    a0, s1              // ~sqrt of num~
prt     printLoop3
prtS    finalStr3           // ". Check: "
move    a0, s1              // ~sqrt of num~
prt     printLoop4
prtS    finalStr4           // "^2 = "
// add_shift_mult call
move    a0, s0
move    a1, s1
jal     add_shift_mult
nop
move    a0, v0              // ~num to be sqrted~
prt     printLoop5
prtS    finalStr5           // ", "
addiu   t1, s1, 1
move    a0, t1              // ~sqrt of num + 1~
prt     printLoop6
prtS    finalStr4           // "^2 = "
// add_shift_mult call
addiu   t1, s1, 1
move    a0, s0
move    a1, t1
jal     add_shift_mult
nop
move    a0, v0              // ~(guess+1) sqr~
prt     printLoop7

end:
j       end
nop
.end main

//=================================
// Subroutine: isqrt
// Description:
//      finds the square root of a
//      number through refining
// Registers:
//      a0 - number to be sqrted
//      a1 - initial guess
//      s0 - number to be sqrted, unmodified
//      s1 - initial guess, next guess
//      s2 - number to be sqrted, volatile?
//      s3 - new-guess
//      s4 - guess before addition, for check
//      t1 - result of 'new-guess - guess'
//      t9 - result of 'num / guess'
//      v0 - final answer
//=================================
.ent isqrt
isqrt:
addiu   sp, sp, -44         // create stack frame
sw      ra, 40(sp)
sw      fp, 36(sp)
move    fp, sp
sw      s4, 32(fp)
sw      s3, 28(fp)
sw      s2, 24(fp)
sw      s1, 20(fp)
sw      s0, 16(fp)

move    s1, a1              // load guess into reg
move    s0, a0              // load num into reg
addiu   t5, t5, 1           // iteration count
isqrtLoop:
// output stuff
prtS    iterationStr        // "Iteration = "
move    a0, t5              // ~iteration count~
prt     printLoop8
prtS    guessStr            // " :: guess = "
move    a0, s1              // ~guess~
prt     printLoop9

// solving square root
move    s2, s0
divu    s2, s1              // num / guess
mflo    t9
move    s4, s1
addu    s1, s1, t9          // guess + (num/guess)
srl     s3, s1, 1           // new-guess

sub     t1, s3, s4
beq     t1, 1, shouldLeave
nop
// output stuff
prtS    newGuessStr         // " :: new_guess = "
move    a0, s3              // ~new_guess~
prt     printLoop10
prtS    newLine

// guess check
sub     t1, s3, s4          // new-guess - guess
move    a0, t1
jal     int_abs_val
nop
blt     v0, 2, leaveFunc    // compare new-guess to (num/guess)
nop

adjust:
move    s1, s3              // alter current guess
addiu   t5, t5, 1           // adjust iteration counter
j       isqrtLoop
nop
// incase new-guess > guess
shouldLeave:
prtS    newGuessStr         // " :: new_guess = "
move    a0, s4              // ~new_guess~
prt     printLoop11
prtS    newLine

move    v0, s4
j       leave4Real
nop
leaveFunc:
move    v0, s3

leave4Real:
lw      s4, 32(fp)          // destroy stack frame
lw      s3, 28(fp)
lw      s2, 24(fp)
lw      s1, 20(fp)
lw      s0, 16(fp)
move    sp, fp
lw      ra, 40(fp)
lw      fp, 36(fp)
addiu   fp, fp, 44

jr      ra
nop
.end isqrt
//=================================
// Subroutine: add_shift_mult
// Description:
//      multiplies two numbers by
//      shifting
// Registers:
//      a0 - num to be squared
//      a1 - initial guess
//      t1 - multiplicand
//      t2 - multiplier
//      t3 - product
//      t8 - check
//      t9 - number of loops
//      v0 - final answer
//=================================
.ent add_shift_mult
add_shift_mult:
move    t9, a1              
move    t1, a1              
move    t2, a1              
move    t3, zero
add_shift:
andi    t8, t2, 1
beq     t8, zero, go_on
nop
addu    t3, t3, t1
go_on:
sll     t1, t1, 1
srl     t2, t2, 1
addiu   t9, t9, -1
bgtz    t9, add_shift
nop

move    v0, t3

jr      ra
nop
.end add_shift_mult
//=================================
// Subroutine: int_abs_val
// Description:
//      gives the absolute value
//      of a negative number
// Registers:
//      zero - used to subtract from
//      a0 - num to be positive
//      t0 - zero
//      v0 - final answer
//=================================
.ent int_abs_val
int_abs_val:
move    t0, zero
sub     a0, t0, a0
move    v0, a0

jr      ra
nop
.end int_abs_val
//=================================
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
//=================================
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

newLine:        .asciiz "\n"
numStr:         .asciiz "n = "
iterationStr:   .asciiz "Iteration = "
guessStr:       .asciiz " :: guess = "
newGuessStr:    .asciiz " :: new_guess = "
finalStr:       .asciiz "The isqrt of "
finalStr2:      .asciiz " is "
finalStr3:      .asciiz ". Check: "
finalStr4:      .asciiz "^2 = "
finalStr5:      .asciiz ", "