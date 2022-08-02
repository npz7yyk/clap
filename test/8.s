# -*- LoongArch Assembly -*-
# mod after div
.globl _start 
.type _start, @function
.text
.align 2 

_start:
    li.w $r10,0xa8
    csrwr $r10,0x0
    li.w $r9,0
    li.w $r23,0x80
    li.w $r16,0x10
    li.w $r28,0x1000
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    sll.w $r6,$r28,$r9
    div.wu $r4,$r6,$r16
    mod.wu $r6,$r6,$r23
    syscall 0x11
