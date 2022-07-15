`timescale 1ns / 1ps
`include "../exception.vh"
module TLB#(
    parameter TLBNUM = 16,
    parameter VALEN = 32
    )(
    input                       clk,
    //search port pc
    input  [              19:0] s0_vpn,
    input  [               7:0] s0_asid,
    input  [               1:0] s0_plv,
    input  [               1:0] s0_mem_type,
    output                      s0_found,
    //output [$clog2(TLBNUM)-1:0] s0_index,
    output     [           19:0] s0_pfn,
    output     [            1:0] s0_mat,
    output reg [            6:0] s0_exception,
    // output reg                   s0_d,
    // output reg                   s0_v,

    //search port data
    input  [              19:0] s1_vpn,
    input  [               7:0] s1_asid,
    input  [               1:0] s1_plv,
    input  [               1:0] s1_mem_type,
    output                      s1_found,
    //output [$clog2(TLBNUM)-1:0] s1_index,
    output     [          19:0] s1_pfn,
    output     [           1:0] s1_mat,
    output reg [           6:0] s1_exception,
    // output reg                  s1_d,
    // output reg                  s1_v,

    //write port
    input                       we,
    input  [$clog2(TLBNUM)-1:0] w_index,
    input  [              18:0] w_vpn2,
    input  [               7:0] w_asid,
    input  [               5:0] w_ps,
    input                       w_e,
    input                       w_g,
    input  [              19:0] w_pfn0,
    input  [               1:0] w_mat0,
    input  [               1:0] w_plv0,
    input                       w_d0,
    input                       w_v0,
    input  [              19:0] w_pfn1,
    input  [               1:0] w_mat1,
    input  [               1:0] w_plv1,
    input                       w_d1,
    input                       w_v1,

    //read port
    input  [$clog2(TLBNUM)-1:0] r_index,
    output [              18:0] r_vpn2,
    output [               7:0] r_asid,
    output [               5:0] r_ps,
    output                      r_e,
    output                      r_g,
    output [              19:0] r_pfn0,
    output [               1:0] r_mat0,
    output [               1:0] r_plv0,
    output                      r_d0,
    output                      r_v0,
    output [              19:0] r_pfn1,
    output [               1:0] r_mat1,
    output [               1:0] r_plv1,
    output                      r_d1,
    output                      r_v1
    );

    parameter FETCH = 2'b0;
    parameter LOAD = 2'd1;
    parameter STORE = 2'd2;

    wire [TLBNUM-1:0] found0, found1;

    reg found_v0, found_v1;
    reg found_d0, found_d1;
    reg [1:0] found_mat0, found_mat1;
    reg [1:0] found_plv0, found_plv1;
    reg [19:0] found_pfn0, found_pfn1;



    /* memory */
    reg [18:0]  tlb_vpn2    [0:TLBNUM-1];
    reg [ 7:0]  tlb_asid    [0:TLBNUM-1];
    reg [ 5:0]  tlb_ps      [0:TLBNUM-1];
    reg         tlb_g       [0:TLBNUM-1];
    reg         tlb_e       [0:TLBNUM-1];
    reg [19:0]  tlb_pfn0    [0:TLBNUM-1];
    reg [ 1:0]  tlb_mat0    [0:TLBNUM-1];
    reg [ 1:0]  tlb_plv0    [0:TLBNUM-1];
    reg         tlb_d0      [0:TLBNUM-1];
    reg         tlb_v0      [0:TLBNUM-1];
    reg [19:0]  tlb_pfn1    [0:TLBNUM-1];
    reg [ 1:0]  tlb_mat1    [0:TLBNUM-1];
    reg [ 1:0]  tlb_plv1    [0:TLBNUM-1];
    reg         tlb_d1      [0:TLBNUM-1];
    reg         tlb_v1      [0:TLBNUM-1];

    /* hit judge */
    genvar i;
    for(i = 0; i < TLBNUM; i = i + 1) begin
        assign found0[i] = tlb_e[i] && 
                           (tlb_g[i] || (tlb_asid[i] == s0_asid)) && 
                           (tlb_vpn2[i] == s0_vpn[19:1]);
        
        assign found1[i] = tlb_e[i] && 
                           (tlb_g[i] || (tlb_asid[i] == s1_asid)) && 
                           (tlb_vpn2[i] == s1_vpn[19:1]);


    end
    /* TLB hit */
    assign s0_found = |found0;
    assign s1_found = |found1;
    assign s0_pfn = found_pfn0;
    assign s1_pfn = found_pfn1;
    assign s0_mat = found_mat0;
    assign s1_mat = found_mat1;

    integer j;
    always @(*) begin
        found_v0 = 0; found_v1 = 0;
        found_d0 = 0; found_d1 = 0;
        found_mat0 = 0; found_mat1 = 0;
        found_plv0 = 0; found_plv1 = 0;
        found_pfn0 = 0; found_pfn1 = 0;
        for(j = 0; j < TLBNUM; j = j + 1) begin
            if(found0[j]) begin
                if(!s0_vpn[0]) begin
                    found_v0   = tlb_v0[j];
                    found_d0   = tlb_d0[j];
                    found_mat0 = tlb_d0[j];
                    found_plv0 = tlb_plv0[j];
                    found_pfn0 = tlb_pfn0[j];
                end
                else begin
                    found_v0   = tlb_v1[j];
                    found_d0   = tlb_d1[j];
                    found_mat0 = tlb_d1[j];
                    found_plv0 = tlb_plv1[j];
                    found_pfn0 = tlb_pfn1[j];
                end
            end
            if(found1[j]) begin
                if(!s1_vpn[0]) begin
                    found_v1   = tlb_v0[j];
                    found_d1   = tlb_d0[j];
                    found_mat1 = tlb_d0[j];
                    found_plv1 = tlb_plv0[j];
                    found_pfn1 = tlb_pfn0[j];
                end
                else begin
                    found_v1   = tlb_v1[j];
                    found_d1   = tlb_d1[j];
                    found_mat1 = tlb_d1[j];
                    found_plv1 = tlb_plv1[j];
                    found_pfn1 = tlb_pfn1[j];
                end
            end
        end
    end

    /* exeption coping */
    always @(posedge clk) begin
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
    always @(posedge clk) begin
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

    /* TLB read */
    assign r_vpn2   =  (r_index == w_index) && we ? w_vpn2 : tlb_vpn2    [r_index];
    assign r_asid   =  (r_index == w_index) && we ? w_asid : tlb_asid    [r_index];
    assign r_e      =  (r_index == w_index) && we ? w_e    : tlb_e       [r_index];
    assign r_g      =  (r_index == w_index) && we ? w_g    : tlb_g       [r_index];
    assign r_pfn0   =  (r_index == w_index) && we ? w_pfn0 : tlb_pfn0    [r_index];
    assign r_mat0   =  (r_index == w_index) && we ? w_mat0 : tlb_mat0    [r_index];
    assign r_plv0   =  (r_index == w_index) && we ? w_plv0 : tlb_plv0    [r_index];
    assign r_d0     =  (r_index == w_index) && we ? w_d0   : tlb_d0      [r_index];
    assign r_v0     =  (r_index == w_index) && we ? w_v0   : tlb_v0      [r_index];
    assign r_pfn1   =  (r_index == w_index) && we ? w_pfn1 : tlb_pfn1    [r_index];
    assign r_mat1   =  (r_index == w_index) && we ? w_mat1 : tlb_mat1    [r_index];
    assign r_plv1   =  (r_index == w_index) && we ? w_plv1 : tlb_plv1    [r_index];
    assign r_d1     =  (r_index == w_index) && we ? w_d1   : tlb_d1      [r_index];
    assign r_v1     =  (r_index == w_index) && we ? w_v1   : tlb_v1      [r_index];

    /* TLB write */
    always @(posedge clk) begin
        if(we) begin
            tlb_vpn2[w_index] <= w_vpn2;
            tlb_asid[w_index] <= w_asid;
            tlb_ps  [w_index] <= w_ps;
            tlb_g   [w_index] <= w_g;
            tlb_e   [w_index] <= w_e;
            tlb_pfn0[w_index] <= w_pfn0;
            tlb_mat0[w_index] <= w_mat0;
            tlb_plv0[w_index] <= w_plv0;
            tlb_d0  [w_index] <= w_d0;
            tlb_v0  [w_index] <= w_v0;
            tlb_pfn1[w_index] <= w_pfn1;
            tlb_mat1[w_index] <= w_mat1;
            tlb_plv1[w_index] <= w_plv1;
            tlb_d1  [w_index] <= w_d1;
            tlb_v1  [w_index] <= w_v1;
        end
    end
endmodule 
 