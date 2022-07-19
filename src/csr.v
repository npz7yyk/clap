`include "csr.vh"

module csr(
    input clk,
    input rstn,
    //software query port (exe stage)
    input  [13:0] addr,
    output [31:0] rdata,    //read first
    input  [31:0] wen,
    input  [31:0] wdata,
    
    //current machine state
    output [1:0] privilege,
    output [8:0] coreid,

    //exception
    input store_state,      //pplv <= plv , pie <= ie 
    input restore_state,    //plv  <= pplv, ie  <= pie
    output [5:0] ecode_out,
    output [8:0] subecode_out,
    input [6:0] expcode_in,
    input expcode_wen,
    output [31:0] era_out,
    input [31:0] era_in,
    input era_wen,
    input [31:0] badv_in,
    input badv_wen,
    output [31:0] eentry,tlbrentry,

    //interrupt
    output [0:0] ie,
    output [12:0] lie,
    output software_int0,software_int1,//软中断使能
    output intercore_int,              //核间中断
    output timer_int,                  //定时器中断
    input [7:0] hardward_int,

    //MMU
    output [1:0] translate_mode,    //01: direct, 10: paged
    output direct_i_mat, //处于直接地址翻译模式时，存储访问类型
    output direct_d_mat, //0: 非缓存, 1: 可缓存
    //直接映射窗口0
    output dmw0_plv0,
    output dmw0_plv3,
    output dmw0_mat,
    output [31:29] dmw0_vseg,dmw0_pseg,
    //直接映射窗口1
    output dmw1_plv0,
    output dmw1_plv3,
    output dmw1_mat,
    output [31:29] dmw1_vseg,dmw1_pseg,
    //TLB (read port)
    output [15:0] tlb_index_out,
    output [5:0] tlb_ps_out,
    output tlb_ne_out,
    output [18:0] tlb_vppn_out,
    output tlb_valid_0_out,             tlb_valid_1_out,
    output tlb_dirty_0_out,             tlb_dirty_1_out,
    output [1:0] tlb_priviledge_0_out,  tlb_priviledge_1_out,
    output [1:0] tlb_mat_0_out,         tlb_mat_1_out,
    output [23:0] ppn_0_out,            ppn_1_out,
    output [9:0] asid_out,
    output [31:0] pgdl_out,pgdh_out,pgd_out,
    
    //TLB (write port)
    input [15:0] tlb_index_in,
    input tlb_index_we,
    input [5:0] tlb_ps_in,
    input tlb_ps_in_we,
    input tlb_ne_in,
    input tlb_ne_in_we,
    input [18:0] tlb_vppn_in,
    input tlb_vppn_we,
    input tlb_valid_0_in,               tlb_valid_1_in,
    input tlb_valid_0_wen,              tlb_valid_1_wen,
    input tlb_dirty_0_in,               tlb_dirty_1_in,
    input tlb_dirty_0_wen,              tlb_dirty_1_wen,
    input [1:0] tlb_priviledge_0_in,    tlb_priviledge_1_in,
    input tlb_priviledge_0_wen,         tlb_priviledge_1_wen,
    input [1:0] tlb_mat_0_in,           tlb_mat_1_in,
    input tlb_mat_0_wen,                tlb_mat_1_wen,
    input [23:0] ppn_0_in,              ppn_1_in,
    input ppn_0_wen,                    ppn_1_wen,
    input [31:0] pgd_in,
    input pdg_wen,

    //ll bit
    output llbit,
    input llbit_set,
    input llbit_clear,

    //timer
    output [31:0] tid
);
endmodule
