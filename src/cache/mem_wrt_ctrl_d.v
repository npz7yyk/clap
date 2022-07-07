`timescale 1ns / 1ps
module mem_wrt_ctrl_d(
    input [31:0] w_data_CPU,
    input [511:0] w_data_AXI,
    input [31:0] addr_rbuf,
    input [3:0] wrt_type,
    input wrt_data_sel,
    output reg [511:0] mem_din,
    output reg [63:0] mem_we_normal
    );
    always @(*) begin
        case(wrt_data_sel)
        1'b0: mem_din = w_data_AXI;
        1'b1: mem_din = {16{w_data_CPU}};
        endcase
    end
    always @(*) begin
        case(addr_rbuf[5:2])
        4'h0: mem_we_normal = wrt_type;
        4'h1: mem_we_normal = {wrt_type, 4'b0};
        4'h2: mem_we_normal = {wrt_type, 8'b0};
        4'h3: mem_we_normal = {wrt_type, 12'b0};
        4'h4: mem_we_normal = {wrt_type, 16'b0};
        4'h5: mem_we_normal = {wrt_type, 20'b0};
        4'h6: mem_we_normal = {wrt_type, 24'b0};
        4'h7: mem_we_normal = {wrt_type, 28'b0};
        4'h8: mem_we_normal = {wrt_type, 32'b0};
        4'h9: mem_we_normal = {wrt_type, 36'b0};
        4'ha: mem_we_normal = {wrt_type, 40'b0};
        4'hb: mem_we_normal = {wrt_type, 44'b0};
        4'hc: mem_we_normal = {wrt_type, 48'b0};
        4'hd: mem_we_normal = {wrt_type, 52'b0};
        4'he: mem_we_normal = {wrt_type, 56'b0};
        4'hf: mem_we_normal = {wrt_type, 60'b0};
        endcase
    end
endmodule
