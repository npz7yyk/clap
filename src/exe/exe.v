`include "../uop.vh"
module exe(
    input[0:0]clk,   
    input[0:0]rstn,

    input[0:0]eu0_en_in,
    input[`WIDTH_UOP-1:0]eu0_uop_in,
    input [4:0]eu0_rd_in,
    input [4:0]eu0_rj_in,
    input [4:0]eu0_rk_in,
    input[31:0]eu0_pc_in,
    input[31:0]eu0_pc_next_in,
    input [5:0]eu0_exp_in,
    input [31:0]data00,
    input[31:0]data10,

    input[0:0]eu1_en_in,
    input[`WIDTH_UOP-1:0]eu1_uop_in,
    input [4:0]eu1_rd_in,
    input [4:0]eu1_rj_in,
    input [4:0]eu1_rk_in,
    input [31:0]data10,
    input [31:0]data11,
    input [5:0]eu1_exp_in,

    output reg [31:0]data_out0,
    output reg [4:0]addr_out0,
    output reg [31:0]data_out1,
    output reg [4:0]addr_out1,
    
    output[0:0]eu0_ready,
    output[0:0]eu0_finish
);



endmodule 