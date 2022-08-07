// -*- LoongArch Assembly -*-
// _go

# define zero	$r0
# define ra	$r1
# define tp	$r2
# define sp	$r3
# define a0	$r4
# define a1	$r5
# define a2	$r6
# define a3	$r7
# define a4	$r8
# define a5	$r9
# define a6	$r10
# define a7	$r11
# define v0	$r4
# define v1	$r5 
# define t0	$r12
# define t1	$r13
# define t2	$r14
# define t3	$r15
# define t4	$r16
# define t5	$r17
# define t6	$r18
# define t7	$r19
# define t8	$r20
# define x	$r21
# define fp	$r22
# define s0	$r23
# define s1	$r24
# define s2	$r25
# define s3	$r26
# define s4	$r27
# define s5	$r28
# define s6	$r29
# define s7	$r30
# define s8	$r31

#define csr_crmd      0x0
#define csr_prmd      0x1
#define csr_euen      0x2
#define csr_ectl      0x4
#define csr_estat     0x5
#define csr_era       0x6
#define csr_badv      0x7
#define csr_eentry     0xc
#define csr_tlbidx    0x10
#define csr_tlbehi    0x11
#define csr_tlbelo0    0x12
#define csr_tlbelo1    0x13
#define csr_asid      0x18
#define csr_pgdl      0x19
#define csr_pgdh      0x1a
#define csr_pgd       0x1b
#define csr_cpuid    0x20
#define csr_save0     0x30
#define csr_save1     0x31
#define csr_save2     0x32
#define csr_save3     0x33
#define csr_tid       0x40
#define csr_tval      0x42
#define csr_ticlr     0x44
#define csr_llbctl    0x60
#define csr_tlbrentry 0x88
#define csr_ctag      0x98
#define csr_dmw0      0x180
#define csr_dmw1      0x181

#define ZERO 0 
#define RA   1  
#define TP   2 
#define SP   3 
#define A0   4  
#define A1   5 
#define A2   6 
#define A3   7 
#define A4   8 
#define A5   9 
#define A6   10 
#define A7   11 
#define T0   12 
#define T1   13 
#define T2   14
#define T3   15 
#define T4   16 
#define T5   17 
#define T6   18 
#define T7   19 
#define T8   20  
#define X    21 
#define FP   22 
#define S0   23
#define S1   24
#define S2   25
#define S3   26
#define S4   27
#define S5   28
#define S6   29
#define S7   30
#define S8   31  

#define CRMD 32 
#define PRMD 33
#define ECTL 34
#define ESTAT 35 
#define ERA  36
#define BADV 37 
#define EENTRY 38 
#define LLBCTL 39 
#define TLBIDX 40
#define TLBEHI 41
#define TLBELO0 42
#define TLBELO1 43 

#define RSIZE 4

.globl _start
.type _start, @function
.text
.align 2


_start:
    li.w $r10,0xa8 // plv=0,ie=0,da=1,pg=0,datf=1,datm=1
    csrwr $r10,0x0
    la      x, DBGREG 
    ld.w    t0, x, ESTAT * RSIZE 
    csrwr   t0, csr_estat 
    ld.w    t0, x, ECTL * RSIZE 
    csrwr   t0, csr_ectl 
    ld.w    t0, x, ERA * RSIZE
    csrwr   t0, csr_era 
    ld.w    t0, x, PRMD * RSIZE
    csrwr   t0, csr_prmd 
    ld.w    t0, x, CRMD * RSIZE
    csrwr   t0, csr_crmd 

    ld.w    ra, x, RA * RSIZE
    ld.w    tp, x, TP * RSIZE
    ld.w    sp, x, SP * RSIZE
    ld.w    a0, x, A0 * RSIZE
    ld.w    a1, x, A1 * RSIZE
    ld.w    a2, x, A2 * RSIZE
    ld.w    a3, x, A3 * RSIZE
    ld.w    a4, x, A4 * RSIZE
    ld.w    a5, x, A5 * RSIZE
    ld.w    a6, x, A6 * RSIZE
    ld.w    a7, x, A7 * RSIZE
    ld.w    t0, x, T0 * RSIZE
    ld.w    t1, x, T1 * RSIZE
    ld.w    t2, x, T2 * RSIZE
    ld.w    t3, x, T3 * RSIZE
    ld.w    t4, x, T4 * RSIZE
    ld.w    t5, x, T5 * RSIZE
    ld.w    t6, x, T6 * RSIZE
    ld.w    t7, x, T7 * RSIZE
    ld.w    t8, x, T8 * RSIZE
    ld.w    fp, x, FP * RSIZE
    ld.w    s0, x, S0 * RSIZE
    ld.w    s1, x, S1 * RSIZE
    ld.w    s2, x, S2 * RSIZE
    ld.w    s3, x, S3 * RSIZE
    ld.w    s4, x, S4 * RSIZE
    ld.w    s5, x, S5 * RSIZE
    ld.w    s6, x, S6 * RSIZE
    ld.w    s7, x, S7 * RSIZE
    ld.w    s8, x, S8 * RSIZE
    ld.w    x, x, X * RSIZE 

    ertn

