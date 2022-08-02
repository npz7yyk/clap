`include "clap_config.vh"

/* verilator lint_off DECLFILENAME */
module TLB_memory#(
    parameter TLBNUM = 32
    )(
    input                       clk,
    input [               2:0]  clear_mem,
    input [               9:0]  clear_asid,
    input [              31:0]  clear_vaddr,
    //read all port
    output [    TLBNUM*19-1:0]  all_vpn2,
    output [    TLBNUM*10-1:0]  all_asid,
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
    output [               9:0] r_asid,
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
    input  [               9:0] w_asid,
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
    localparam
        CLEAR_ALL = 3'd1,
        CLEAR_G1 = 3'd2,
        CLEAR_G0_ALL = 3'd3,
        CLEAR_G0_ASID_ALL = 3'd4,
        CLEAR_G0_ASID_VA = 3'd5,
        CLEAR_G1ORASID_VA = 3'd6;
    
    reg [18:0]  tlb_vpn2    [TLBNUM-1:0];
    reg [9:0]   tlb_asid    [TLBNUM-1:0];
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
    integer k;
    initial begin
        for(k = 0; k < TLBNUM; k =  k + 1) begin
            tlb_vpn2[k] = 0;
            tlb_asid[k] = 0;
            tlb_ps[k] = 0;
            tlb_g[k] = 0;
            tlb_e[k] = 0;
            tlb_pfn0[k] = 0;
            tlb_mat0[k] = 0;
            tlb_plv0[k] = 0;
            tlb_d0[k] = 0;
            tlb_v0[k] = 0;
            tlb_pfn1[k] = 0;
            tlb_mat1[k] = 0;
            tlb_plv1[k] = 0;
            tlb_d1[k] = 0;
            tlb_v1[k] = 0;
        end
    end

    genvar i;
    for (i = 0; i < TLBNUM; i = i + 1)begin
        assign all_vpn2[i*19+18:i*19]   = tlb_vpn2[i];
        assign all_asid[i*10+9:i*10]    = tlb_asid[i];
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
    
    assign r_vpn2   =  {19{all_e[r_index]}} & tlb_vpn2    [r_index];
    assign r_asid   =  {10{all_e[r_index]}} & tlb_asid    [r_index];
    assign r_ps     =  { 6{all_e[r_index]}} & tlb_ps      [r_index];
    assign r_e      =                         tlb_e       [r_index];
    assign r_g      =  all_e[r_index]       & tlb_g       [r_index];
    assign r_pfn0   =  {20{all_e[r_index]}} & tlb_pfn0    [r_index];
    assign r_mat0   =  {2{all_e[r_index]}}  & tlb_mat0    [r_index];
    assign r_plv0   =  {2{all_e[r_index]}}  & tlb_plv0    [r_index];
    assign r_d0     =  all_e[r_index]       & tlb_d0      [r_index];
    assign r_v0     =  all_e[r_index]       & tlb_v0      [r_index];
    assign r_pfn1   =  {20{all_e[r_index]}} & tlb_pfn1    [r_index];
    assign r_mat1   =  {2{all_e[r_index]}}  & tlb_mat1    [r_index];
    assign r_plv1   =  {2{all_e[r_index]}}  & tlb_plv1    [r_index];
    assign r_d1     =  all_e[r_index]       & tlb_d1      [r_index];
    assign r_v1     =  all_e[r_index]       & tlb_v1      [r_index];

    integer j;
    always @(posedge clk) begin
        if(clear_mem != 0) begin
            case(clear_mem)
            CLEAR_ALL: begin
                for(j = 0; j < TLBNUM; j = j + 1) begin
                    tlb_e[j] <= 0;
                end
            end
            CLEAR_G0_ALL: begin
                for(j = 0; j < TLBNUM; j = j + 1) begin
                    tlb_e[j] <= tlb_e[j] & tlb_g[j];
                end
            end
            CLEAR_G0_ASID_ALL: begin
                for(j = 0; j < TLBNUM; j = j + 1) begin
                    if(!tlb_g[j] && clear_asid == tlb_asid[j]) tlb_e[j] <= 0;
                end
            end
            CLEAR_G0_ASID_VA: begin
                for(j = 0; j < TLBNUM; j = j + 1) begin
                    if(!tlb_g[j] && clear_asid == tlb_asid[j] && clear_vaddr[31:13] == tlb_vpn2[j]) 
                        tlb_e[j] <= 0;
                end
            end
            CLEAR_G1: begin
                for(j = 0; j < TLBNUM; j = j + 1) begin
                    tlb_e[j] <= tlb_e[j] & ~tlb_g[j];
                end
            end
            CLEAR_G1ORASID_VA: begin
                for(j = 0; j < TLBNUM; j = j + 1) begin
                    if((tlb_g[j] || clear_asid == tlb_asid[j]) && clear_vaddr[31:13] == tlb_vpn2[j])
                        tlb_e[j] <= 0;
                end
            end
            default: ;
            endcase
        end 
        else if(we) begin
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
