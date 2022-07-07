`timescale 1ns / 1ps

module write_hazard(
    input clk,
    input op, op_store,
    input [31:0] addr, addr_store,
    output reg forwarding
    );
    parameter LOAD = 0;
    parameter WRITE = 1;
    always @(posedge clk) begin
        if(op == LOAD && op_store == WRITE && addr == addr_store)begin
            forwarding = 1;
        end
        else forwarding = 0;
    end
endmodule
