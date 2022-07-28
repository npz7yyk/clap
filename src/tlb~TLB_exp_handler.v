`include "exception.vh"
/* verilator lint_off DECLFILENAME */
module TLB_exp_handler(
    input s0_found,
    input s0_en,
    input [1:0] s0_mem_type,
    input s0_dmw_hit,
    input found_v0,
    input found_d0,
    input [1:0] s0_plv,
    input [1:0] found_plv0,
    output [6:0] s0_exception,

    input [31:0] s0_vaddr,

    input s1_found,
    input s1_en,
    input [1:0] s1_mem_type,
    input s1_dmw_hit,
    input found_v1,
    input found_d1,
    input [1:0] s1_plv,
    input [1:0] found_plv1,
    output [6:0] s1_exception,

    input [31:0] s1_vaddr
    );

    parameter FETCH = 2'd2;
    parameter LOAD = 2'd0;
    parameter STORE = 2'd1;
    reg [6:0] s0_exception_temp, s1_exception_temp;
    /* exeption coping */
    always @(*) begin
        s0_exception_temp = 0;
        if(s0_plv == 2'd3 && s0_vaddr[31]) s0_exception_temp = `EXP_ADEF;
        // TLBR
        else if(!s0_found)  s0_exception_temp = `EXP_TLBR;
        // PIF, PIL, PIS
        else if(!found_v0) begin
            case (s0_mem_type)//%Warning-CASEINCOMPLETE: /home/songxiao/Desktop/chiplab/IP/myCPU/tlb~TLB_exp_handler.v:41:13: Case values incompletely covered (example pattern 0x3)
                FETCH: s0_exception_temp = `EXP_PIF;
                LOAD:  s0_exception_temp = `EXP_PIL;
                STORE: s0_exception_temp = `EXP_PIS; 
            endcase
        end
        //PPI
        else if(s0_plv > found_plv0) s0_exception_temp = `EXP_PPI;
        //PME
        else if(s0_mem_type == STORE && !found_d0) s0_exception_temp = `EXP_PME;
    end
    always @(*) begin
        s1_exception_temp = 0;
        // TLBR
        if(s1_plv == 2'd3 && s1_vaddr[31]) s1_exception_temp = `EXP_ADEM;
        else if(!s1_found)  s1_exception_temp = `EXP_TLBR;
        // PIF, PIL, PIS
        else if(!found_v1) begin
            case (s1_mem_type)//%Warning-CASEINCOMPLETE: /home/songxiao/Desktop/chiplab/IP/myCPU/tlb~TLB_exp_handler.v:59:13: Case values incompletely covered (example pattern 0x3)
                FETCH: s1_exception_temp = `EXP_PIF;
                LOAD:  s1_exception_temp = `EXP_PIL;
                STORE: s1_exception_temp = `EXP_PIS; 
            endcase
        end
        //PPI
        else if(s1_plv > found_plv1) s1_exception_temp = `EXP_PPI;
        //PME
        else if(s1_mem_type == STORE && !found_d1) s1_exception_temp = `EXP_PME;
    end

    assign s0_exception = s0_exception_temp & {7{~s0_dmw_hit}} & {7{s0_en}};
    assign s1_exception = s1_exception_temp & {7{~s1_dmw_hit}} & {7{s1_en}};

endmodule