.data
DBGREG:
    .word  0x00000000 #define ZERO 0     register_t zero;
    .word  0x07067888 #define RA   1     register_t ra;
    .word  0x00000000 #define TP   2     register_t tp;
    .word  0x07dfff58 #define SP   3     register_t sp;
    .word  0x00000002 #define A0   4     register_t a0;
    .word  0xa4f00000 #define A1   5     register_t a1;
    .word  0xa4f00040 #define A2   6     register_t a2;
    .word  0x00000000 #define A3   7     register_t a3;
    .word  0x00000000 #define A4   8     register_t a4;
    .word  0x00000000 #define A5   9     register_t a5;
    .word  0x00000000 #define A6   10    register_t a6;
    .word  0x00000000 #define A7   11    register_t a7;
    .word  0x00000000 #define T0   12    register_t t0;
    .word  0x00000000 #define T1   13    register_t t1;
    .word  0x00000000 #define T2   14    register_t t2;
    .word  0x00000000 #define T3   15    register_t t3;
    .word  0x00000000 #define T4   16    register_t t4;
    .word  0x00000000 #define T5   17    register_t t5;
    .word  0x00000000 #define T6   18    register_t t6;
    .word  0x00000000 #define T7   19    register_t t7;
    .word  0x00000000 #define T8   20    register_t t8;
    .word  0x00000000 #define X    21    register_t x;
    .word  0x00000000 #define FP   22    register_t fp;
    .word  0x00000000 #define S0   23    register_t s0;
    .word  0x00000000 #define S1   24    register_t s1;
    .word  0x00000000 #define S2   25    register_t s2;
    .word  0x00000000 #define S3   26    register_t s3;
    .word  0x00000000 #define S4   27    register_t s4;
    .word  0x00000000 #define S5   28    register_t s5;
    .word  0x00000000 #define S6   29    register_t s6;
    .word  0x00000000 #define S7   30    register_t s7;
    .word  0x00000000 #define S8   31    register_t s8; 
    .word  0x00000000 #define CRMD 32    register_t crmd;
    .word  0x00000000 #define PRMD 33    register_t prmd;
    .word  0x00000000 #define ECTL 34    register_t ectl;
    .word  0x00000000 #define ESTAT 35   register_t estat;
    .word  0xa07c5c28 #define ERA  36    register_t era;
    .word  0x00000000 #define BADV 37    register_t badv;
    .word  0x00000000 #define EENTRY 38  register_t eentry;
    .word  0x00000000 #define LLBCTL 39  register_t llbctl;
    .word  0x00000000 #define TLBIDX 40  register_t tlbidx;
    .word  0x00000000 #define TLBEHI 41  register_t tlbehi;
    .word  0x00000000 #define TLBELO0 42 register_t tlbelo0;
    .word  0x00000000 #define TLBELO1 43 register_t tlbelo1;
