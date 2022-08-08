`include "clap_config.vh"
`include "uop.vh"

module decode_unit_input_reg
(
    input clk,rstn,flush,

    input input_valid_in,
    input [31:0] inst0_in, inst1_in,
    input known0_in,known1_in,
    input [31:0] pred_record0_in,pred_record1_in,
    input first_inst_jmp_in,
    input [6:0] exception_in,
    input [31:0] badv_in,
    input [31:0] pc_in,
    input [31:0] pc_next_in,

    output reg input_valid_out,
    output reg [31:0] inst0_out, inst1_out,
    output reg known0_out,known1_out,
    output reg [31:0] pred_record0_out,pred_record1_out,
    output reg first_inst_jmp_out,
    output reg [6:0] exception_out,
    output reg [31:0] badv_out,
    output reg [31:0] pc_out,
    output reg [31:0] pc_next_out
);
    always @(posedge clk)
        if(~rstn || flush)begin
            input_valid_out <= 0;
            exception_out <= 0;
        end
        else begin
            input_valid_out <= input_valid_in;
            inst0_out       <= inst0_in;
            inst1_out       <= inst1_in;
            known0_out      <= known0_in;
            known1_out      <= known1_in;
            pred_record0_out<= pred_record0_in;
            pred_record1_out<= pred_record1_in;
            first_inst_jmp_out<=first_inst_jmp_in;
            pc_out          <= pc_in;
            pc_next_out     <= pc_next_in;
            exception_out   <= exception_in;
            badv_out        <= badv_in;
        end
endmodule
