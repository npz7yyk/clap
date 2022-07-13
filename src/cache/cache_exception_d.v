`timescale 1ns / 1ps
`include "../exception.vh"
module cache_exception_d(
    input [31:0] addr_rbuf,
    input [3:0] type,
    output reg [6:0] exception
    );
    parameter BYTE = 4'b0001;
    parameter HALF = 4'b0011;
    parameter WORD = 4'b1111;
    always @(*) begin
        exception = 0;
        case(type)
        WORD: begin
            if(addr_rbuf[1:0]) exception = `EXP_ADEF;
        end
        HALF: begin
            if(addr_rbuf[0]) exception = `EXP_ADEF;
        end
        endcase
    end
endmodule