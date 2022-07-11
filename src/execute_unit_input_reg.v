`include "uop.vh"

module execute_unit_input_reg
(
    input clk,rstn,flush,stall,

    input en_in,
    input [`WIDTH_UOP-1:0] uop_in,
    input [4:0] rd_in,rj_in,rk_in,
    input [31:0] imm_in,
    input [31:0] pc_in,pc_next_in,
    input [6:0] exception_in,

    output reg en_out,
    output reg [`WIDTH_UOP-1:0] uop_out,
    output reg [4:0] rd_out,rj_out,rk_out,
    output reg [31:0] imm_out,
    output reg [31:0] pc_out,pc_next_out,
    output reg [6:0] exception_out
);
    always @(posedge clk)
        if(~rstn || flush)begin
            en_out          <= 0;
            uop_out         <= 0;
            rd_out          <= 0;
            rj_out          <= 0;
            rk_out          <= 0;
            imm_out         <= 0;
            pc_out          <= 0;
            pc_next_out     <= 4;
            exception_out   <= 0;
        end
        else if(~stall) begin
            en_out          <= en_in;
            uop_out         <= uop_in;
            rd_out          <= rd_in;
            rj_out          <= rj_in;
            rk_out          <= rk_in;
            imm_out         <= imm_in;
            pc_out          <= pc_in;
            pc_next_out     <= pc_next_in;
            exception_out   <= exception_in;
        end
endmodule
