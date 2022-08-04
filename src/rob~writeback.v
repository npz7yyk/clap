`include "clap_config.vh"
`include "exception.vh"
`include "csr.vh"

/* verilator lint_off DECLFILENAME */
module writeback
(   
    (* mark_debug = "true" *)input eu0_valid,eu1_valid,
    (* mark_debug = "true" *)input [31:0] eu0_data,eu1_data,
    (* mark_debug = "true" *)input [4:0] eu0_rd,eu1_rd,
    (* mark_debug = "true" *)input [31:0] eu0_pc,eu1_pc,
    (* mark_debug = "true" *)input [6:0] eu0_exception,
    input [31:0] eu0_badv,
    (* mark_debug = "true" *)input [31:0] eu0_inst,eu1_inst,

    //connect to register file
    output wen0,wen1,
    output [4:0] waddr0,waddr1,
    output [31:0] wdata0,wdata1,

    //debug port
    output [31:0] debug0_wb_pc,
    output [ 3:0] debug0_wb_rf_wen,
    output [ 4:0] debug0_wb_rf_wnum,
    output [31:0] debug0_wb_rf_wdata,
    output [31:0] debug0_wb_inst,

    output [31:0] debug1_wb_pc,
    output [ 3:0] debug1_wb_rf_wen,
    output [ 4:0] debug1_wb_rf_wnum,
    output [31:0] debug1_wb_rf_wdata,
    output [31:0] debug1_wb_inst,

    //connect to PC
    output set_pc,
    output [31:0] pc,

    //CSR
    input [31:0] eentry,tlbrentry,
    output [31:0] era,
    output era_wen,
    output store_state,
    output back_to_direct_translate,
    output [18:0] vppn,
    output vppn_we,
    output [6:0] expcode_out,
    output expcode_wen,
    output [31:0] badv,
    output badv_wen,
    input [`PGD_BASE] pgdl,pgdh,
    output [`PGD_BASE] pgd,
    output pgd_wen
);
    wire has_exception = eu0_valid && eu0_exception!=0;
    reg set_badv;
    reg set_vppn;
    always @* begin
        set_badv = 0;
        if(eu0_valid)
            case(eu0_exception)
            `EXP_TLBR, `EXP_ADEF, `EXP_ADEM, `EXP_ALE, `EXP_PIL, `EXP_PIS,
            `EXP_PIF, `EXP_PME, `EXP_PPI:
                set_badv = 1;
            default: set_badv = 0;
            endcase
    end
    always @* begin
        set_vppn = 0;
        if(eu0_valid)
            case(eu0_exception)
            `EXP_TLBR, `EXP_PIL, `EXP_PIS, `EXP_PIF, `EXP_PME, `EXP_PPI:
                set_vppn = 1;
            default: set_vppn = 0;
            endcase
    end
    assign set_pc = has_exception;
    assign store_state = has_exception;
    assign expcode_wen = has_exception;
    assign era_wen     = has_exception;
    wire is_tlb_exp = eu0_exception==`EXP_TLBR;
    assign pc = is_tlb_exp ? tlbrentry:eentry;
    assign back_to_direct_translate = is_tlb_exp;
    assign era = eu0_pc;
    assign expcode_out = eu0_exception;
    assign badv = eu0_badv;
    assign pgd = eu0_badv[31]?pgdh:pgdl;
    assign badv_wen = set_badv;
    assign pgd_wen = set_badv;
    assign vppn = eu0_badv[31:13];
    assign vppn_we = set_vppn;

    assign wen0 = eu0_valid && eu0_exception==0;
    //第一条指令出现异常时，第二条指令不能被写回
    assign wen1 = eu1_valid && !has_exception;
    assign waddr0 = eu0_rd;
    assign waddr1 = eu1_rd;
    assign wdata0 = eu0_data;
    assign wdata1 = eu1_data;
    
    assign debug0_wb_pc = eu0_pc;
    assign debug0_wb_rf_wen = {4{wen0}};
    assign debug0_wb_rf_wnum = eu0_rd;
    assign debug0_wb_rf_wdata = eu0_data;
    assign debug0_wb_inst = eu0_inst;

    assign debug1_wb_pc = eu1_pc;
    assign debug1_wb_rf_wen = {4{wen1}};
    assign debug1_wb_rf_wnum = eu1_rd;
    assign debug1_wb_rf_wdata = eu1_data;
    assign debug1_wb_inst = eu1_inst;
endmodule
