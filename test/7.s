# -*- LoongArch Assembly -*-
# branch
.globl _start 
.type _start, @function
.text
.align 2

_start:
    li.w $r2,19260817
    csrwr $r2,0x30
    li.w $r4,19890604
    csrwr $r4,0x30
    csrrd $r3,0x30
