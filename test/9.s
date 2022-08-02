# -*- LoongArch Assembly -*-
# ibar
.globl _start 
.type _start, @function
.text
.align 2 

_start:
    li.w $r10,0xa8
    csrwr $r10,0x0
    li.w $r31,21
    b end_nop
start_nop:
    nop
    nop
    li.w $r30,19260817
    beq $r31,$r30,end
    li.w $r1,0x12345678
    b error
end_nop:
    la.local $r5,inst1
    la.local $r6,start_nop
    ld.w $r10,$r5,0
    st.w $r10,$r6,0
    ld.w $r10,$r5,4
    st.w $r10,$r6,4
    ibar 0x0
    jirl $r0,$r6,0
    syscall 0x11

inst1:
    li.w $r31,19260817

end:
    li.w $r31,0xabcdef
error:
    syscall 0x11
