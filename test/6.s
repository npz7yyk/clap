# -*- LoongArch Assembly -*-
# branch
.globl _start 
.type _start, @function
.text
.align 2

_start:
    addi.w $r1,$r0,10
    addi.w $r5,$r0,1989
    add.w $r2,$r0,$r0
.L1:
    addi.w $r2,$r2,5
    addi.w $r1,$r1,-1
    bne $r1,$r0,.L1
    addi.w $r31,$r2,0   # r31 = 50
    addi.w $r2,$r0,10
    addi.w $r3,$r0,1
    addi.w $r1,$r0,1
.L2:
    beq $r3,$r2,.L3
    mul.w $r1,$r3,$r1
    # mod.w $r1,$r1,$r5
    addi.w $r3,$r3,1
    b .L2
.L3:
    add.w $r30,$r1,$r0  # r30 = 10! mod 1989
    addi.w $r1,$r0,10
    addi.w $r2,$r0,1
    addi.w $r3,$r0,0
.L6:
    bge $r2,$r1,.L4
    andi $r4,$r2,1
    beq $r4,$r0,.L5
    add.w $r3,$r2,$r3
.L5:
    addi.w $r2,$r2,1
    b .L6
.L4:
    add.w $r29,$r3,$r0  # r29 = 1+3+..+9 = 25
