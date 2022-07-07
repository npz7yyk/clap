`timescale 1ns / 1ps

module register#(
    parameter WIDTH = 32
    )(
    input clk, rstn, we,
    input [WIDTH-1:0] din,
    output reg [WIDTH-1:0] dout
    );
    always @(posedge clk) begin
        if(!rstn) dout <= 0;
        else if(we) dout <= din;
    end
endmodule
