`include "exception.vh"
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

    input s1_found,
    input s1_en,
    input [1:0] s1_mem_type,
    input s1_dmw_hit,
    input found_v1,
    input found_d1,
    input [1:0] s1_plv,
    input [1:0] found_plv1,
    output [6:0] s1_exception
    );

    parameter FETCH = 2'd2;
    parameter LOAD = 2'd0;
    parameter STORE = 2'd1;
    reg [6:0] s0_exception_temp, s1_exception_temp;
    /* exeption coping */
    always @(*) begin
        s0_exception_temp = 0;
        // TLBR
        if(!s0_found)  s0_exception_temp = `EXP_TLBR;
        // PIF, PIL, PIS
        else if(!found_v0) begin
            case (s0_mem_type)
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
        if(!s1_found)  s1_exception_temp = `EXP_TLBR;
        // PIF, PIL, PIS
        else if(!found_v1) begin
            case (s1_mem_type)
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
