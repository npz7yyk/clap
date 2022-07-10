`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/24 22:23:27
// Design Name: 
// Module Name: predict_unit
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


module predict_unit #(
    parameter ADDR_WIDTH = 32,
              HASH_DEPTH = 5,
              HASH_WIDTH = 24,
              PARA_WIDTH = 10
)(
    input wire                    clk,
    input wire                    rstn,
    input wire                    en,               // whether unit works

    input wire [ADDR_WIDTH - 1:0] pc_now,

    input wire                    exist1,
    input wire                    exist2,
    input wire [ADDR_WIDTH - 1:0] info1,
    input wire [ADDR_WIDTH - 1:0] info2,

    input wire                    past_vld1,
    input wire                    past_vld2,
    input wire [PARA_WIDTH - 1:0] past1,
    input wire [PARA_WIDTH - 1:0] past2,

    input wire                    ex_vld,           // if ex_vld = 1,
    input wire [ADDR_WIDTH - 1:0] ex_pc,            // ex_pc no more in guess
    input wire                    ex_wrong,

    output wire [ADDR_WIDTH - 1:0] pc_new,
    output wire                    branch,
    output wire                    reason
);
    // start of guess log part

    parameter GUESS_DEPTH = HASH_DEPTH;
    parameter GUESS_WIDTH = 4;

    wire [GUESS_DEPTH - 1:0] guess_waddr = pc_now[GUESS_DEPTH + 2:3];
    wire [GUESS_DEPTH - 1:0] guess_raddr = pc_now[GUESS_DEPTH + 2:3];
    wire [GUESS_WIDTH - 1:0] guess_wdata;
    wire [GUESS_WIDTH - 1:0] guess_rdata;

    /* 
     * structure of data (from high to low):
     * name     bits    function
     * guess1   2       log of guess about instruction1
     * guess2   2       log of guess about instruction2
     */
    single_port_memory #(
        .DATA_DEPTH (GUESS_DEPTH),
        .DATA_WIDTH (GUESS_WIDTH)
    ) guess_log (
        .clk        (clk),
        .wt_en      (en),
        .waddr      (guess_waddr),
        .wdata      (guess_wdata),
        .raddr      (guess_raddr),
        .rdata      (guess_rdata)
    );

    /*
     * InGuess tells us whether we should predict depend on 
     * guess or fact. InGuess is 1 only if the instruction
     * has info 2'b01 and log but just has no more result from ex.
     */
    reg [(1 << GUESS_DEPTH) - 1:0] inGuess1;
    reg [(1 << GUESS_DEPTH) - 1:0] inGuess2;

    initial begin
        inGuess1 <= 32'b0;
        inGuess2 <= 32'b0;
    end

    // new values for inGuess
    wire inGuess1_new, inGuess2_new;
    wire ex_addr = ex_pc[GUESS_DEPTH + 2:3];

    // this "always" deals with inGuess
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            inGuess1 <= 32'b0;
            inGuess2 <= 32'b0;
        end
        else if (en) begin
            if (ex_wrong) begin
                inGuess1 <= 32'b0;
                inGuess2 <= 32'b0;
            end
            else if (ex_vld) begin
                // so somewhere will be set 0
                if (ex_addr == guess_waddr) begin
                    if (ex_pc[2]) begin
                        inGuess1[guess_waddr] <= inGuess1_new;
                        inGuess2[guess_waddr] <= 1'b0;
                    end else begin
                        inGuess1[guess_waddr] <= 1'b0;
                        inGuess2[guess_waddr] <= inGuess2_new;
                    end
                end else begin
                    inGuess1[guess_waddr] <= inGuess1_new;
                    inGuess2[guess_waddr] <= inGuess2_new;
                    if (ex_pc[2]) inGuess2[ex_addr] <= 1'b0;
                    else inGuess1[ex_addr] <= 1'b0;
                end
            end else begin
                inGuess1[guess_waddr] <= inGuess1_new;
                inGuess2[guess_waddr] <= inGuess2_new;
            end
        end
    end

    // end of guess log part

    wire [HASH_WIDTH - 1:0] key = pc_now[
        HASH_WIDTH + HASH_DEPTH + 2:HASH_DEPTH + 3];

    // Whether a branch is needed decided by guess state or log
    reg branch_past1, branch_past2;
    always @(*) begin
        if (inGuess1[guess_raddr]) begin
            case (guess_rdata[3:2])
            2'b00: branch_past1 = past1[1];
            2'b01: branch_past1 = past1[3];
            2'b10: branch_past1 = past1[5];
            2'b11: branch_past1 = past1[7];
            endcase
        end else begin
            case (past1[9:8])
            2'b00: branch_past1 = past1[1];
            2'b01: branch_past1 = past1[3];
            2'b10: branch_past1 = past1[5];
            2'b11: branch_past1 = past1[7];
            endcase
        end

        if (inGuess2[guess_raddr]) begin
            case (guess_rdata[1:0])
            2'b00: branch_past2 = past2[1];
            2'b01: branch_past2 = past2[3];
            2'b10: branch_past2 = past2[5];
            2'b11: branch_past2 = past2[7];
            endcase
        end else begin
            case (past2[9:8])
            2'b00: branch_past2 = past2[1];
            2'b01: branch_past2 = past2[3];
            2'b10: branch_past2 = past2[5];
            2'b11: branch_past2 = past2[7];
            endcase
        end
    end

    // whether we only care about instruction2
    wire pcAtHalf = pc_now[2];
    // whether inst branches to lower pc
    wire back1 = info1[ADDR_WIDTH - 1:2] < pc_now[ADDR_WIDTH - 1:2];
    wire back2 = info2[ADDR_WIDTH - 1:2] < pc_now[ADDR_WIDTH - 1:2];

    // this "always" deals with branch1 and branch2
    reg branch1, branch2;
    always @(*) begin
        if (exist1) begin
            if (past_vld1) branch1 = branch_past1;
            else branch1 = back1;
        end else branch1 = 1'b0;

        if (exist2) begin
            if (past_vld2) branch2 = branch_past2;
            else branch2 = back2;
        end else branch2 = 1'b0;
    end

    assign inGuess1_new = pcAtHalf ? 1'b0 : exist1 & past_vld1;
    assign inGuess2_new = branch1 ? 1'b0 : exist2 & past_vld2;
    assign branch = branch1 | branch2;
    assign reason = pcAtHalf ? 1'b1 : ~branch1 & branch2;

    wire [1:0] guess1 = {
        inGuess1[guess_raddr] ? 
        guess_rdata[2] : past1[8],
        branch && !reason
    };
    wire [1:0] guess2 = {
        inGuess2[guess_raddr] ? 
        guess_rdata[0] : past2[8],
        branch && reason
    };

    assign guess_wdata = {guess1, guess2};
    
    wire [ADDR_WIDTH - 3:0] pc_choose = reason ?
        info2[ADDR_WIDTH - 1:2] : info1[ADDR_WIDTH - 1:2];

    assign pc_new = branch ?
        {pc_choose, 2'b00} :
        {pc_now[ADDR_WIDTH - 1:3] + 1, 3'b000};

endmodule