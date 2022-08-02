# -*- LoongArch Assembly -*-
# tlb
# 虚地址2c002xxx -> 实地址1c003xxx
#       2c003xxx ->       1c002xxx
# 进入用户态前
# 实地址[1c002000]=20220802  [1c003000]=19260817
# 虚地址[2c003000]=20220802  [2c002000]=19260817
# 在中断处理程序中填入
# 实地址[1c002004]=12345678  [1c003004]=87654321
.globl _start
.type _start, @function
.text
.align 2

_start:
    li.w $r10,0xa8 # plv=0,ie=0,da=1,pg=0,datf=1,datm=1
    csrwr $r10,0x0
    li.w $r9,0x1c002000
    li.w $r8,20220802
    st.w $r8,$r9,0
    li.w $r9,0x1c003000
    li.w $r8,19260817
    st.w $r8,$r9,0
    la.local $r10,tlbrefill
    csrwr $r10,0x88
    la.local $r10,exception
    csrwr $r10,0x0c
    li.w $r10,0x00000019
    csrwr $r10,0x180  # dmw0
    li.w $r10,0xb0  # plv=0,ie=0,da=0,pg=1,datf=1,datm=1
    li.w $r11,0x3   # pplv=3, pie=0
    la.local $r12,user_program # era
    csrwr $r10,0x0
    csrwr $r11,0x1
    csrwr $r12,0x6
    ertn

# (使用寄存器2~9, 31)
user_program:
    li.w $r2,0x2c003000
    ld.w $r3,$r2,0 # TLBR exception
    li.w $r4,20220802
    bne $r4,$r3,error
    ld.w $r3,$r2,4
    li.w $r4,12345678
    bne $r3,$r4,error
    li.w $r2,0x2c002000
    ld.w $r3,$r2,0
    li.w $r4,19260817
    bne $r4,$r3,error
    ld.w $r3,$r2,4
    li.w $r4,87654321
    bne $r3,$r4,error
    li.w $r31,0x5678
    syscall 0x0
error:
    li.w $r31,0x1234
    syscall 0x0

# (使用寄存器 10~19)
.align 6
tlbrefill:
    li.w $r17,0x1c002004
    li.w $r18,12345678
    st.w $r18,$r17,0
    li.w $r17,0x1c003004
    li.w $r18,87654321
    st.w $r18,$r17,0
    li.w $r10,0x0c000000  # tlbidx.ps = 12
    li.w $r11,0x2c002000 # vpn = 0x2c002
    li.w $r12,0x01c0035d # ppn = 0x1c003, g=1 mat=1 plv=3 v=1
    li.w $r13,0x01c0025d # ppn = 0x1c002, g=1 mat=1 plv=3 v=1
    csrwr $r10,0x10
    csrwr $r12,0x12
    csrwr $r13,0x13
    csrrd $r14,0x11
    bne $r14,$r11,error_sys
    tlbfill
    ertn
error_sys:
    li.w $r31,0x12340000
    idle 0x0
.align 6
exception:
    idle 0x0
