`define CRMD        14'h000 //当前模式信息 
`define PRMD        14'h001 //例外前模式信息
`define EUEN        14'h002 //拓展部件使能
`define ECFG        14'h004 //例外配置
`define ESTAT       14'h005 //例外状态
`define ERA         14'h006 //例外返回地址
`define BADV        14'h007 //出错虚地址
`define EENTRY      14'h00C //例外入口地址
`define TLBIDX      14'h010 //TLB索引
`define TLBEHI      14'h011 //TLB表项高位
`define TLBEHO0     14'h012 //TLB表项低位0
`define TLBEHO1     14'h013 //TLB表项低位1
`define ASID        14'h018 //地址空间标识符
`define PGDL        14'h019 //低半地址空间全局目录基址
`define PGDH        14'h01A //高半地址空间全局目录基址
`define PGD         14'h01B //全局目录基址
`define CPUID       14'h020 //处理器编号
`define SAVE0       14'h030 //数据保存
`define SAVE1       14'h031 //数据保存
`define SAVE2       14'h032 //数据保存
`define SAVE3       14'h033 //数据保存
`define TID         14'h040 //定时器编号
`define TCFG        14'h041 //定时器配置
`define TVAL        14'h042 //定时器值
`define CNTC        14'h43  //计数器值
`define TICLR       14'h044 //定时器中断清除
`define LLBCTL      14'h060 //LLBit控制
`define TLBRENTRY   14'h088 //TLB重填例外入口地址
`define CTAG        14'h098 //高速缓存标签
`define DMW0        14'h180 //直接映射配置窗口
`define DMW1        14'h181 //直接映射配置窗口

//CRMD
`define PLV       1:0
`define IE        2
`define DA        3
`define PG        4
`define DATF      6:5
`define DATM      8:7
//PRMD
`define PPLV      1:0
`define PIE       2
//ECTL
`define LIE       12:0
//ESTAT
`define IS        12:0
`define ECODE     21:16
`define ESUBCODE  30:22
//TLBIDX
`define INDEX     4:0
`define PS        29:24
`define NE        31
//TLBEHI
`define VPPN      31:13
//TLBELO
`define TLB_V      0
`define TLB_D      1
`define TLB_PLV    3:2
`define TLB_MAT    5:4
`define TLB_G      6
`define TLB_PPN    31:8
`define TLB_PPN_EN 27:8   //todo
//ASID
`define TLB_ASID  9:0
//CPUID
`define COREID    8:0
//LLBCTL
`define ROLLB     0
`define WCLLB     1
`define KLO       2
//TCFG
`define EN        0
`define PERIODIC  1
`define INITVAL   31:2
//TICLR
`define CLR       0
//TLBRENTRY
`define TLBRENTRY_PA 31:6
//DMW
`define PLV0      0
`define PLV3      3 
`define DMW_MAT   5:4
`define PSEG      27:25
`define VSEG      31:29
//PGDL PGDH PGD
`define BASE      31:12

`define ECODE_INT  6'h0
`define ECODE_PIL  6'h1
`define ECODE_PIS  6'h2
`define ECODE_PIF  6'h3
`define ECODE_PME  6'h4
`define ECODE_PPI  6'h7
`define ECODE_ADEF 6'h8
`define ECODE_ADEM 6'h8
`define ECODE_ALE  6'h9
`define ECODE_SYS  6'hb
`define ECODE_BRK  6'hc
`define ECODE_INE  6'hd
`define ECODE_IPE  6'he
`define ECODE_FPD  6'hf
`define ECODE_TLBR 6'h3f

`define ESUBCODE_ADEF  9'h0
`define ESUBCODE_ADEM  9'h1

