`timescale 1ns / 1ps
`include "../exception.vh"
module TLB_exp_handler#(
    parameter TLBNUM = 16
    )(
    
    input s0_found,
    input [1:0] s0_mem_type,
    input found_v0,
    input found_d0,
    input [1:0] s0_plv,
    input [1:0] found_plv0,
    output reg [6:0] s0_exception,

    input s1_found,
    input [1:0] s1_mem_type,
    input found_v1,
    input found_d1,
    input [1:0] s1_plv,
    input [1:0] found_plv1,
    output reg [6:0] s1_exception
    );

    parameter FETCH = 2'b0;
    parameter LOAD = 2'd1;
    parameter STORE = 2'd2;

    /* exeption coping */
    always @(*) begin
        s0_exception = 0;
        // TLBR
        if(!s0_found)  s0_exception = `EXP_TLBR;
        // PIF, PIL, PIS
        else if(!found_v0) begin
            case (s0_mem_type)
                FETCH: s0_exception = `EXP_PIF;
                LOAD:  s0_exception = `EXP_PIL;
                STORE: s0_exception = `EXP_PIS; 
            endcase
        end
        //PPI
        else if(s0_plv > found_plv0) s0_exception = `EXP_PPI;
        //PME
        else if(s0_mem_type == STORE && !found_d0) s0_exception = `EXP_PME;
    end
    always @(*) begin
        s1_exception = 0;
        // TLBR
        if(!s1_found)  s1_exception = `EXP_TLBR;
        // PIF, PIL, PIS
        else if(!found_v1) begin
            case (s1_mem_type)
                FETCH: s1_exception = `EXP_PIF;
                LOAD:  s1_exception = `EXP_PIL;
                STORE: s1_exception = `EXP_PIS; 
            endcase
        end
        //PPI
        else if(s1_plv > found_plv1) s1_exception = `EXP_PPI;
        //PME
        else if(s1_mem_type == STORE && !found_d1) s1_exception = `EXP_PME;
    end
endmodule