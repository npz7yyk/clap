	.file	"1.c"
	.text
	.align	2
	.globl	_start
	.type	_start, @function
_start:
.LFB0 = .
	addi.w	$r3,$r3,-80
.LCFI0 = .
	st.w	$r22,$r3,76
.LCFI1 = .
	addi.w	$r22,$r3,80
.LCFI2 = .
	addi.w	$r12,$r0,3			# 0x3
	st.w	$r12,$r22,-68
	addi.w	$r12,$r0,5			# 0x5
	st.w	$r12,$r22,-64
	addi.w	$r12,$r0,57			# 0x39
	st.w	$r12,$r22,-60
	addi.w	$r12,$r0,1			# 0x1
	st.w	$r12,$r22,-56
	addi.w	$r12,$r0,3			# 0x3
	st.w	$r12,$r22,-52
	addi.w	$r12,$r0,77			# 0x4d
	st.w	$r12,$r22,-48
	addi.w	$r12,$r0,66			# 0x42
	st.w	$r12,$r22,-44
	addi.w	$r12,$r0,12			# 0xc
	st.w	$r12,$r22,-40
	addi.w	$r12,$r0,66			# 0x42
	st.w	$r12,$r22,-36
	addi.w	$r12,$r0,12			# 0xc
	st.w	$r12,$r22,-32
	addi.w	$r12,$r0,-122			# 0xffffffffffffff86
	st.w	$r12,$r22,-28
	st.w	$r0,$r22,-20
	b	.L2
.L6:
	ld.w	$r12,$r22,-20
	addi.w	$r12,$r12,1
	st.w	$r12,$r22,-24
	b	.L3
.L5:
	ld.w	$r12,$r22,-20
	slli.w	$r12,$r12,2
	addi.w	$r13,$r22,-16
	add.w	$r12,$r13,$r12
	ld.w	$r13,$r12,-52
	ld.w	$r12,$r22,-24
	slli.w	$r12,$r12,2
	addi.w	$r14,$r22,-16
	add.w	$r12,$r14,$r12
	ld.w	$r12,$r12,-52
	ble	$r13,$r12,.L4
	ld.w	$r12,$r22,-20
	slli.w	$r12,$r12,2
	addi.w	$r13,$r22,-16
	add.w	$r12,$r13,$r12
	ld.w	$r13,$r12,-52
	ld.w	$r12,$r22,-24
	slli.w	$r12,$r12,2
	addi.w	$r14,$r22,-16
	add.w	$r12,$r14,$r12
	ld.w	$r12,$r12,-52
	xor	$r13,$r13,$r12
	ld.w	$r12,$r22,-20
	slli.w	$r12,$r12,2
	addi.w	$r14,$r22,-16
	add.w	$r12,$r14,$r12
	st.w	$r13,$r12,-52
	ld.w	$r12,$r22,-24
	slli.w	$r12,$r12,2
	addi.w	$r13,$r22,-16
	add.w	$r12,$r13,$r12
	ld.w	$r13,$r12,-52
	ld.w	$r12,$r22,-20
	slli.w	$r12,$r12,2
	addi.w	$r14,$r22,-16
	add.w	$r12,$r14,$r12
	ld.w	$r12,$r12,-52
	xor	$r13,$r13,$r12
	ld.w	$r12,$r22,-24
	slli.w	$r12,$r12,2
	addi.w	$r14,$r22,-16
	add.w	$r12,$r14,$r12
	st.w	$r13,$r12,-52
	ld.w	$r12,$r22,-20
	slli.w	$r12,$r12,2
	addi.w	$r13,$r22,-16
	add.w	$r12,$r13,$r12
	ld.w	$r13,$r12,-52
	ld.w	$r12,$r22,-24
	slli.w	$r12,$r12,2
	addi.w	$r14,$r22,-16
	add.w	$r12,$r14,$r12
	ld.w	$r12,$r12,-52
	xor	$r13,$r13,$r12
	ld.w	$r12,$r22,-20
	slli.w	$r12,$r12,2
	addi.w	$r14,$r22,-16
	add.w	$r12,$r14,$r12
	st.w	$r13,$r12,-52
.L4:
	ld.w	$r12,$r22,-24
	addi.w	$r12,$r12,1
	st.w	$r12,$r22,-24
.L3:
	ld.w	$r13,$r22,-24
	addi.w	$r12,$r0,9			# 0x9
	ble	$r13,$r12,.L5
	ld.w	$r12,$r22,-20
	addi.w	$r12,$r12,1
	st.w	$r12,$r22,-20
.L2:
	ld.w	$r13,$r22,-20
	addi.w	$r12,$r0,8			# 0x8
	ble	$r13,$r12,.L6
	st.w	$r0,$r22,-28
	b	.L7
.L10:
	ld.w	$r12,$r22,-28
	slli.w	$r12,$r12,2
	addi.w	$r13,$r22,-16
	add.w	$r12,$r13,$r12
	ld.w	$r13,$r12,-52
	ld.w	$r12,$r22,-28
	addi.w	$r12,$r12,1
	slli.w	$r12,$r12,2
	addi.w	$r14,$r22,-16
	add.w	$r12,$r14,$r12
	ld.w	$r12,$r12,-52
	ble	$r13,$r12,.L8
	addi.w	$r12,$r0,1			# 0x1
	b	.L11
.L8:
	ld.w	$r12,$r22,-28
	addi.w	$r12,$r12,1
	st.w	$r12,$r22,-28
.L7:
	ld.w	$r13,$r22,-28
	addi.w	$r12,$r0,8			# 0x8
	ble	$r13,$r12,.L10
	or	$r12,$r0,$r0
.L11:
	or	$r4,$r12,$r0
	ld.w	$r22,$r3,76
.LCFI3 = .
	addi.w	$r3,$r3,80
.LCFI4 = .
	jr	$r1
.LFE0:
	.size	_start, .-_start
	.section	.eh_frame,"aw",@progbits
.Lframe1:
	.4byte	.LECIE1-.LSCIE1
.LSCIE1:
	.4byte	0
	.byte	0x3
	.ascii	"\000"
	.byte	0x1
	.byte	0x7c
	.byte	0x1
	.byte	0xc
	.byte	0x3
	.byte	0
	.align	2
.LECIE1:
.LSFDE1:
	.4byte	.LEFDE1-.LASFDE1
.LASFDE1:
	.4byte	.LASFDE1-.Lframe1
	.4byte	.LFB0
	.4byte	.LFE0-.LFB0
	.byte	0x4
	.4byte	.LCFI0-.LFB0
	.byte	0xe
	.byte	0x50
	.byte	0x4
	.4byte	.LCFI1-.LCFI0
	.byte	0x96
	.byte	0x1
	.byte	0x4
	.4byte	.LCFI2-.LCFI1
	.byte	0xc
	.byte	0x16
	.byte	0
	.byte	0x4
	.4byte	.LCFI3-.LCFI2
	.byte	0xd6
	.byte	0x4
	.4byte	.LCFI4-.LCFI3
	.byte	0xd
	.byte	0x3
	.align	2
.LEFDE1:
	.ident	"GCC: (小步快跑 Clap 8.3.0-20220602ubuntu1~20.04) 8.3.0"
	.section	.note.GNU-stack,"",@progbits
