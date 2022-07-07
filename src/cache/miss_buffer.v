`timescale 1ns / 1ps

module miss_buffer(
    input clk, 
    input way_rstn,
    input way_we,
    input [3:0] way_din,
    output [3:0] mem_en_mbuf,
    input data_num_we,
    input data_num_rstn,
    output reg [63:0] mem_we_mbuf
    );
    register#(4) miss_buffer_wayinfo(
        .clk    (clk),
        .rstn   (rstn),
        .we     (way_we),
        .din    (way_din),
        .dout   (mem_en_mbuf)
    );
    always @(posedge clk) begin
        if(!data_num_rstn) mem_we_mbuf <= 64'hf;
        else if(data_num_we) mem_we_mbuf <= mem_we_mbuf << 4;
    end

endmodule
