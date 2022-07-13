`timescale 1ns / 1ps
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


module branch_unit #(
    parameter ADDR_WIDTH = 32,
              HASH_DEPTH = 5,
              HASH_WIDTH = 24
)(
    input wire                    clk,
    input wire                    rstn,

    input wire                    ifVld,            // whether this unit works
    input wire [ADDR_WIDTH - 1:0] ifPC,             // instruction to predict

    input wire                    idVld,            // whether signal from id is valid
    input wire [ADDR_WIDTH - 1:0] idPC,             // pc of instruction pair being decoded
    input wire [ADDR_WIDTH - 1:0] idPCTar1,         // branch target of instruction1
    input wire [ADDR_WIDTH - 1:0] idPCTar2,         // branch target of instruction2
    input wire              [1:0] idType1,          // type of instruction1
    input wire              [1:0] idType2,          // type of instruction2

    input wire                    exVld,            // whether signal from ex is valid
    input wire [ADDR_WIDTH - 1:0] exPC,             // pc of instruction under execution
    input wire [ADDR_WIDTH - 1:0] exPCTar,          // branch target of this instruction
    input wire              [1:0] exType,           // instruction type
    input wire                    exBranch,         // whether this instruction branches
    input wire                    exWrong,          // ex pc wrongly predicted

    output wire [ADDR_WIDTH - 1:0] pdPC,            // pc predicted
    output wire                    pdBranch,        // whether a branch is predicted
    output wire                    pdReason,        // if branch, which inst causes this
    output wire                    pdKnown
);
    // start of instruction fact part
    wire [3:0] erFactSel, exFactSel;
    wire [1:0] ifFactSel;
    wire [ADDR_WIDTH - 1:0] ifFactData1, ifFactData2;
    data #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .HASH_DEPTH (HASH_DEPTH),
        .HASH_WIDTH (HASH_WIDTH)
    ) fact (
        .clk            (clk),
        .rstn           (rstn),

        .idEn           (idVld),
        .idPC           (idPC),
        .idTypeLower    (idType1),
        .idTypeUpper    (idType2),
        .idPCTarLower   (idPCTar1),
        .idPCTarUpper   (idPCTar2),

        .idExist        (idFactExist),
        .idInsert       (idFactInsert),
        .idIsPair       (idFactIsPair),

        //exVld does not exist for instance fact of module data
        //.exVld          (exVld),
        .exPC           (exPC),
        .exExist        (exFactExist),

        .ifPC           (ifPC),
        .ifExistLower   (ifFactExist1),
        .ifExistUpper   (ifFactExist2),
        .ifDataLower    (ifFactData1),
        .ifDataUpper    (ifFactData2)
    );
    // end of instruction fact part

    // start of past log part
    localparam PAST_DEPTH = HASH_DEPTH + 1;
    localparam PAST_WIDTH = 10;

    wire exBack = exPCTar[ADDR_WIDTH - 1:2] < exPC[ADDR_WIDTH - 1:2];

    /**
     * fact log data structure (from high to low):
     * name     bits    function
     * fact     2       the jump-or-not note
     * log      8       the experience for 11-10-01-00
     *                  each case has 2 bits
     */
    wire [PAST_WIDTH - 1:0] ifPastPara1, ifPastPara2;
    para #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .HASH_DEPTH (PAST_DEPTH),
        .PARA_WIDTH (PAST_WIDTH)
    ) past (
        .clk            (clk),
        .rstn           (rstn),

        //erSel does not exit for instance past of module para
        //.erSel          (erFactSel),
        .erPC           (idPC),
        .erLower        (erFactLower),
        .erUpper        (erFactUpper),

        //bdSel doest not exit for instance past of module data
        //.bdSel          (exFactSel),
        .bdPC           (exPC),
        .bdBack         (exBack),
        .bdType         (exType),
        .bdBranch       (exBranch),

        .ifPC           (ifPC),
        .ifVldLower     (ifPastVld1),
        .ifVldUpper     (ifPastVld2),
        .ifParaLower    (ifPastPara1),
        .ifParaUpper    (ifPastPara2)
    );
    // end of instruction log part

    // start of prediction part
    predict_unit #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .HASH_DEPTH (HASH_DEPTH),
        .HASH_WIDTH (HASH_WIDTH),
        .PARA_WIDTH (PAST_WIDTH)
    ) predict (
        .clk        (clk),
        .rstn       (rstn),
        .en         (ifVld),

        .pc_now     (ifPC),

        .exist1     (ifFactExist1),
        .exist2     (ifFactExist2),
        .info1      (ifFactData1),
        .info2      (ifFactData2),

        .past_vld1  (ifPastVld1),
        .past_vld2  (ifPastVld2),
        .past1      (ifPastPara1),
        .past2      (ifPastPara2),

        .ex_vld     (exVld),
        .ex_pc      (exPC),
        .ex_wrong   (exWrong),

        .pc_new     (pdPC),
        .branch     (pdBranch),
        .reason     (pdReason),
        .known      (pdKnown)
    );
    // end of prediction part

endmodule
