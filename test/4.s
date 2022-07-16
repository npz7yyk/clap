# -*- LoongArch Assembly -*-
# arithmeic instructions with data hazards
.globl _start 
.type _start, @function
.text
.align 2

_start:
    addi.w $r1, $r0, 10
    addi.w $r2, $r0, 11
    add.w $r0, $r1, $r2
    add.w $r3, $r1, $r2
    add.w $r4,$r0,$r2
    sub.w $r5,$r0,$r2
    addi.w $r1,$r0,5
    addi.w $r2,$r0,2
    or $r10,$r1,$r2
    addi.w $r3,$r0,234
    addi.w $r4,$r0,1233
    xor $r4,$r3,$r4
    xor $r3,$r3,$r4
    xor $r4,$r3,$r4
    mul.w $r31,$r3,$r4
    ori $r29,$r31,5
    sub.w $r4,$r0,$r4
    mulh.wu $r30,$r3,$r4
    addi.w $r3,$r0,100
    addi.w $r4,$r0,9
    div.w $r14,$r3,$r4
    add.w $r17,$r14,$r0
    mod.w $r15,$r3,$r4
    add.w $r16,$r15,$r0
    slt $r1,$r16,$r17
    sll.w $r2,$r1,$r15
    slli.w $r2,$r2,5
    srl.w $r2,$r2,$r17
