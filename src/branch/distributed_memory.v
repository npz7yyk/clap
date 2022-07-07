`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/07 22:11:37
// Design Name: 
// Module Name: distributed_memory
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module single_port_memory #(
    parameter ADDR_WIDTH = 5,
              DATA_WIDTH = 32
)(
    input wire                    clk,
    input wire                    wt_en,
    input wire [ADDR_WIDTH - 1:0] wtaddr,
    input wire [DATA_WIDTH - 1:0] wtdata,
    input wire [ADDR_WIDTH - 1:0] raddr1,

    output wire [DATA_WIDTH - 1:0] rdata1
);
    reg [DATA_WIDTH - 1:0] memory [(1 << ADDR_WIDTH) - 1:0];

    always @(posedge clk)
        if (wt_en) memory[wtaddr] <= wtdata;
    
    assign rdata1 = memory[raddr1];

endmodule


module double_port_memory #(
    parameter ADDR_WIDTH = 5,
              DATA_WIDTH = 32
)(
    input wire                    clk,
    input wire                    wt_en,
    input wire [ADDR_WIDTH - 1:0] wtaddr,
    input wire [DATA_WIDTH - 1:0] wtdata,
    input wire [ADDR_WIDTH - 1:0] raddr1,
    input wire [ADDR_WIDTH - 1:0] raddr2,

    output wire [DATA_WIDTH - 1:0] rdata1,
    output wire [DATA_WIDTH - 1:0] rdata2
);
    reg [DATA_WIDTH - 1:0] memory [(1 << ADDR_WIDTH) - 1:0];

    always @(posedge clk)
        if (wt_en) memory[wtaddr] <= wtdata;
    
    assign rdata1 = memory[raddr1];
    assign rdata2 = memory[raddr2];

endmodule


module triple_port_memory #(
    parameter ADDR_WIDTH = 5,
              DATA_WIDTH = 32
)(
    input wire                    clk,
    input wire                    wt_en,
    input wire [ADDR_WIDTH - 1:0] wtaddr,
    input wire [DATA_WIDTH - 1:0] wtdata,
    input wire [ADDR_WIDTH - 1:0] raddr1,
    input wire [ADDR_WIDTH - 1:0] raddr2,
    input wire [ADDR_WIDTH - 1:0] raddr3,

    output wire [DATA_WIDTH - 1:0] rdata1,
    output wire [DATA_WIDTH - 1:0] rdata2,
    output wire [DATA_WIDTH - 1:0] rdata3
);
    reg [DATA_WIDTH - 1:0] memory [(1 << ADDR_WIDTH) - 1:0];

    always @(posedge clk)
        if (wt_en) memory[wtaddr] <= wtdata;
    
    assign rdata1 = memory[raddr1];
    assign rdata2 = memory[raddr2];
    assign rdata3 = memory[raddr3];

endmodule
