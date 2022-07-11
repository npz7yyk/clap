`timescale 1ns / 1ps
module mux2_1#(
    parameter WIDTH = 32
    )(
    input [WIDTH-1:0] din1,
    input [WIDTH-1:0] din2,
    input [1:0]sel,
    output reg [WIDTH-1:0] dout
    );
    always @(*) begin
        case(sel)
        2'b10: dout = din1;
        2'b01: dout = din2;
        default: dout = 0;
        endcase
    end
endmodule
module mux3_1#(
    parameter WIDTH = 32
    )(
    input [WIDTH-1:0] din1,
    input [WIDTH-1:0] din2,
    input [WIDTH-1:0] din3,
    input [3:0] sel,
    output reg [WIDTH-1:0] dout
    );
    always @(*) begin
        case(sel)
        3'b100: dout = din1;
        3'b010: dout = din2;
        3'b001: dout = din3;
        default: dout = 0;
        endcase
    end
endmodule
