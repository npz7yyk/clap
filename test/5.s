# load and store instructions without data hazards
.globl _start 
.type _start, @function
.text
.align 2

_start:
    la.local $r31,int2
    ld.w $r1,$r31,0     # 19260817
    la.local $r31,char1
    ld.b $r2,$r31,0     # -1
    ld.bu $r3,$r31,0    # 255
    la.local $r31,short1
    ld.h $r4,$r31,0     # -32767
    ld.hu $r5,$r31,0    # 32769
    la.local $r31,int1
    addi.w $r1,$r0,100
    addi.w $r2,$r0,101
    addi.w $r3,$r0,102
    addi.w $r4,$r0,103
    addi.w $r5,$r0,104
    addi.w $r6,$r0,105
    addi.w $r7,$r0,106
    addi.w $r8,$r0,107
    addi.w $r9,$r0,108
    addi.w $r10,$r0,109
    addi.w $r11,$r0,110
    st.w $r1,$r31,0
    st.w $r2,$r31,4
    st.w $r3,$r31,8
    st.w $r4,$r31,12
    st.w $r5,$r31,16
    st.w $r6,$r31,20
    st.w $r7,$r31,24
    st.w $r8,$r31,28
    st.w $r9,$r31,32
    st.w $r10,$r31,36
    st.w $r11,$r31,40
    xor $r1,$r1,$r1
    sub.w $r2,$r2,$r2
    andi $r3,$r3,0
    and $r4,$r4,$r0
    mul.w $r5,$r5,$r0
    div.w $r30,$r6,$r6
    mod.w $r6,$r6,$r30
    slli.w $r7,$r7,31
    srli.w $r8,$r8,31
    slli.w $r7,$r7,1
    srli.w $r8,$r8,1
    add.w $r9,$r0,$r0
    add.w $r10,$r0,$r0
    add.w $r11,$r0,$r0
    ld.w $r1,$r31,0         # 100
    ld.w $r2,$r31,4         # 101
    ld.w $r3,$r31,8         # 102
    ld.w $r4,$r31,12        # 103
    ld.w $r5,$r31,16        # 104
    ld.w $r6,$r31,20        # 105
    ld.w $r7,$r31,24        # 106
    ld.w $r8,$r31,28        # 107
    ld.w $r9,$r31,32        # 108
    ld.w $r10,$r31,36       # 109
    ld.w $r11,$r31,40       # 110

.data
.align 2
int1:
    .space 44
int2:
    .word 19260817
.align 0
char1:
    .byte 0xFF
.align 1
short1:
    .short -32767
