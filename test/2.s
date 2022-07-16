# -*- LoongArch Assembly -*-
.text
.align 2
.globl _start
.type _start, @function

_start:
    #rdcntid.w $r4
    rdcntvl.w $r7
    rdcntvh.w $r8
    add.w $r1,$r2,$r3
    addi.w $r1,$r2,-33
    sub.w $r4,$r5,$r6
    slt $r7,$r8,$r9
    slti $r7,$r8,-2012
    sltu $r10,$r11,$r12
    sltui $r10,$r11,-204
    nor $r13,$r14,$r15
    and $r16,$r17,$r18
    andi $r16,$r17,2049
    or $r19,$r20,$r21
    ori $r19,$r20,2210
    xor $r22,$r23,$r24
    xori $r22,$r23,2400
    sll.w $r25,$r26,$r27
    slli.w $r25,$r26,12
    srl.w $r28,$r29,$r30
    srli.w $r28,$r29,3
    sra.w $r31,$r1,$r2
    srai.w $r31,$r1,8
    mul.w $r3,$r4,$r5
    mulh.w $r6,$r7,$r8
    mulh.wu $r9,$r10,$r11
    div.w $r12,$r13,$r14
    mod.w $r15,$r16,$r17
    div.wu $r18,$r19,$r20
    mod.wu $r21,$r22,$r23
    break 1926
    syscall 817
    ertn
    idle 3454
    lu12i.w $r24,-5241
    lu12i.w $r25,262143
    pcaddu12i $r26,-5242
    pcaddu12i $r27,262142
    ll.w $r1,$r2,144
    sc.w $r3,$r4,-336
    ld.b $r5,$r6,66
    ld.bu $r5,$r6,66
    ld.h $r7,$r8,-88
    ld.hu $r5,$r6,66
    ld.w $r9,$r10,100
    st.b $r11,$r12,-12
    st.w $r13,$r14,14
    preld 0,$r15,-15        # TODO: 表明preld
    dbar 0                  # TODO: 区分dbar和ibar
    ibar 0
    jirl $r16,$r17,340      # 最好处理jilr/b/bl
    jirl $r16,$r17,-340
    b 1220
    b -1220
    bl 3420
    bl -3420
    beq $r18,$r19,4
    bne $r19,$r20,-4
    blt $r21,$r22,44
    bge $r23,$r24,-220
    bltu $r25,$r26,232
    bgeu $r29,$r31,-996
    # csrrd $r24,34
    # csrwr $r25,35
    # csrxchg $r26,36
    # cacop ????
    # tlbsrch
    # tlbrd
    # tlbwr
    # tlbfill
    # invtlb
    # idle
    