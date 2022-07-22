// -*- Verilog -*-
`include "csr.vh"

//TODO: reset all CSRs
module csr
#(
    COREID = 0,
    ASIDBITS = 10,
    TLBIDX_WIDTH = 4,
    TIMER_WIDTH = 32
)
(
    input clk,
    input rstn,
    //software query port (exe stage)
    input software_query_en,
    input  [13:0] addr,
    output reg [31:0] rdata,//read first
    input  [31:0] wen,      //bit write enable
    input  [31:0] wdata,
    
    //current machine state
    output [1:0] privilege,

    //exception
    input store_state,      //pplv <= plv , pie <= ie 
    input restore_state,    //plv  <= pplv, ie  <= pie
    input [6:0] expcode_in,
    input expcode_wen,
    output [31:0] era_out,
    input [31:0] era_in,
    input era_wen,
    input [31:0] badv_in,
    input badv_wen,
    output [31:0] eentry,tlbrentry,
    input [31:0] pgd_in,
    input pgd_wen,

    //interrupt
    output has_interrupt,
    input [7:0] hardware_int,

    //MMU
    output [1:0] translate_mode,    //01: direct, 10: paged
    output direct_i_mat, //处于直接地址翻译模式时，存储访问类型
    output direct_d_mat, //0: 非缓存, 1: 可缓存
    //直接映射窗口0
    output reg dmw0_plv0,
    output reg dmw0_plv3,
    output reg dmw0_mat,
    output reg [31:29] dmw0_vseg,dmw0_pseg,
    //直接映射窗口1
    output reg dmw1_plv0,
    output reg dmw1_plv3,
    output reg dmw1_mat,
    output reg [31:29] dmw1_vseg,dmw1_pseg,
    //TLB (read port)
    output [TLBIDX_WIDTH-1:0] tlb_index_out,
    output [5:0] tlb_ps_out,
    output tlb_ne_out,
    output [18:0] tlb_vppn_out,
    output tlb_valid_0_out,             tlb_valid_1_out,
    output tlb_dirty_0_out,             tlb_dirty_1_out,
    output [1:0] tlb_priviledge_0_out,  tlb_priviledge_1_out,
    output tlb_mat_0_out,         tlb_mat_1_out,
    output tlb_global_0_out,            tlb_global_1_out,
    output [23:0] tlb_ppn_0_out,        tlb_ppn_1_out,
    output [9:0] asid_out,
    output [31:0] pgdl_out,pgdh_out,
    
    //TLB (write port)
    input [TLBIDX_WIDTH-1:0] tlb_index_in,
    input tlb_index_we,
    input [5:0] tlb_ps_in,
    input tlb_ps_we,
    input tlb_ne_in,
    input tlb_ne_we,
    input [18:0] tlb_vppn_in,
    input tlb_vppn_we,
    input tlb_valid_0_in,               tlb_valid_1_in,
    input tlb_valid_0_wen,              tlb_valid_1_wen,
    input tlb_dirty_0_in,               tlb_dirty_1_in,
    input tlb_dirty_0_wen,              tlb_dirty_1_wen,
    input [1:0] tlb_priviledge_0_in,    tlb_priviledge_1_in,
    input tlb_priviledge_0_wen,         tlb_priviledge_1_wen,
    input tlb_mat_0_in,                 tlb_mat_1_in,
    input tlb_mat_0_wen,                tlb_mat_1_wen,
    input tlb_global_0_in,              tlb_global_1_in,
    input tlb_global_0_wen,             tlb_global_1_wen,
    input [23:0] tlb_ppn_0_in,          tlb_ppn_1_in,
    input tlb_ppn_0_wen,                tlb_ppn_1_wen,
    input [9:0] asid_in,
    input asid_wen,

    //ll bit
    output llbit,
    input llbit_set,
    input llbit_clear_by_eret,
    input llbit_clear_by_other,

    //timer
    output [31:0] tid,

    //cache tag
    output [31:0] cache_tag
);
    reg timer_int;      //定时器中断
    ///////////////////////////////////////
    //control state registers defination
    //CRMD
    reg [`CRMD_PLV]     crmd_plv;
    reg [`CRMD_IE]      crmd_ie;
    reg [`CRMD_DA]      crmd_da;
    reg [`CRMD_PG]      crmd_pg;
    reg [`CRMD_DATF]    crmd_datf;
    reg [`CRMD_DATM]    crmd_datm;
    wire [31:0] csr_crmd;
    assign csr_crmd[`CRMD_PLV]  = crmd_plv;
    assign csr_crmd[`CRMD_IE]   = crmd_ie;
    assign csr_crmd[`CRMD_DA]   = crmd_da;
    assign csr_crmd[`CRMD_PG]   = crmd_pg;
    assign csr_crmd[`CRMD_DATF] = crmd_datf;
    assign csr_crmd[`CRMD_DATM] = crmd_datm;
    assign csr_crmd[`CRMD_ZERO] = 0;
    //PRMD
    reg [`PRMD_PPLV]    prmd_pplv;
    reg [`PRMD_PIE]     prmd_pie;
    wire [31:0] csr_prmd;
    assign csr_prmd[`PRMD_PPLV] = prmd_pplv;
    assign csr_prmd[`PRMD_PIE]  = prmd_pie;
    assign csr_prmd[`PRMD_ZERO] = 0;
    //EUEN
    reg [`EUEN_FPE]     euen_fpe;
    wire [31:0] csr_euen;
    assign csr_euen[`EUEN_FPE]  = euen_fpe;
    assign csr_euen[`EUEN_ZERO] = 0;
    //ECFG
    reg [`ECFG_LIE]     ecfg_lie;
    wire [31:0] csr_ecfg;
    assign csr_ecfg[`ECFG_LIE]  = ecfg_lie;
    assign csr_ecfg[`ECFG_ZERO] = 0;
    //ESTAT
    reg [`ESTAT_IS_0] estat_is_0;
    reg [`ESTAT_ECODE] estat_ecode;
    reg [`ESTAT_ESUBCODE] estat_subecode;
    wire [31:0] csr_estat;
    assign csr_estat[`ESTAT_IS_0] = estat_is_0;
    assign csr_estat[`ESTAT_IS_1] = {1'b0,timer_int,hardware_int};
    assign csr_estat[`ESTAT_ZERO_0] = 0;
    assign csr_estat[`ESTAT_ECODE]  = estat_ecode;
    assign csr_estat[`ESTAT_ESUBCODE] = estat_subecode;
    assign csr_estat[`ESTAT_ZERO_1] = 0;
    //ERA
    reg [31:0] csr_era;
    //BADV
    reg [31:0] csr_badv;
    //EENTRY
    reg [`EENTRY_VA] eentry_va;
    wire [31:0] csr_eentry;
    assign csr_eentry[`EENTRY_ZERO] = 0;
    assign csr_eentry[`EENTRY_VA]   = csr_eentry;
    //TLBRENTRY
    reg [`EENTRY_VA] tlbrentry_pa;
    wire [31:0] csr_tlbrentry;
    assign csr_tlbrentry[`TLBRENTRY_ZERO] = 0;
    assign csr_tlbrentry[`TLBRENTRY_PA]   = csr_eentry;
    //CPUID
    wire [31:0] csr_cpuid = COREID;
    //SAVE0~3
    reg [31:0] csr_save0,csr_save1,csr_save2,csr_save3;
    //LLBCTL
    reg [`LLBCTL_ROLLB] llbctl_rollb;
    reg [`LLBCTL_KLO]   llbctl_klo;
    wire [31:0] csr_llbctl;
    assign csr_llbctl[`LLBCTL_ROLLB] = llbctl_rollb;
    assign csr_llbctl[`LLBCTL_WCLLB] = 0;
    assign csr_llbctl[`LLBCTL_KLO]   = llbctl_klo;
    assign csr_llbctl[`LLBCTL_ZERO]  = 0;
    //TLBIDX
    reg [`TLBIDX_INDEX] tlbidx_index;
    reg [`TLBIDX_PS] tlbidx_ps;
    reg [`TLBIDX_NE]    tlbidx_ne;
    wire [31:0] csr_tlbidx;
    assign csr_tlbidx[`TLBIDX_INDEX] = tlbidx_index;
    assign csr_tlbidx[`TLBIDX_ZERO_0] = 0;
    assign csr_tlbidx[`TLBIDX_PS] = tlbidx_ps;
    assign csr_tlbidx[`TLBIDX_ZERO_1] = 0;
    assign csr_tlbidx[`TLBIDX_NE] = tlbidx_ne;
    //TLBEHI
    reg [`TLBEHI_VPPN] tlbehi_vppn;
    wire [31:0] csr_tlbehi;
    assign csr_tlbehi[`TLBEHI_ZERO] = 0;
    assign csr_tlbehi[`TLBEHI_VPPN] = tlbehi_vppn;
    //TLBELO
    reg [31:0] csr_tlbelo0,csr_tlbelo1;
    //ASID
    reg [`ASID_ASID] asid_asid;
    wire [31:0] csr_asid;
    assign csr_asid[`ASID_ASID]     = asid_asid;
    assign csr_asid[`ASID_ZERO_0]   = 0;
    assign csr_asid[`ASID_ASIDBITS] = ASIDBITS;
    assign csr_asid[`ASID_ZERO_1]   = 0;
    //PGDL PGDH
    reg [`PGD_BASE] pgdl_base, pgdh_base;
    wire [31:0] csr_pgdl, csr_pgdh;
    assign csr_pgdl[`PGD_ZERO]  = 0;
    assign csr_pgdl[`PGD_BASE]  = pgdl_base;
    assign csr_pgdh[`PGD_ZERO]  = 0;
    assign csr_pgdh[`PGD_BASE]  = pgdh_base;
    //PGD
    reg [31:0] csr_pgd;
    //DMW0~1
    wire [31:0] csr_dmw0, csr_dmw1;
    assign csr_dmw0[`DMW_PLV0]      = dmw0_plv0;
    assign csr_dmw0[`DMW_ZERO_0]    = 0;
    assign csr_dmw0[`DMW_PLV3]      = dmw0_plv3;
    assign csr_dmw0[`DMW_MAT]       = {1'd0,dmw0_mat};
    assign csr_dmw0[`DMW_ZERO_1]    = 0;
    assign csr_dmw0[`DMW_PSEG]      = dmw0_pseg;
    assign csr_dmw0[`DMW_ZERO_2]    = 0;
    assign csr_dmw0[`DMW_VSEG]      = dmw0_vseg;
    assign csr_dmw1[`DMW_PLV0]      = dmw1_plv0;
    assign csr_dmw1[`DMW_ZERO_0]    = 0;
    assign csr_dmw1[`DMW_PLV3]      = dmw1_plv3;
    assign csr_dmw1[`DMW_MAT]       = {1'd0,dmw1_mat};
    assign csr_dmw1[`DMW_ZERO_1]    = 0;
    assign csr_dmw1[`DMW_PSEG]      = dmw1_pseg;
    assign csr_dmw1[`DMW_ZERO_2]    = 0;
    assign csr_dmw1[`DMW_VSEG]      = dmw1_vseg;
    //TID
    reg [31:0] csr_tid;
    //TCFG
    reg [`TCFG_EN] tcfg_en;
    reg [`TCFG_PERIODIC] tcfg_peridic;
    reg [`TCFG_INITVAL] tcfg_initval;
    wire [31:0] csr_tcfg;
    assign csr_tcfg[`TCFG_EN]   = tcfg_en;
    assign csr_tcfg[`TCFG_PERIODIC] = tcfg_peridic;
    assign csr_tcfg[`TCFG_INITVAL]  = tcfg_initval;
    //TVAL
    reg [31:0] csr_tval;
    //TICLR
    wire [31:0] csr_ticlr = 0;
    //CTAG
    reg [31:0] csr_ctag;
    //end control state registers defination
    ///////////////////////////////////////

    ///////////////////////////////////////
    //CSR update (updated by software has higher priority)
    //CRMD
    always @(posedge clk)
        if(~rstn) begin
            crmd_plv <= 0;
            crmd_ie <= 0;
            crmd_da <= 1;
            crmd_pg <= 0;
            // FIXME: 为了加速性能测试，重置后DATF, DATM等于1，但这不符合 龙芯架构32位精简版参考手册 p. 53
            crmd_datf <= 1;
            crmd_datm <= 1;
        end else if(software_query_en&&addr==`CSR_CRMD) begin
            if(wen[0]) crmd_plv[0]  <= wdata[0];
            if(wen[1]) crmd_plv[1]  <= wdata[1];
            if(wen[2]) crmd_ie[2]   <= wdata[2];
            if(wen[3]) crmd_da[3]   <= wdata[3];
            if(wen[4]) crmd_pg[4]   <= wdata[4];
            if(wen[5]) crmd_datf[5] <= wdata[5];
            if(wen[6]) crmd_datf[6] <= wdata[6];
            if(wen[7]) crmd_datm[7] <= wdata[7];
            if(wen[8]) crmd_datm[8] <= wdata[8];
        end else if(restore_state) begin
            crmd_plv <= prmd_pplv;
            crmd_ie <= prmd_pie;
        end else if(store_state) begin
            crmd_plv <= 0;
            crmd_ie <= 0;
        end
    
    //PRMD
    always @(posedge clk)
        if(software_query_en&&addr==`CSR_PRMD) begin
            if(wen[0]) prmd_pplv[0]<=wdata[0];
            if(wen[1]) prmd_pplv[1]<=wdata[1];
            if(wen[2]) prmd_pie[2] <=wdata[2];
        end else if(store_state) begin
            prmd_pplv <= crmd_plv;
            prmd_pie  <= crmd_ie;
        end
    
    //EUEN
    always @(posedge clk)
        if(~rstn) begin
            euen_fpe <= 0;
        end else if(software_query_en&&addr==`CSR_EUEN) begin
            if(wen[0]) euen_fpe[0]<=wdata[0];
        end
    
    //ECFG
    always @(posedge clk)
        if(~rstn) begin
            ecfg_lie <= 0;
        end else if(software_query_en&&addr==`CSR_ECFG) begin
            if(wen[0]) ecfg_lie[0]<=wdata[0];
            if(wen[1]) ecfg_lie[1]<=wdata[1];
            if(wen[2]) ecfg_lie[2]<=wdata[2];
            if(wen[3]) ecfg_lie[3]<=wdata[3];
            if(wen[4]) ecfg_lie[4]<=wdata[4];
            if(wen[5]) ecfg_lie[5]<=wdata[5];
            if(wen[6]) ecfg_lie[6]<=wdata[6];
            if(wen[7]) ecfg_lie[7]<=wdata[7];
            if(wen[8]) ecfg_lie[8]<=wdata[8];
            if(wen[9]) ecfg_lie[9]<=wdata[9];
            if(wen[10]) ecfg_lie[10]<=wdata[10];
            if(wen[11]) ecfg_lie[11]<=wdata[11];
            if(wen[12]) ecfg_lie[12]<=wdata[12];
        end
    
    //ESTAT
    always @(posedge clk)
        if(~rstn) begin
            estat_is_0 <= 0;
        end else if(software_query_en&&addr==`CSR_ESTAT) begin
            if(wen[0]) estat_is_0[0]<=wdata[0];
            if(wen[1]) estat_is_0[1]<=wdata[1];
        end else if(expcode_wen) begin
            estat_ecode <= expcode_in[5:0];
            estat_subecode <= expcode_in[6];
        end
    
    //ERA
    always @(posedge clk)
        if(software_query_en&&addr==`CSR_ERA) begin
            if(wen[ 0]) csr_era[ 0]<=wdata[ 0];
            if(wen[ 1]) csr_era[ 1]<=wdata[ 1];
            if(wen[ 2]) csr_era[ 2]<=wdata[ 2];
            if(wen[ 3]) csr_era[ 3]<=wdata[ 3];
            if(wen[ 4]) csr_era[ 4]<=wdata[ 4];
            if(wen[ 5]) csr_era[ 5]<=wdata[ 5];
            if(wen[ 6]) csr_era[ 6]<=wdata[ 6];
            if(wen[ 7]) csr_era[ 7]<=wdata[ 7];
            if(wen[ 8]) csr_era[ 8]<=wdata[ 8];
            if(wen[ 9]) csr_era[ 9]<=wdata[ 9];
            if(wen[10]) csr_era[10]<=wdata[10];
            if(wen[11]) csr_era[11]<=wdata[11];
            if(wen[12]) csr_era[12]<=wdata[12];
            if(wen[13]) csr_era[13]<=wdata[13];
            if(wen[14]) csr_era[14]<=wdata[14];
            if(wen[15]) csr_era[15]<=wdata[15];
            if(wen[16]) csr_era[16]<=wdata[16];
            if(wen[17]) csr_era[17]<=wdata[17];
            if(wen[18]) csr_era[18]<=wdata[18];
            if(wen[19]) csr_era[19]<=wdata[19];
            if(wen[20]) csr_era[20]<=wdata[20];
            if(wen[21]) csr_era[21]<=wdata[21];
            if(wen[22]) csr_era[22]<=wdata[22];
            if(wen[23]) csr_era[23]<=wdata[23];
            if(wen[24]) csr_era[24]<=wdata[24];
            if(wen[25]) csr_era[25]<=wdata[25];
            if(wen[26]) csr_era[26]<=wdata[26];
            if(wen[27]) csr_era[27]<=wdata[27];
            if(wen[28]) csr_era[28]<=wdata[28];
            if(wen[29]) csr_era[29]<=wdata[29];
            if(wen[30]) csr_era[30]<=wdata[30];
            if(wen[31]) csr_era[31]<=wdata[31];
        end else if(era_wen) begin
            csr_era <= era_in;
        end

    //BADV
    always @(posedge clk)
        if(software_query_en&&addr==`CSR_BADV) begin
            if(wen[ 0]) csr_badv[ 0]<=wdata[ 0];
            if(wen[ 1]) csr_badv[ 1]<=wdata[ 1];
            if(wen[ 2]) csr_badv[ 2]<=wdata[ 2];
            if(wen[ 3]) csr_badv[ 3]<=wdata[ 3];
            if(wen[ 4]) csr_badv[ 4]<=wdata[ 4];
            if(wen[ 5]) csr_badv[ 5]<=wdata[ 5];
            if(wen[ 6]) csr_badv[ 6]<=wdata[ 6];
            if(wen[ 7]) csr_badv[ 7]<=wdata[ 7];
            if(wen[ 8]) csr_badv[ 8]<=wdata[ 8];
            if(wen[ 9]) csr_badv[ 9]<=wdata[ 9];
            if(wen[10]) csr_badv[10]<=wdata[10];
            if(wen[11]) csr_badv[11]<=wdata[11];
            if(wen[12]) csr_badv[12]<=wdata[12];
            if(wen[13]) csr_badv[13]<=wdata[13];
            if(wen[14]) csr_badv[14]<=wdata[14];
            if(wen[15]) csr_badv[15]<=wdata[15];
            if(wen[16]) csr_badv[16]<=wdata[16];
            if(wen[17]) csr_badv[17]<=wdata[17];
            if(wen[18]) csr_badv[18]<=wdata[18];
            if(wen[19]) csr_badv[19]<=wdata[19];
            if(wen[20]) csr_badv[20]<=wdata[20];
            if(wen[21]) csr_badv[21]<=wdata[21];
            if(wen[22]) csr_badv[22]<=wdata[22];
            if(wen[23]) csr_badv[23]<=wdata[23];
            if(wen[24]) csr_badv[24]<=wdata[24];
            if(wen[25]) csr_badv[25]<=wdata[25];
            if(wen[26]) csr_badv[26]<=wdata[26];
            if(wen[27]) csr_badv[27]<=wdata[27];
            if(wen[28]) csr_badv[28]<=wdata[28];
            if(wen[29]) csr_badv[29]<=wdata[29];
            if(wen[30]) csr_badv[30]<=wdata[30];
            if(wen[31]) csr_badv[31]<=wdata[31];
        end else if(badv_wen) begin
            csr_badv <= badv_in;
        end

    //EENTRY
    always @(posedge clk)
        if(software_query_en&&addr==`CSR_EENTRY) begin
            if(wen[ 6]) eentry_va[ 6]<=wdata[ 6];
            if(wen[ 7]) eentry_va[ 7]<=wdata[ 7];
            if(wen[ 8]) eentry_va[ 8]<=wdata[ 8];
            if(wen[ 9]) eentry_va[ 9]<=wdata[ 9];
            if(wen[10]) eentry_va[10]<=wdata[10];
            if(wen[11]) eentry_va[11]<=wdata[11];
            if(wen[12]) eentry_va[12]<=wdata[12];
            if(wen[13]) eentry_va[13]<=wdata[13];
            if(wen[14]) eentry_va[14]<=wdata[14];
            if(wen[15]) eentry_va[15]<=wdata[15];
            if(wen[16]) eentry_va[16]<=wdata[16];
            if(wen[17]) eentry_va[17]<=wdata[17];
            if(wen[18]) eentry_va[18]<=wdata[18];
            if(wen[19]) eentry_va[19]<=wdata[19];
            if(wen[20]) eentry_va[20]<=wdata[20];
            if(wen[21]) eentry_va[21]<=wdata[21];
            if(wen[22]) eentry_va[22]<=wdata[22];
            if(wen[23]) eentry_va[23]<=wdata[23];
            if(wen[24]) eentry_va[24]<=wdata[24];
            if(wen[25]) eentry_va[25]<=wdata[25];
            if(wen[26]) eentry_va[26]<=wdata[26];
            if(wen[27]) eentry_va[27]<=wdata[27];
            if(wen[28]) eentry_va[28]<=wdata[28];
            if(wen[29]) eentry_va[29]<=wdata[29];
            if(wen[30]) eentry_va[30]<=wdata[30];
            if(wen[31]) eentry_va[31]<=wdata[31];
        end
    
    //TLBRENTRY
    always @(posedge clk)
        if(software_query_en&&addr==`CSR_TLBRENTRY) begin
            if(wen[ 6]) tlbrentry_pa[ 6]<=wdata[ 6];
            if(wen[ 7]) tlbrentry_pa[ 7]<=wdata[ 7];
            if(wen[ 8]) tlbrentry_pa[ 8]<=wdata[ 8];
            if(wen[ 9]) tlbrentry_pa[ 9]<=wdata[ 9];
            if(wen[10]) tlbrentry_pa[10]<=wdata[10];
            if(wen[11]) tlbrentry_pa[11]<=wdata[11];
            if(wen[12]) tlbrentry_pa[12]<=wdata[12];
            if(wen[13]) tlbrentry_pa[13]<=wdata[13];
            if(wen[14]) tlbrentry_pa[14]<=wdata[14];
            if(wen[15]) tlbrentry_pa[15]<=wdata[15];
            if(wen[16]) tlbrentry_pa[16]<=wdata[16];
            if(wen[17]) tlbrentry_pa[17]<=wdata[17];
            if(wen[18]) tlbrentry_pa[18]<=wdata[18];
            if(wen[19]) tlbrentry_pa[19]<=wdata[19];
            if(wen[20]) tlbrentry_pa[20]<=wdata[20];
            if(wen[21]) tlbrentry_pa[21]<=wdata[21];
            if(wen[22]) tlbrentry_pa[22]<=wdata[22];
            if(wen[23]) tlbrentry_pa[23]<=wdata[23];
            if(wen[24]) tlbrentry_pa[24]<=wdata[24];
            if(wen[25]) tlbrentry_pa[25]<=wdata[25];
            if(wen[26]) tlbrentry_pa[26]<=wdata[26];
            if(wen[27]) tlbrentry_pa[27]<=wdata[27];
            if(wen[28]) tlbrentry_pa[28]<=wdata[28];
            if(wen[29]) tlbrentry_pa[29]<=wdata[29];
            if(wen[30]) tlbrentry_pa[30]<=wdata[30];
            if(wen[31]) tlbrentry_pa[31]<=wdata[31];
        end
    
    //SAVE0~3
    always @(posedge clk)
        if(software_query_en&&addr==`CSR_SAVE0) begin
            if(wen[ 0]) csr_save0[ 0]<=wdata[ 0];
            if(wen[ 1]) csr_save0[ 1]<=wdata[ 1];
            if(wen[ 2]) csr_save0[ 2]<=wdata[ 2];
            if(wen[ 3]) csr_save0[ 3]<=wdata[ 3];
            if(wen[ 4]) csr_save0[ 4]<=wdata[ 4];
            if(wen[ 5]) csr_save0[ 5]<=wdata[ 5];
            if(wen[ 6]) csr_save0[ 6]<=wdata[ 6];
            if(wen[ 7]) csr_save0[ 7]<=wdata[ 7];
            if(wen[ 8]) csr_save0[ 8]<=wdata[ 8];
            if(wen[ 9]) csr_save0[ 9]<=wdata[ 9];
            if(wen[10]) csr_save0[10]<=wdata[10];
            if(wen[11]) csr_save0[11]<=wdata[11];
            if(wen[12]) csr_save0[12]<=wdata[12];
            if(wen[13]) csr_save0[13]<=wdata[13];
            if(wen[14]) csr_save0[14]<=wdata[14];
            if(wen[15]) csr_save0[15]<=wdata[15];
            if(wen[16]) csr_save0[16]<=wdata[16];
            if(wen[17]) csr_save0[17]<=wdata[17];
            if(wen[18]) csr_save0[18]<=wdata[18];
            if(wen[19]) csr_save0[19]<=wdata[19];
            if(wen[20]) csr_save0[20]<=wdata[20];
            if(wen[21]) csr_save0[21]<=wdata[21];
            if(wen[22]) csr_save0[22]<=wdata[22];
            if(wen[23]) csr_save0[23]<=wdata[23];
            if(wen[24]) csr_save0[24]<=wdata[24];
            if(wen[25]) csr_save0[25]<=wdata[25];
            if(wen[26]) csr_save0[26]<=wdata[26];
            if(wen[27]) csr_save0[27]<=wdata[27];
            if(wen[28]) csr_save0[28]<=wdata[28];
            if(wen[29]) csr_save0[29]<=wdata[29];
            if(wen[30]) csr_save0[30]<=wdata[30];
            if(wen[31]) csr_save0[31]<=wdata[31];
        end
    
    always @(posedge clk)
        if(software_query_en&&addr==`CSR_SAVE1) begin
            if(wen[ 0]) csr_save1[ 0]<=wdata[ 0];
            if(wen[ 1]) csr_save1[ 1]<=wdata[ 1];
            if(wen[ 2]) csr_save1[ 2]<=wdata[ 2];
            if(wen[ 3]) csr_save1[ 3]<=wdata[ 3];
            if(wen[ 4]) csr_save1[ 4]<=wdata[ 4];
            if(wen[ 5]) csr_save1[ 5]<=wdata[ 5];
            if(wen[ 6]) csr_save1[ 6]<=wdata[ 6];
            if(wen[ 7]) csr_save1[ 7]<=wdata[ 7];
            if(wen[ 8]) csr_save1[ 8]<=wdata[ 8];
            if(wen[ 9]) csr_save1[ 9]<=wdata[ 9];
            if(wen[10]) csr_save1[10]<=wdata[10];
            if(wen[11]) csr_save1[11]<=wdata[11];
            if(wen[12]) csr_save1[12]<=wdata[12];
            if(wen[13]) csr_save1[13]<=wdata[13];
            if(wen[14]) csr_save1[14]<=wdata[14];
            if(wen[15]) csr_save1[15]<=wdata[15];
            if(wen[16]) csr_save1[16]<=wdata[16];
            if(wen[17]) csr_save1[17]<=wdata[17];
            if(wen[18]) csr_save1[18]<=wdata[18];
            if(wen[19]) csr_save1[19]<=wdata[19];
            if(wen[20]) csr_save1[20]<=wdata[20];
            if(wen[21]) csr_save1[21]<=wdata[21];
            if(wen[22]) csr_save1[22]<=wdata[22];
            if(wen[23]) csr_save1[23]<=wdata[23];
            if(wen[24]) csr_save1[24]<=wdata[24];
            if(wen[25]) csr_save1[25]<=wdata[25];
            if(wen[26]) csr_save1[26]<=wdata[26];
            if(wen[27]) csr_save1[27]<=wdata[27];
            if(wen[28]) csr_save1[28]<=wdata[28];
            if(wen[29]) csr_save1[29]<=wdata[29];
            if(wen[30]) csr_save1[30]<=wdata[30];
            if(wen[31]) csr_save1[31]<=wdata[31];
        end
    
    always @(posedge clk)
        if(software_query_en&&addr==`CSR_SAVE2) begin
            if(wen[ 0]) csr_save2[ 0]<=wdata[ 0];
            if(wen[ 1]) csr_save2[ 1]<=wdata[ 1];
            if(wen[ 2]) csr_save2[ 2]<=wdata[ 2];
            if(wen[ 3]) csr_save2[ 3]<=wdata[ 3];
            if(wen[ 4]) csr_save2[ 4]<=wdata[ 4];
            if(wen[ 5]) csr_save2[ 5]<=wdata[ 5];
            if(wen[ 6]) csr_save2[ 6]<=wdata[ 6];
            if(wen[ 7]) csr_save2[ 7]<=wdata[ 7];
            if(wen[ 8]) csr_save2[ 8]<=wdata[ 8];
            if(wen[ 9]) csr_save2[ 9]<=wdata[ 9];
            if(wen[10]) csr_save2[10]<=wdata[10];
            if(wen[11]) csr_save2[11]<=wdata[11];
            if(wen[12]) csr_save2[12]<=wdata[12];
            if(wen[13]) csr_save2[13]<=wdata[13];
            if(wen[14]) csr_save2[14]<=wdata[14];
            if(wen[15]) csr_save2[15]<=wdata[15];
            if(wen[16]) csr_save2[16]<=wdata[16];
            if(wen[17]) csr_save2[17]<=wdata[17];
            if(wen[18]) csr_save2[18]<=wdata[18];
            if(wen[19]) csr_save2[19]<=wdata[19];
            if(wen[20]) csr_save2[20]<=wdata[20];
            if(wen[21]) csr_save2[21]<=wdata[21];
            if(wen[22]) csr_save2[22]<=wdata[22];
            if(wen[23]) csr_save2[23]<=wdata[23];
            if(wen[24]) csr_save2[24]<=wdata[24];
            if(wen[25]) csr_save2[25]<=wdata[25];
            if(wen[26]) csr_save2[26]<=wdata[26];
            if(wen[27]) csr_save2[27]<=wdata[27];
            if(wen[28]) csr_save2[28]<=wdata[28];
            if(wen[29]) csr_save2[29]<=wdata[29];
            if(wen[30]) csr_save2[30]<=wdata[30];
            if(wen[31]) csr_save2[31]<=wdata[31];
        end
    
    always @(posedge clk)
        if(software_query_en&&addr==`CSR_SAVE3) begin
            if(wen[ 0]) csr_save3[ 0]<=wdata[ 0];
            if(wen[ 1]) csr_save3[ 1]<=wdata[ 1];
            if(wen[ 2]) csr_save3[ 2]<=wdata[ 2];
            if(wen[ 3]) csr_save3[ 3]<=wdata[ 3];
            if(wen[ 4]) csr_save3[ 4]<=wdata[ 4];
            if(wen[ 5]) csr_save3[ 5]<=wdata[ 5];
            if(wen[ 6]) csr_save3[ 6]<=wdata[ 6];
            if(wen[ 7]) csr_save3[ 7]<=wdata[ 7];
            if(wen[ 8]) csr_save3[ 8]<=wdata[ 8];
            if(wen[ 9]) csr_save3[ 9]<=wdata[ 9];
            if(wen[10]) csr_save3[10]<=wdata[10];
            if(wen[11]) csr_save3[11]<=wdata[11];
            if(wen[12]) csr_save3[12]<=wdata[12];
            if(wen[13]) csr_save3[13]<=wdata[13];
            if(wen[14]) csr_save3[14]<=wdata[14];
            if(wen[15]) csr_save3[15]<=wdata[15];
            if(wen[16]) csr_save3[16]<=wdata[16];
            if(wen[17]) csr_save3[17]<=wdata[17];
            if(wen[18]) csr_save3[18]<=wdata[18];
            if(wen[19]) csr_save3[19]<=wdata[19];
            if(wen[20]) csr_save3[20]<=wdata[20];
            if(wen[21]) csr_save3[21]<=wdata[21];
            if(wen[22]) csr_save3[22]<=wdata[22];
            if(wen[23]) csr_save3[23]<=wdata[23];
            if(wen[24]) csr_save3[24]<=wdata[24];
            if(wen[25]) csr_save3[25]<=wdata[25];
            if(wen[26]) csr_save3[26]<=wdata[26];
            if(wen[27]) csr_save3[27]<=wdata[27];
            if(wen[28]) csr_save3[28]<=wdata[28];
            if(wen[29]) csr_save3[29]<=wdata[29];
            if(wen[30]) csr_save3[30]<=wdata[30];
            if(wen[31]) csr_save3[31]<=wdata[31];
        end

    //LLBCTL
    always @(posedge clk)
        if(~rstn) begin
            llbctl_klo <= 0;
            llbctl_rollb <= 0;
        end else if(software_query_en&&addr==`CSR_LLBCTL) begin
            if(wen[1]) llbctl_rollb<=0;
            if(wen[2]) llbctl_klo<=wdata[2];
        end else if(llbit_set) llbctl_rollb<=1;
        else if(llbit_clear_by_other) llbctl_rollb<=0;
        else if(llbit_clear_by_eret) begin 
            llbctl_rollb<=llbctl_klo;
            llbctl_klo<=0;
        end
    
    //TIBIDX
    always @(posedge clk)
        if(~rstn)
            tlbidx_index<=0;
        else if(software_query_en&&addr==`CSR_TLBIDX) begin
            if( 0<TLBIDX_WIDTH&&wen[ 0]) tlbidx_index[ 0]<=wdata[ 0];
            if( 1<TLBIDX_WIDTH&&wen[ 1]) tlbidx_index[ 1]<=wdata[ 1];
            if( 2<TLBIDX_WIDTH&&wen[ 2]) tlbidx_index[ 2]<=wdata[ 2];
            if( 3<TLBIDX_WIDTH&&wen[ 3]) tlbidx_index[ 3]<=wdata[ 3];
            if( 4<TLBIDX_WIDTH&&wen[ 4]) tlbidx_index[ 4]<=wdata[ 4];
            if( 5<TLBIDX_WIDTH&&wen[ 5]) tlbidx_index[ 5]<=wdata[ 5];
            if( 6<TLBIDX_WIDTH&&wen[ 6]) tlbidx_index[ 6]<=wdata[ 6];
            if( 7<TLBIDX_WIDTH&&wen[ 7]) tlbidx_index[ 7]<=wdata[ 7];
            if( 8<TLBIDX_WIDTH&&wen[ 8]) tlbidx_index[ 8]<=wdata[ 8];
            if( 9<TLBIDX_WIDTH&&wen[ 9]) tlbidx_index[ 9]<=wdata[ 9];
            if(10<TLBIDX_WIDTH&&wen[10]) tlbidx_index[10]<=wdata[10];
            if(11<TLBIDX_WIDTH&&wen[11]) tlbidx_index[11]<=wdata[11];
            if(12<TLBIDX_WIDTH&&wen[12]) tlbidx_index[12]<=wdata[12];
            if(13<TLBIDX_WIDTH&&wen[13]) tlbidx_index[13]<=wdata[13];
            if(14<TLBIDX_WIDTH&&wen[14]) tlbidx_index[14]<=wdata[14];
            if(15<TLBIDX_WIDTH&&wen[15]) tlbidx_index[15]<=wdata[15];
            if(wen[24]) tlbidx_ps[24]<=wdata[24];
            if(wen[25]) tlbidx_ps[25]<=wdata[25];
            if(wen[26]) tlbidx_ps[26]<=wdata[26];
            if(wen[27]) tlbidx_ps[27]<=wdata[27];
            if(wen[28]) tlbidx_ps[28]<=wdata[28];
            if(wen[29]) tlbidx_ps[29]<=wdata[29];
            if(wen[31]) tlbidx_ne[31]<=wdata[31];
        end else begin
            if(tlb_index_we) tlbidx_index<=tlb_index_in;
            if(tlb_ps_we) tlbidx_ps <= tlb_ps_in;
            if(tlb_ne_we) tlbidx_ne <= tlb_ne_in;
        end

    //TLBEHI
    always @(posedge clk)
        if(software_query_en&&addr==`CSR_TLBEHI) begin
            if(wen[13]) tlbehi_vppn[13] <= wdata[13];
            if(wen[14]) tlbehi_vppn[14] <= wdata[14];
            if(wen[15]) tlbehi_vppn[15] <= wdata[15];
            if(wen[16]) tlbehi_vppn[16] <= wdata[16];
            if(wen[17]) tlbehi_vppn[17] <= wdata[17];
            if(wen[18]) tlbehi_vppn[18] <= wdata[18];
            if(wen[19]) tlbehi_vppn[19] <= wdata[19];
            if(wen[20]) tlbehi_vppn[20] <= wdata[20];
            if(wen[21]) tlbehi_vppn[21] <= wdata[21];
            if(wen[22]) tlbehi_vppn[22] <= wdata[22];
            if(wen[23]) tlbehi_vppn[23] <= wdata[23];
            if(wen[24]) tlbehi_vppn[24] <= wdata[24];
            if(wen[25]) tlbehi_vppn[25] <= wdata[25];
            if(wen[26]) tlbehi_vppn[26] <= wdata[26];
            if(wen[27]) tlbehi_vppn[27] <= wdata[27];
            if(wen[28]) tlbehi_vppn[28] <= wdata[28];
            if(wen[29]) tlbehi_vppn[29] <= wdata[29];
            if(wen[30]) tlbehi_vppn[30] <= wdata[30];
            if(wen[31]) tlbehi_vppn[31] <= wdata[31];
        end else if(tlb_vppn_we)
            tlbehi_vppn<=tlb_vppn_in;
    
    //TLBELO0~1
    always @(posedge clk)
        if(~rstn) begin
            csr_tlbelo0 <= 0;
        end else if(software_query_en&&addr==`CSR_TLBELO0) begin
            if(wen[ 0]) csr_tlbelo0[ 0] <= wdata[ 0];
            if(wen[ 1]) csr_tlbelo0[ 1] <= wdata[ 1];
            if(wen[ 2]) csr_tlbelo0[ 2] <= wdata[ 2];
            if(wen[ 3]) csr_tlbelo0[ 3] <= wdata[ 3];
            if(wen[ 4]) csr_tlbelo0[ 4] <= wdata[ 4];
            if(wen[ 5]) csr_tlbelo0[ 5] <= wdata[ 5];
            if(wen[ 6]) csr_tlbelo0[ 6] <= wdata[ 6];
            //csr_tlbelo0[7] is read-only
            if(wen[ 8]) csr_tlbelo0[ 8] <= wdata[ 8];
            if(wen[ 9]) csr_tlbelo0[ 9] <= wdata[ 9];
            if(wen[10]) csr_tlbelo0[10] <= wdata[10];
            if(wen[11]) csr_tlbelo0[11] <= wdata[11];
            if(wen[12]) csr_tlbelo0[12] <= wdata[12];
            if(wen[13]) csr_tlbelo0[13] <= wdata[13];
            if(wen[14]) csr_tlbelo0[14] <= wdata[14];
            if(wen[15]) csr_tlbelo0[15] <= wdata[15];
            if(wen[16]) csr_tlbelo0[16] <= wdata[16];
            if(wen[17]) csr_tlbelo0[17] <= wdata[17];
            if(wen[18]) csr_tlbelo0[18] <= wdata[18];
            if(wen[19]) csr_tlbelo0[19] <= wdata[19];
            if(wen[20]) csr_tlbelo0[20] <= wdata[20];
            if(wen[21]) csr_tlbelo0[21] <= wdata[21];
            if(wen[22]) csr_tlbelo0[22] <= wdata[22];
            if(wen[23]) csr_tlbelo0[23] <= wdata[23];
            if(wen[24]) csr_tlbelo0[24] <= wdata[24];
            if(wen[25]) csr_tlbelo0[25] <= wdata[25];
            if(wen[26]) csr_tlbelo0[26] <= wdata[26];
            if(wen[27]) csr_tlbelo0[27] <= wdata[27];
            if(wen[28]) csr_tlbelo0[28] <= wdata[28];
            if(wen[29]) csr_tlbelo0[29] <= wdata[29];
            if(wen[30]) csr_tlbelo0[30] <= wdata[30];
            if(wen[31]) csr_tlbelo0[31] <= wdata[31];
        end else begin
            if(tlb_valid_0_wen) csr_tlbelo0[`TLBELO_V] <= tlb_valid_0_in;
            if(tlb_dirty_0_wen) csr_tlbelo0[`TLBELO_D] <= tlb_dirty_0_in;
            if(tlb_priviledge_0_wen) csr_tlbelo0[`TLBELO_PLV] <= tlb_priviledge_0_in;
            if(tlb_mat_0_wen) csr_tlbelo0[`TLBELO_MAT] <= {1'b0,tlb_mat_0_in};
            if(tlb_global_0_wen) csr_tlbelo0[`TLBELO_G] <= tlb_global_0_in;
            if(tlb_ppn_0_wen) csr_tlbelo0[`TLBELO_PPN] <= tlb_ppn_0_in;
        end
    
    always @(posedge clk)
        if(~rstn) begin
            csr_tlbelo1 <= 0;
        end else if(software_query_en&&addr==`CSR_TLBELO1) begin
            if(wen[ 0]) csr_tlbelo1[ 0] <= wdata[ 0];
            if(wen[ 1]) csr_tlbelo1[ 1] <= wdata[ 1];
            if(wen[ 2]) csr_tlbelo1[ 2] <= wdata[ 2];
            if(wen[ 3]) csr_tlbelo1[ 3] <= wdata[ 3];
            if(wen[ 4]) csr_tlbelo1[ 4] <= wdata[ 4];
            if(wen[ 5]) csr_tlbelo1[ 5] <= wdata[ 5];
            if(wen[ 6]) csr_tlbelo1[ 6] <= wdata[ 6];
            //csr_tlbelo1[7] is read-only
            if(wen[ 8]) csr_tlbelo1[ 8] <= wdata[ 8];
            if(wen[ 9]) csr_tlbelo1[ 9] <= wdata[ 9];
            if(wen[10]) csr_tlbelo1[10] <= wdata[10];
            if(wen[11]) csr_tlbelo1[11] <= wdata[11];
            if(wen[12]) csr_tlbelo1[12] <= wdata[12];
            if(wen[13]) csr_tlbelo1[13] <= wdata[13];
            if(wen[14]) csr_tlbelo1[14] <= wdata[14];
            if(wen[15]) csr_tlbelo1[15] <= wdata[15];
            if(wen[16]) csr_tlbelo1[16] <= wdata[16];
            if(wen[17]) csr_tlbelo1[17] <= wdata[17];
            if(wen[18]) csr_tlbelo1[18] <= wdata[18];
            if(wen[19]) csr_tlbelo1[19] <= wdata[19];
            if(wen[20]) csr_tlbelo1[20] <= wdata[20];
            if(wen[21]) csr_tlbelo1[21] <= wdata[21];
            if(wen[22]) csr_tlbelo1[22] <= wdata[22];
            if(wen[23]) csr_tlbelo1[23] <= wdata[23];
            if(wen[24]) csr_tlbelo1[24] <= wdata[24];
            if(wen[25]) csr_tlbelo1[25] <= wdata[25];
            if(wen[26]) csr_tlbelo1[26] <= wdata[26];
            if(wen[27]) csr_tlbelo1[27] <= wdata[27];
            if(wen[28]) csr_tlbelo1[28] <= wdata[28];
            if(wen[29]) csr_tlbelo1[29] <= wdata[29];
            if(wen[30]) csr_tlbelo1[30] <= wdata[30];
            if(wen[31]) csr_tlbelo1[31] <= wdata[31];
        end else begin
            if(tlb_valid_1_wen) csr_tlbelo1[`TLBELO_V] <= tlb_valid_1_in;
            if(tlb_dirty_1_wen) csr_tlbelo1[`TLBELO_D] <= tlb_dirty_1_in;
            if(tlb_priviledge_1_wen) csr_tlbelo1[`TLBELO_PLV] <= tlb_priviledge_1_in;
            if(tlb_mat_1_wen) csr_tlbelo1[`TLBELO_MAT] <= {1'b0,tlb_mat_1_in};
            if(tlb_global_1_wen) csr_tlbelo1[`TLBELO_G] <= tlb_global_1_in;
            if(tlb_ppn_1_wen) csr_tlbelo1[`TLBELO_PPN] <= tlb_ppn_1_in;
        end
    
    //ASID
    always @(posedge clk)
        if(~rstn)
            asid_asid <= 0;
        else if(software_query_en&&addr==`CSR_ASID) begin
            if(wen[0]) asid_asid[0]<=wdata[0];
            if(wen[1]) asid_asid[1]<=wdata[1];
            if(wen[2]) asid_asid[2]<=wdata[2];
            if(wen[3]) asid_asid[3]<=wdata[3];
            if(wen[4]) asid_asid[4]<=wdata[4];
            if(wen[5]) asid_asid[5]<=wdata[5];
            if(wen[6]) asid_asid[6]<=wdata[6];
            if(wen[7]) asid_asid[7]<=wdata[7];
            if(wen[8]) asid_asid[8]<=wdata[8];
            if(wen[9]) asid_asid[9]<=wdata[9];
        end else if(asid_wen)
            asid_asid <= asid_in;
    
    //PGDL
    always @(posedge clk)
        if(software_query_en&&addr==`CSR_PGDL) begin
            if(wen[12]) pgdl_base[12] <= wdata[12];
            if(wen[13]) pgdl_base[13] <= wdata[13];
            if(wen[14]) pgdl_base[14] <= wdata[14];
            if(wen[15]) pgdl_base[15] <= wdata[15];
            if(wen[16]) pgdl_base[16] <= wdata[16];
            if(wen[17]) pgdl_base[17] <= wdata[17];
            if(wen[18]) pgdl_base[18] <= wdata[18];
            if(wen[19]) pgdl_base[19] <= wdata[19];
            if(wen[20]) pgdl_base[20] <= wdata[20];
            if(wen[21]) pgdl_base[21] <= wdata[21];
            if(wen[22]) pgdl_base[22] <= wdata[22];
            if(wen[23]) pgdl_base[23] <= wdata[23];
            if(wen[24]) pgdl_base[24] <= wdata[24];
            if(wen[25]) pgdl_base[25] <= wdata[25];
            if(wen[26]) pgdl_base[26] <= wdata[26];
            if(wen[27]) pgdl_base[27] <= wdata[27];
            if(wen[28]) pgdl_base[28] <= wdata[28];
            if(wen[29]) pgdl_base[29] <= wdata[29];
            if(wen[30]) pgdl_base[30] <= wdata[30];
            if(wen[31]) pgdl_base[31] <= wdata[31];
        end
    
    //PGDH
    always @(posedge clk)
        if(software_query_en&&addr==`CSR_PGDH) begin
            if(wen[12]) pgdh_base[12] <= wdata[12];
            if(wen[13]) pgdh_base[13] <= wdata[13];
            if(wen[14]) pgdh_base[14] <= wdata[14];
            if(wen[15]) pgdh_base[15] <= wdata[15];
            if(wen[16]) pgdh_base[16] <= wdata[16];
            if(wen[17]) pgdh_base[17] <= wdata[17];
            if(wen[18]) pgdh_base[18] <= wdata[18];
            if(wen[19]) pgdh_base[19] <= wdata[19];
            if(wen[20]) pgdh_base[20] <= wdata[20];
            if(wen[21]) pgdh_base[21] <= wdata[21];
            if(wen[22]) pgdh_base[22] <= wdata[22];
            if(wen[23]) pgdh_base[23] <= wdata[23];
            if(wen[24]) pgdh_base[24] <= wdata[24];
            if(wen[25]) pgdh_base[25] <= wdata[25];
            if(wen[26]) pgdh_base[26] <= wdata[26];
            if(wen[27]) pgdh_base[27] <= wdata[27];
            if(wen[28]) pgdh_base[28] <= wdata[28];
            if(wen[29]) pgdh_base[29] <= wdata[29];
            if(wen[30]) pgdh_base[30] <= wdata[30];
            if(wen[31]) pgdh_base[31] <= wdata[31];
        end
    
    //PGD
    always @(posedge clk)
        if(~rstn)
            csr_pgd <= 0;
        else if(pgd_wen)
            csr_pgd[`PGD_BASE] <= pgd_in[`PGD_BASE];
    
    //DMW0~1
    always @(posedge clk)
        if(~rstn) begin
            dmw0_plv0<=0;
            dmw0_plv3<=0;
        end else if(software_query_en&&addr==`CSR_DMW0) begin
            if(wen[ 0]) dmw0_plv0<=wdata[ 0];
            if(wen[ 3]) dmw0_plv3<=wdata[ 3];
            if(wen[ 4]) dmw0_mat<=wdata[ 4];
            if(wen[25]) dmw0_pseg[29]<=wdata[25];
            if(wen[26]) dmw0_pseg[30]<=wdata[26];
            if(wen[27]) dmw0_pseg[31]<=wdata[27];
            if(wen[29]) dmw0_vseg[29]<=wdata[29];
            if(wen[30]) dmw0_vseg[30]<=wdata[30];
            if(wen[31]) dmw0_vseg[31]<=wdata[31];
        end
    
    always @(posedge clk)
        if(~rstn) begin
            dmw1_plv0<=0;
            dmw1_plv3<=0;
        end else if(software_query_en&&addr==`CSR_DMW1) begin
            if(wen[ 0]) dmw1_plv0<=wdata[ 0];
            if(wen[ 3]) dmw1_plv3<=wdata[ 3];
            if(wen[ 4]) dmw1_mat<=wdata[ 4];
            if(wen[25]) dmw1_pseg[29]<=wdata[25];
            if(wen[26]) dmw1_pseg[30]<=wdata[26];
            if(wen[27]) dmw1_pseg[31]<=wdata[27];
            if(wen[29]) dmw1_vseg[29]<=wdata[29];
            if(wen[30]) dmw1_vseg[30]<=wdata[30];
            if(wen[31]) dmw1_vseg[31]<=wdata[31];
        end
    
    always @(posedge clk)
        if(~rstn) begin
            csr_tid <= 0;
        end else if(software_query_en&&addr==`CSR_TID) begin
            if(wen[ 0]) csr_tid[ 0]<=wdata[ 0];
            if(wen[ 1]) csr_tid[ 1]<=wdata[ 1];
            if(wen[ 2]) csr_tid[ 2]<=wdata[ 2];
            if(wen[ 3]) csr_tid[ 3]<=wdata[ 3];
            if(wen[ 4]) csr_tid[ 4]<=wdata[ 4];
            if(wen[ 5]) csr_tid[ 5]<=wdata[ 5];
            if(wen[ 6]) csr_tid[ 6]<=wdata[ 6];
            if(wen[ 7]) csr_tid[ 7]<=wdata[ 7];
            if(wen[ 8]) csr_tid[ 8]<=wdata[ 8];
            if(wen[ 9]) csr_tid[ 9]<=wdata[ 9];
            if(wen[10]) csr_tid[10]<=wdata[10];
            if(wen[11]) csr_tid[11]<=wdata[11];
            if(wen[12]) csr_tid[12]<=wdata[12];
            if(wen[13]) csr_tid[13]<=wdata[13];
            if(wen[14]) csr_tid[14]<=wdata[14];
            if(wen[15]) csr_tid[15]<=wdata[15];
            if(wen[16]) csr_tid[16]<=wdata[16];
            if(wen[17]) csr_tid[17]<=wdata[17];
            if(wen[18]) csr_tid[18]<=wdata[18];
            if(wen[19]) csr_tid[19]<=wdata[19];
            if(wen[20]) csr_tid[20]<=wdata[20];
            if(wen[21]) csr_tid[21]<=wdata[21];
            if(wen[22]) csr_tid[22]<=wdata[22];
            if(wen[23]) csr_tid[23]<=wdata[23];
            if(wen[24]) csr_tid[24]<=wdata[24];
            if(wen[25]) csr_tid[25]<=wdata[25];
            if(wen[26]) csr_tid[26]<=wdata[26];
            if(wen[27]) csr_tid[27]<=wdata[27];
            if(wen[28]) csr_tid[28]<=wdata[28];
            if(wen[29]) csr_tid[29]<=wdata[29];
            if(wen[30]) csr_tid[30]<=wdata[30];
            if(wen[31]) csr_tid[31]<=wdata[31];
        end

    //TCFG
    always @(posedge clk)
        if(~rstn) begin
            tcfg_en <= 0;
            tcfg_initval <= 0;
        end else if(software_query_en&&addr==`CSR_TID) begin
            if(wen[ 0]) tcfg_en[ 0]     <=wdata[ 0];
            if(wen[ 1]) tcfg_peridic[ 1]<=wdata[ 1];
            if(wen[ 2]) tcfg_initval[ 2]<=wdata[ 2];
            if(wen[ 3]) tcfg_initval[ 3]<=wdata[ 3];
            if(wen[ 4]) tcfg_initval[ 4]<=wdata[ 4];
            if(wen[ 5]) tcfg_initval[ 5]<=wdata[ 5];
            if(wen[ 6]) tcfg_initval[ 6]<=wdata[ 6];
            if(wen[ 7]) tcfg_initval[ 7]<=wdata[ 7];
            if(wen[ 8]) tcfg_initval[ 8]<=wdata[ 8];
            if(wen[ 9]) tcfg_initval[ 9]<=wdata[ 9];
            if(wen[10]) tcfg_initval[10]<=wdata[10];
            if(wen[11]) tcfg_initval[11]<=wdata[11];
            if(wen[12]) tcfg_initval[12]<=wdata[12];
            if(wen[13]) tcfg_initval[13]<=wdata[13];
            if(wen[14]) tcfg_initval[14]<=wdata[14];
            if(wen[15]) tcfg_initval[15]<=wdata[15];
            if(wen[16]) tcfg_initval[16]<=wdata[16];
            if(wen[17]) tcfg_initval[17]<=wdata[17];
            if(wen[18]) tcfg_initval[18]<=wdata[18];
            if(wen[19]) tcfg_initval[19]<=wdata[19];
            if(wen[20]) tcfg_initval[20]<=wdata[20];
            if(wen[21]) tcfg_initval[21]<=wdata[21];
            if(wen[22]) tcfg_initval[22]<=wdata[22];
            if(wen[23]) tcfg_initval[23]<=wdata[23];
            if(wen[24]) tcfg_initval[24]<=wdata[24];
            if(wen[25]) tcfg_initval[25]<=wdata[25];
            if(wen[26]) tcfg_initval[26]<=wdata[26];
            if(wen[27]) tcfg_initval[27]<=wdata[27];
            if(wen[28]) tcfg_initval[28]<=wdata[28];
            if(wen[29]) tcfg_initval[29]<=wdata[29];
            if(wen[30]) tcfg_initval[30]<=wdata[30];
            if(wen[31]) tcfg_initval[31]<=wdata[31];
        end
    
    reg just_set_timer;
    always @(posedge clk)
        if(software_query_en&&addr==`CSR_TID&&wen[`TCFG_INITVAL])
            just_set_timer<=1;
        else just_set_timer<=0;
    
    //TVAL
    reg time_out;
    always @(posedge clk)
        if(~rstn) begin
            csr_tval <= 0;
            time_out <= 0;
        end
        //FIXME: 设置TCFG.InitVal后自动重置定时器，这在手册中未提及
        else if(csr_tval==0||just_set_timer) begin
            time_out <= 0;
            if(tcfg_peridic) csr_tval<={tcfg_initval[`TCFG_INITVAL],2'd0};
        end else if(tcfg_en) begin
            csr_tval<=csr_tval-1;
            time_out<=csr_tval==1;
        end
    
    //TICLR
    always @(posedge clk)
        if(~rstn||software_query_en&&addr==`CSR_TICLR&&wen[`TICLR_CLR]&&wdata[`TICLR_CLR])
            timer_int <= 0;
        else if(time_out)
            timer_int <= 1;
    
    //CTAG
    always @(posedge clk)
        if(software_query_en&&addr==`CSR_CTAG) begin
            if(wen[ 0]) csr_ctag[ 0]<=wdata[ 0];
            if(wen[ 1]) csr_ctag[ 1]<=wdata[ 1];
            if(wen[ 2]) csr_ctag[ 2]<=wdata[ 2];
            if(wen[ 3]) csr_ctag[ 3]<=wdata[ 3];
            if(wen[ 4]) csr_ctag[ 4]<=wdata[ 4];
            if(wen[ 5]) csr_ctag[ 5]<=wdata[ 5];
            if(wen[ 6]) csr_ctag[ 6]<=wdata[ 6];
            if(wen[ 7]) csr_ctag[ 7]<=wdata[ 7];
            if(wen[ 8]) csr_ctag[ 8]<=wdata[ 8];
            if(wen[ 9]) csr_ctag[ 9]<=wdata[ 9];
            if(wen[10]) csr_ctag[10]<=wdata[10];
            if(wen[11]) csr_ctag[11]<=wdata[11];
            if(wen[12]) csr_ctag[12]<=wdata[12];
            if(wen[13]) csr_ctag[13]<=wdata[13];
            if(wen[14]) csr_ctag[14]<=wdata[14];
            if(wen[15]) csr_ctag[15]<=wdata[15];
            if(wen[16]) csr_ctag[16]<=wdata[16];
            if(wen[17]) csr_ctag[17]<=wdata[17];
            if(wen[18]) csr_ctag[18]<=wdata[18];
            if(wen[19]) csr_ctag[19]<=wdata[19];
            if(wen[20]) csr_ctag[20]<=wdata[20];
            if(wen[21]) csr_ctag[21]<=wdata[21];
            if(wen[22]) csr_ctag[22]<=wdata[22];
            if(wen[23]) csr_ctag[23]<=wdata[23];
            if(wen[24]) csr_ctag[24]<=wdata[24];
            if(wen[25]) csr_ctag[25]<=wdata[25];
            if(wen[26]) csr_ctag[26]<=wdata[26];
            if(wen[27]) csr_ctag[27]<=wdata[27];
            if(wen[28]) csr_ctag[28]<=wdata[28];
            if(wen[29]) csr_ctag[29]<=wdata[29];
            if(wen[30]) csr_ctag[30]<=wdata[30];
            if(wen[31]) csr_ctag[31]<=wdata[31];
        end
    //end CSR update
    ///////////////////////////////////////

    ///////////////////////////////////////
    //CSR read
    always @(posedge clk)
        if(software_query_en)
            case(addr)
            `CSR_CRMD     : rdata <= csr_crmd     ;
            `CSR_PRMD     : rdata <= csr_prmd     ;
            `CSR_EUEN     : rdata <= csr_euen     ;
            `CSR_ECFG     : rdata <= csr_ecfg     ;
            `CSR_ESTAT    : rdata <= csr_estat    ;
            `CSR_ERA      : rdata <= csr_era      ;
            `CSR_BADV     : rdata <= csr_badv     ;
            `CSR_EENTRY   : rdata <= csr_eentry   ;
            `CSR_TLBIDX   : rdata <= csr_tlbidx   ;
            `CSR_TLBEHI   : rdata <= csr_tlbehi   ;
            `CSR_TLBELO0  : rdata <= csr_tlbelo0  ;
            `CSR_TLBELO1  : rdata <= csr_tlbelo1  ;
            `CSR_ASID     : rdata <= csr_asid     ;
            `CSR_PGDL     : rdata <= csr_pgdl     ;
            `CSR_PGDH     : rdata <= csr_pgdh     ;
            `CSR_PGD      : rdata <= csr_pgd      ;
            `CSR_CPUID    : rdata <= csr_cpuid    ;
            `CSR_SAVE0    : rdata <= csr_save0    ;
            `CSR_SAVE1    : rdata <= csr_save1    ;
            `CSR_SAVE2    : rdata <= csr_save2    ;
            `CSR_SAVE3    : rdata <= csr_save3    ;
            `CSR_TID      : rdata <= csr_tid      ;
            `CSR_TCFG     : rdata <= csr_tcfg     ;
            `CSR_TVAL     : rdata <= csr_tval     ;
            `CSR_TICLR    : rdata <= csr_ticlr    ;
            `CSR_LLBCTL   : rdata <= csr_llbctl   ;
            `CSR_TLBRENTRY: rdata <= csr_tlbrentry;
            `CSR_CTAG     : rdata <= csr_ctag     ;
            `CSR_DMW0     : rdata <= csr_dmw0     ;
            `CSR_DMW1     : rdata <= csr_dmw1     ;
            endcase
    
    assign privilege = crmd_plv;
    assign era_out = csr_era;
    assign eentry = csr_eentry;
    assign tlbrentry = csr_tlbrentry;
    assign has_interrupt = crmd_ie&&(ecfg_lie&{csr_estat[`ESTAT_IS]})!=0;
    assign translate_mode = {crmd_pg,crmd_da};
    assign direct_i_mat = crmd_datf;
    assign direct_d_mat = crmd_datm;
    assign tlb_index_out = tlbidx_index;
    assign tlb_ps_out = tlbidx_ps;
    assign tlb_ne_out = tlbidx_ne;
    assign tlb_vppn_out = tlbehi_vppn;
    assign tlb_valid_0_out = csr_tlbelo0[`TLBELO_V];
    assign tlb_dirty_0_out = csr_tlbelo0[`TLBELO_D];
    assign tlb_priviledge_0_out = csr_tlbelo0[`TLBELO_PLV];
    assign tlb_mat_0_out = csr_tlbelo0[`TLBELO_V];
    assign tlb_global_0_out = csr_tlbelo0[`TLBELO_G];
    assign tlb_ppn_0_out = csr_tlbelo0[`TLBELO_PPN];
    assign tlb_valid_1_out = csr_tlbelo1[`TLBELO_V];
    assign tlb_dirty_1_out = csr_tlbelo1[`TLBELO_D];
    assign tlb_priviledge_1_out = csr_tlbelo1[`TLBELO_PLV];
    assign tlb_mat_1_out = csr_tlbelo1[`TLBELO_V];
    assign tlb_global_1_out = csr_tlbelo1[`TLBELO_G];
    assign tlb_ppn_1_out = csr_tlbelo1[`TLBELO_PPN];
    assign asid_out = asid_asid;
    assign pgdl_out = csr_pgdl;
    assign pgdh_out = csr_pgdh;
    assign llbit = llbctl_rollb;
    assign tid = csr_tid;
    assign cache_tag = csr_ctag;
    //end CSR read
    ///////////////////////////////////////
endmodule
