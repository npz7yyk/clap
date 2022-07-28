//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/10 23:16:13
// Design Name: 
// Module Name: branch_unit
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

/* verilator lint_off DECLFILENAME */
module way_select #(
    parameter HASH_DEPTH = 5 
)(
    input                         clk,
    input                         en,
    input wire [HASH_DEPTH - 1:0] waddr,
    // verilator lint_off UNSIGNED (visit[0] is used because it's guaranteed to be one-hot, FIXME: really???)
    input wire              [3:0] visit,
    // verilator lint_on UNSIGNED
    input wire [HASH_DEPTH - 1:0] raddr,

    output wire             [3:0] select
);
    reg [7:0] queue [(1 << HASH_DEPTH) - 1:0];

    integer i;
    initial 
        for (i = 0; i < (1 << HASH_DEPTH); i = i + 1)
            queue[i] = 8'b00_01_10_11;

    wire [1:0] way = {visit[3] | visit[2], visit[3] | visit[1]};
    wire [7:0] queueOld = queue[waddr];
    reg [7:0] queueNew;
    always @(*) begin
        if (queue[waddr][7:6] == way)
            queueNew = {queueOld[5:0], queueOld[7:6]};
        else if (queue[waddr][5:4] == way)
            queueNew = {queueOld[7:6], queueOld[3:0], queueOld[5:4]};
        else if (queue[waddr][3:2] == way)
            queueNew = {queueOld[7:4], queueOld[1:0], queueOld[3:2]};
        else
            queueNew = queueOld;
    end

    always @(posedge clk)
        if (en)
            queue[waddr] <= queueNew;

    wire [1:0] tar = queue[raddr][7:6];
    assign select = {
         tar[1] & tar[0],  tar[1] & !tar[0],
        !tar[1] & tar[0], !tar[1] & !tar[0]
    };

endmodule
