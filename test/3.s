.globl _start 
.type _start, @function
.text
.align 2

_start:
    addi.w $r1, $r0, 10
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    addi.w $r2, $r0, 11
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    add.w $r0, $r1, $r2
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    add.w $r2,$r0,$r2
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
