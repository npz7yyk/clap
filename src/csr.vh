`define CSR_CRMD        14'h000 //当前模式信息 
`define CSR_PRMD        14'h001 //例外前模式信息
`define CSR_EUEN        14'h002 //拓展部件使能
`define CSR_ECFG        14'h004 //例外配置
`define CSR_ESTAT       14'h005 //例外状态
`define CSR_ERA         14'h006 //例外返回地址
`define CSR_BADV        14'h007 //出错虚地址
`define CSR_EENTRY      14'h00C //例外入口地址
`define CSR_TLBIDX      14'h010 //TLB索引
`define CSR_TLBEHI      14'h011 //TLB表项高位
`define CSR_TLBEHO0     14'h012 //TLB表项低位0
`define CSR_TLBEHO1     14'h013 //TLB表项低位1
`define CSR_ASID        14'h018 //地址空间标识符
`define CSR_PGDL        14'h019 //低半地址空间全局目录基址
`define CSR_PGDH        14'h01A //高半地址空间全局目录基址
`define CSR_PGD         14'h01B //全局目录基址
`define CSR_CPUID       14'h020 //处理器编号
`define CSR_SAVE0       14'h030 //数据保存
`define CSR_SAVE1       14'h031 //数据保存
`define CSR_SAVE2       14'h032 //数据保存
`define CSR_SAVE3       14'h033 //数据保存
`define CSR_TID         14'h040 //定时器编号
`define CSR_TCFG        14'h041 //定时器配置
`define CSR_TVAL        14'h042 //定时器值
`define CSR_TICLR       14'h044 //定时器中断清除
`define CSR_LLBCTL      14'h060 //LLBit控制
`define CSR_TLBRENTRY   14'h088 //TLB重填例外入口地址
`define CSR_CTAG        14'h098 //高速缓存标签
`define CSR_DMW0        14'h180 //直接映射配置窗口
