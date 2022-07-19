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
`define TICLR       14'h044 //定时器中断清除
`define LLBCTL      14'h060 //LLBit控制
`define TLBRENTRY   14'h088 //TLB重填例外入口地址
`define CTAG        14'h098 //高速缓存标签
`define DMW0        14'h180 //直接映射配置窗口
`define DMW1        14'h181 //直接映射配置窗口

//CRMD
`define CRMD_PLV    1:0     //当前特权等级。0: highest, 3: lowest
`define CRMD_IE     2:2     //当前中断使能
`define CRMD_DA     3:3     //直接地址翻译模式使能
`define CRMD_PG     4:4     //映射地址翻译模式的使能
`define CRMD_DATF   6:5     //直接地址翻译模式时，取值操作的存储访问类型
`define CRMDDATM    8:7     //直接地址翻译模式时，load/store操作的存储访问类型
//PRMD
`define PRMD_PPLV   1:0     //例外发生前的特权模式
`define PRMD_PIE    2:2     //例外发生前的中断使能
//EUEN
`define EUEN_FPE    0:0     //基础浮点指令使能控制位
//ECFG
`define ECFG_LIE    12:0    //局部中断使能
//ESTAT
`define ESTAT_IS_0  1:0     //中断状态位
`define ESTAT_IS_1  12:2
`define ESTAT_ECODE 21:16
`define ESTAT_ESUBCODE 30:22
//EENTRY
`define EENTRY_VA   31:6
//TLBRENTRY
`define TLBRENTRY_PA 31:6
//LLBCTL
`define LLBCTL_ROLLB  0:0
`define LLBCTL_WCLLB  1:1
`define LLBCTL_KLO    2:2
//TLBIDX
`define TLBIDX_INDEX 15:0
`define TLBIDX_PS   29:24
`define TLBIDX_NE   31:31
//TLBEHI
`define TLBEHI_VPPN 31:13
//TLBELO
`define TLBELO_V      0:0
`define TLBELO_D      1:1
`define TLBELO_PLV    3:2
`define TLBELO_MAT    5:4
`define TLBELO_G      6:6
`define TLBELO_PPN    31:8
//ASID
`define ASID_ASID     9:0
`define ASID_ASIDBITS 23:16
//PGDL PGDH PGD
`define PGD_BASE   31:12
//DMW
`define DMW_PLV0  0:0
`define DMW_PLV3  3:3 
`define DMW_MAT   5:4
`define DMW_PSEG  27:25
`define DMW_VSEG  31:29
//TCFG
`define TCFG_EN        0:0
`define TCFG_PERIODIC  1:1
`define TCFG_INITVAL   31:2
//TICLR
`define TICLR_CLR       0:0
