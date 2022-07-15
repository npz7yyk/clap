`timescale 1ns / 1ps
`include "../exception.vh"
module TLB_found_signal#(
    parameter TLBNUM = 16
    )(
    input  [    TLBNUM*20-1:0]  all_pfn0,
    input  [     TLBNUM*2-1:0]  all_mat0,
    input  [     TLBNUM*2-1:0]  all_plv0,
    input  [       TLBNUM-1:0]  all_d0,
    input  [       TLBNUM-1:0]  all_v0,
    input  [       TLBNUM-1:0]  found0,
    input                       odd0_bit,
    input  [    TLBNUM*20-1:0]  all_pfn1,
    input  [     TLBNUM*2-1:0]  all_mat1,
    input  [     TLBNUM*2-1:0]  all_plv1,
    input  [       TLBNUM-1:0]  all_d1,
    input  [       TLBNUM-1:0]  all_v1,
    input  [       TLBNUM-1:0]  found1,
    input                       odd1_bit,

    output reg                  found_v0, 
    output reg                  found_v1,
    output reg                  found_d0, 
    output reg                  found_d1,
    output reg[            1:0] found_mat0, 
    output reg[            1:0] found_mat1,
    output reg[            1:0] found_plv0, 
    output reg[            1:0] found_plv1,
    output reg[           19:0] found_pfn0, 
    output reg[           19:0] found_pfn1

    );


    genvar j;
    for(j = 0; j < TLBNUM; j = j + 1) begin
        always @(*) begin
            found_v0 = 0;
            found_d0 = 0;
            found_mat0 = 0; 
            found_plv0 = 0; 
            found_pfn0 = 0;
            if(found0[j]) begin
                if(!odd0_bit) begin
                    found_v0   = all_v0[j];
                    found_d0   = all_d0[j];
                    found_mat0 = all_mat0[2*j+1:2*j];
                    found_plv0 = all_plv0[2*j+1:2*j];
                    found_pfn0 = all_pfn0[20*j+19:20*j];
                end
                else begin
                    found_v0   = all_v1[j];
                    found_d0   = all_d1[j];
                    found_mat0 = all_mat1[2*j+1:2*j];
                    found_plv0 = all_plv1[2*j+1:2*j];
                    found_pfn0 = all_pfn1[20*j+19:20*j];
                end
            end
        end
        always @(*) begin
            found_v1 = 0;
            found_d1 = 0;
            found_mat1 = 0;
            found_plv1 = 0;
            found_pfn1 = 0;

            if(found1[j]) begin
                if(!odd1_bit) begin
                    found_v1   = all_v0[j];
                    found_d1   = all_d0[j];
                    found_mat1 = all_mat0[2*j+1:2*j];
                    found_plv1 = all_plv0[2*j+1:2*j];
                    found_pfn1 = all_pfn0[20*j+19:20*j];
                end
                else begin
                    found_v1   = all_v1[j];
                    found_d1   = all_d1[j];
                    found_mat1 = all_mat1[2*j+1:2*j];
                    found_plv1 = all_plv1[2*j+1:2*j];
                    found_pfn1 = all_pfn1[20*j+19:20*j];
                end
            end
        end
    end
endmodule 
 