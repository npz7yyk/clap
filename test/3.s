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
    add.w $r3, $r1, $r2
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    add.w $r4,$r0,$r2
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    sub.w $r5,$r0,$r2
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    addi.w $r1,$r0,5
    addi.w $r2,$r0,2
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    or $r10,$r1,$r2
    addi.w $r3,$r0,234
    addi.w $r4,$r0,1233
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    xor $r4,$r3,$r4
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    xor $r3,$r3,$r4
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    xor $r4,$r3,$r4
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    mul.w $r31,$r3,$r4
    sub.w $r4,$r0,$r4
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    mulh.wu $r30,$r3,$r4
    addi.w $r3,$r0,100
    addi.w $r4,$r1,9
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    div.w $r14,$r3,$r4
    mod.w $r15,$r3,$r4
