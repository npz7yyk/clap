`timescale 1ns / 1ps
`include "../exception.vh"
module TLB#(
    parameter TLBNUM = 16
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
    output     [            6:0] s0_exception,
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
    output     [           6:0] s1_exception,
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

    wire [TLBNUM-1:0] found0, found1;

    wire found_v0, found_v1;
    wire found_d0, found_d1;
    wire [1:0] found_mat0, found_mat1;
    wire [1:0] found_plv0, found_plv1;
    wire [19:0] found_pfn0, found_pfn1;

    wire [    TLBNUM*19-1:0]  all_vpn2;
    wire [     TLBNUM*8-1:0]  all_asid;
    wire [     TLBNUM*6-1:0]  all_ps;
    wire [       TLBNUM-1:0]  all_g;
    wire [       TLBNUM-1:0]  all_e;
    wire [    TLBNUM*20-1:0]  all_pfn0;
    wire [     TLBNUM*2-1:0]  all_mat0;
    wire [     TLBNUM*2-1:0]  all_plv0;
    wire [       TLBNUM-1:0]  all_d0;
    wire [       TLBNUM-1:0]  all_v0;
    wire [    TLBNUM*20-1:0]  all_pfn1;
    wire [     TLBNUM*2-1:0]  all_mat1;
    wire [     TLBNUM*2-1:0]  all_plv1;
    wire [       TLBNUM-1:0]  all_d1;
    wire [       TLBNUM-1:0]  all_v1;
    
    /* memory */
    TLB_memory memory(
        .clk        (clk),
        .all_vpn2   (all_vpn2),
        .all_asid   (all_asid),
        .all_ps     (all_ps),
        .all_g      (all_g),
        .all_e      (all_e),
        .all_pfn0   (all_pfn0),
        .all_mat0   (all_mat0),
        .all_plv0   (all_plv0),
        .all_d0     (all_d0),
        .all_v0     (all_v0),
        .all_pfn1   (all_pfn1),
        .all_mat1   (all_mat1),
        .all_plv1   (all_plv1),
        .all_d1     (all_d1),
        .all_v1     (all_v1),

        .r_index    (r_index),
        .r_vpn2     (r_vpn2),
        .r_asid     (r_asid),
        .r_ps       (r_ps),
        .r_e        (r_e),
        .r_g        (r_g),
        .r_pfn0     (r_pfn0),
        .r_mat0     (r_mat0),
        .r_plv0     (r_plv0),
        .r_d0       (r_d0),
        .r_v0       (r_v0),
        .r_pfn1     (r_pfn1),
        .r_mat1     (r_mat1),
        .r_plv1     (r_plv1),
        .r_d1       (r_d1),
        .r_v1       (r_v1),

        .we         (we),
        .w_index    (w_index),
        .w_vpn2     (w_vpn2),
        .w_asid     (w_asid),
        .w_ps       (w_ps),
        .w_e        (w_e),
        .w_g        (w_g),
        .w_pfn0     (w_pfn0),
        .w_mat0     (w_mat0),
        .w_plv0     (w_plv0),
        .w_d0       (w_d0),
        .w_v0       (w_v0),
        .w_pfn1     (w_pfn1),
        .w_mat1     (w_mat1),
        .w_plv1     (w_plv1),
        .w_d1       (w_d1),
        .w_v1       (w_v1)
    );

    /* hit judge */
    genvar i;
    for(i = 0; i < TLBNUM; i = i + 1) begin
        assign found0[i] = all_e[i] && 
                           (all_g[i] || (all_asid[8*i+7:8*i] == s0_asid)) && 
                           (all_vpn2[19*i+18:19*i] == s0_vpn[19:1]);
        
        assign found1[i] = all_e[i] && 
                           (all_g[i] || (all_asid[8*i+7:8*i] == s1_asid)) && 
                           (all_vpn2[19*i+18:19*i] == s1_vpn[19:1]);


    end
    /* TLB hit */
    assign s0_found = |found0;
    assign s1_found = |found1;
    assign s0_pfn   = found_pfn0;
    assign s1_pfn   = found_pfn1;
    assign s0_mat   = found_mat0;
    assign s1_mat   = found_mat1;


    TLB_found_signal found_signal(
    .all_pfn0       (all_pfn0),
    .all_mat0       (all_mat0),
    .all_plv0       (all_plv0),
    .all_d0         (all_d0),
    .all_v0         (all_v0),
    .found0         (found0),
    .odd0_bit       (s0_vpn[0]),
    .all_pfn1       (all_pfn1),
    .all_mat1       (all_mat1),
    .all_plv1       (all_plv1),
    .all_d1         (all_d1),
    .all_v1         (all_v1),
    .found1         (found1),
    .odd1_bit       (s1_vpn[1]),
    .found_v0       (found_v0), 
    .found_v1       (found_v1),
    .found_d0       (found_d0), 
    .found_d1       (found_d1),
    .found_mat0     (found_mat0), 
    .found_mat1     (found_mat1),
    .found_plv0     (found_plv0), 
    .found_plv1     (found_plv1),
    .found_pfn0     (found_pfn0), 
    .found_pfn1     (found_pfn1)
    );

    /* exeption coping */
    TLB_exp_handler exp_handler(
        .clk            (clk),
        .s0_found       (s0_found),
        .s0_mem_type    (s0_mem_type),
        .found_v0       (found_v0),
        .found_d0       (found_d0),
        .s0_plv         (s0_plv),
        .found_plv0     (found_plv0),
        .s0_exception   (s0_exception),
        .s1_found       (s1_found),
        .s1_mem_type    (s1_mem_type),
        .found_v1       (found_v1),
        .found_d1       (found_d1),
        .s1_plv         (s1_plv),
        .found_plv1     (found_plv1),
        .s1_exception   (s1_exception)
    );


endmodule 
 