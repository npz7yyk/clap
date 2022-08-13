//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/13
// Design Name: 
// Module Name: stack
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
`include "clap_config.vh"

module stack #(
    parameter QUEUE_ADDR = 4,
    parameter ADDR_WIDTH = 32
)(
    input wire                    clk,
    input wire                    rstn,

    input wire                    push,
    input wire [ADDR_WIDTH - 1:0] addr,
    input wire                    pop,

    input wire                    inGuessIn,
    input wire                    clear,

    output wire                    empty,
    output wire [ADDR_WIDTH - 1:0] pred
);
    reg [ADDR_WIDTH - 1:0] mem [(1 << QUEUE_ADDR) - 1:0];
    reg [QUEUE_ADDR:0] count; 
    reg [QUEUE_ADDR - 1:0] ptr, savePtr;
    reg inGuess;

    assign empty = count == 0;
    assign pred = mem[ptr];

    always @(posedge clk) begin
        if (!rstn) begin
            count <= 0;
            ptr <= 0;
            savePtr <= 0;
            inGuess <= 0;
        end
        else if (clear) begin
            ptr <= savePtr;
            inGuess <= 0;
        end
        else begin
            if (inGuessIn & !inGuess) begin
                savePtr <= ptr;
                inGuess <= 1;
            end
            if (push) begin
                if (pop) begin
                    mem[ptr] <= addr;
                end else begin
                    if (!count[QUEUE_ADDR]) count <= count + 1;
                    ptr <= ptr + 1;
                    mem[ptr + 1] <= addr;
                end
            end else begin
                if (pop) begin
                    if (count != 0) count <= count - 1;
                    ptr <= ptr - 1;
                end
            end
        end
    end

endmodule