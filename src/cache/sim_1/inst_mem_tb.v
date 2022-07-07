`timescale 1ns / 1ps


module inst_mem_tb(
    output [63:0] r_data_CPU
    );
    reg clk;
    initial begin
        clk = 0;
        forever begin
            #1 clk = ~clk;
        end
    end
    wire valid, data_valid;
    assign valid = 1'b1;
    reg [9:0] addr;
    initial begin
        addr = 6'b0;
    end
    always @(posedge clk) begin
        if(data_valid) addr <= addr + 7'd32;
    end
    inst_mem inst_test(
        .clk        (clk),
        .rstn       (1'b1),
        .valid      (valid),
        .addr       ({22'b0, addr}),
        .data_valid (data_valid),
        .r_data_CPU (r_data_CPU)
    );
endmodule
