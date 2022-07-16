module TLB_memory#(
    parameter TLBNUM = 16
    )(
    input clk,
    //read all port
    output [    TLBNUM*19-1:0]  all_vpn2,
    output [     TLBNUM*8-1:0]  all_asid,
    output [     TLBNUM*6-1:0]  all_ps,
    output [       TLBNUM-1:0]  all_g,
    output [       TLBNUM-1:0]  all_e,
    output [    TLBNUM*20-1:0]  all_pfn0,
    output [     TLBNUM*2-1:0]  all_mat0,
    output [     TLBNUM*2-1:0]  all_plv0,
    output [       TLBNUM-1:0]  all_d0,
    output [       TLBNUM-1:0]  all_v0,
    output [    TLBNUM*20-1:0]  all_pfn1,
    output [     TLBNUM*2-1:0]  all_mat1,
    output [     TLBNUM*2-1:0]  all_plv1,
    output [       TLBNUM-1:0]  all_d1,
    output [       TLBNUM-1:0]  all_v1,
    
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
    output                      r_v1,

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
    input                       w_v1


    );
    reg [18:0]  tlb_vpn2    [TLBNUM-1:0];
    reg [7:0]   tlb_asid    [TLBNUM-1:0];
    reg [5:0]   tlb_ps      [TLBNUM-1:0];
    reg         tlb_g       [TLBNUM-1:0];
    reg         tlb_e       [TLBNUM-1:0];
    reg [19:0]  tlb_pfn0    [TLBNUM-1:0];
    reg [1:0]   tlb_mat0    [TLBNUM-1:0];
    reg [1:0]   tlb_plv0    [TLBNUM-1:0];
    reg         tlb_d0      [TLBNUM-1:0];
    reg         tlb_v0      [TLBNUM-1:0];
    reg [19:0]  tlb_pfn1    [TLBNUM-1:0];
    reg [1:0]   tlb_mat1    [TLBNUM-1:0];
    reg [1:0]   tlb_plv1    [TLBNUM-1:0];
    reg         tlb_d1      [TLBNUM-1:0];
    reg         tlb_v1      [TLBNUM-1:0];

    genvar i;
    for (i = 0; i < TLBNUM; i = i + 1)begin
        assign all_vpn2[i*19+18:i*19]   = tlb_vpn2[i];
        assign all_asid[i*8+7:i*8]      = tlb_asid[i];
        assign all_ps[i*6+5:i*6]        = tlb_ps  [i];
        assign all_g[i]                 = tlb_g   [i];
        assign all_e[i]                 = tlb_e   [i];
        assign all_pfn0[20*i+19:20*i]   = tlb_pfn0[i];
        assign all_mat0[2*i+1:2*i]      = tlb_mat0[i];
        assign all_plv0[2*i+1:2*i]      = tlb_plv0[i];
        assign all_d0[i]                = tlb_d0  [i];
        assign all_v0[i]                = tlb_v0  [i];
        assign all_pfn1[20*i+19:20*i]   = tlb_pfn1[i];
        assign all_mat1[2*i+1:2*i]      = tlb_mat1[i];
        assign all_plv1[2*i+1:2*i]      = tlb_plv1[i];
        assign all_d1[i]                = tlb_d1  [i];
        assign all_v1[i]                = tlb_v1  [i];
    end
    
    assign r_vpn2   =  all_vpn2    [r_index];
    assign r_asid   =  all_asid    [r_index];
    assign r_ps     =  all_ps      [r_index];
    assign r_e      =  all_e       [r_index];
    assign r_g      =  all_g       [r_index];
    assign r_pfn0   =  all_pfn0    [r_index];
    assign r_mat0   =  all_mat0    [r_index];
    assign r_plv0   =  all_plv0    [r_index];
    assign r_d0     =  all_d0      [r_index];
    assign r_v0     =  all_v0      [r_index];
    assign r_pfn1   =  all_pfn1    [r_index];
    assign r_mat1   =  all_mat1    [r_index];
    assign r_plv1   =  all_plv1    [r_index];
    assign r_d1     =  all_d1      [r_index];
    assign r_v1     =  all_v1      [r_index];

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
