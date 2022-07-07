`timescale 1ns / 1ps
module request_buffer(
    input clk, rstn,
    input valid,
    input [3:0] write_type,
    input [31:0] w_data_CPU,
    input [31:0] addr,
    input op,
    input [3:0] hit,
    output [31:0] w_data_CPU_reqbuf,
    output [31:0] addr_reqbuf,
    output op_reqbuf,
    output reg [63:0] mem_we_reqbuf,
    output [3:0] mem_en_reqbuf,
    output [511:0] mem_din_reqbuf
    );
    register#(65) request_buffer(
        .clk    (clk), 
        .rstn   (rstn),
        .we     (valid),
        .din    ({w_data_CPU, addr, op}),
        .dout   ({w_data_CPU_reqbuf, addr_reqbuf, op_reqbuf})
    );
     /* generate selection */
    always @(*) begin
        case(addr_reqbuf[5:2])
        4'h0: mem_we_reqbuf = write_type;
        4'h1: mem_we_reqbuf = {write_type, 4'b0};
        4'h2: mem_we_reqbuf = {write_type, 8'b0};
        4'h3: mem_we_reqbuf = {write_type, 12'b0};
        4'h4: mem_we_reqbuf = {write_type, 16'b0};
        4'h5: mem_we_reqbuf = {write_type, 20'b0};
        4'h6: mem_we_reqbuf = {write_type, 24'b0};
        4'h7: mem_we_reqbuf = {write_type, 28'b0};
        4'h8: mem_we_reqbuf = {write_type, 32'b0};
        4'h9: mem_we_reqbuf = {write_type, 36'b0};
        4'ha: mem_we_reqbuf = {write_type, 40'b0};
        4'hb: mem_we_reqbuf = {write_type, 44'b0};
        4'hc: mem_we_reqbuf = {write_type, 48'b0};
        4'hd: mem_we_reqbuf = {write_type, 52'b0};
        4'he: mem_we_reqbuf = {write_type, 56'b0};
        4'hf: mem_we_reqbuf = {write_type, 60'b0};
        endcase
    end
    assign mem_en_reqbuf = hit;
    /* generate din */
    assign mem_din_reqbuf = {16{w_data_CPU}};
endmodule
