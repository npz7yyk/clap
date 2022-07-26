module TLB_dmw(
    input                       dmw0_plv0,
    input                       dmw0_plv3,
    input  [               1:0] dmw0_mat,
    input  [               2:0] dmw0_vseg,
    input  [               2:0] dmw0_pseg,
    input                       dmw1_plv0,
    input                       dmw1_plv3,
    input  [               1:0] dmw1_mat,
    input  [               2:0] dmw1_vseg,
    input  [               2:0] dmw1_pseg,

    input  [              31:0] s0_vaddr,
    input  [               1:0] s0_plv,
    output [               1:0] s0_dmw_mat,
    output [              31:0] s0_dmw_paddr,
    output                      s0_dmw_hit,

    input  [              31:0] s1_vaddr,
    input  [               1:0] s1_plv,
    output [               1:0] s1_dmw_mat,
    output [              31:0] s1_dmw_paddr,
    output                      s1_dmw_hit

    );

    wire s0_dmw_hit0, s0_dmw_hit1;
    wire s1_dmw_hit0, s1_dmw_hit1;

    assign s0_dmw_hit0 = ((dmw0_plv0 && (s0_plv == 0)) || (dmw0_plv3 && (s0_plv == 2'd3))) && (dmw0_vseg == s0_vaddr[31:29]);
    assign s0_dmw_hit1 = ((dmw1_plv0 && (s0_plv == 0)) || (dmw1_plv3 && (s0_plv == 2'd3))) && (dmw1_vseg == s0_vaddr[31:29]);
    assign s1_dmw_hit0 = ((dmw0_plv0 && (s1_plv == 0)) || (dmw0_plv3 && (s1_plv == 2'd3))) && (dmw0_vseg == s1_vaddr[31:29]);
    assign s1_dmw_hit1 = ((dmw1_plv0 && (s1_plv == 0)) || (dmw1_plv3 && (s1_plv == 2'd3))) && (dmw1_vseg == s1_vaddr[31:29]);

    assign s0_dmw_hit = s0_dmw_hit0 | s0_dmw_hit1;
    assign s1_dmw_hit = s1_dmw_hit0 | s1_dmw_hit1;

    assign s0_dmw_mat = {2{s0_dmw_hit0}} & dmw0_mat | {2{s0_dmw_hit1}} & dmw1_mat;
    assign s1_dmw_mat = {2{s1_dmw_hit0}} & dmw0_mat | {2{s1_dmw_hit1}} & dmw1_mat;

    assign s0_dmw_paddr = {32{s0_dmw_hit0}} & {dmw0_pseg, s0_vaddr[28:0]} | {32{s0_dmw_hit1}} & {dmw1_pseg, s0_vaddr[28:0]}; 
    assign s1_dmw_paddr = {32{s1_dmw_hit0}} & {dmw0_pseg, s1_vaddr[28:0]} | {32{s1_dmw_hit1}} & {dmw1_pseg, s1_vaddr[28:0]};


endmodule
