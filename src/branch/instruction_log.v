`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/07 22:27:13
// Design Name: 
// Module Name: instruction_log
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


module data #(
    parameter ADDR_WIDTH = 32,                      // processor address width
              HASH_DEPTH = 5,                       // hash address width
              HASH_WIDTH = 24                       // hash tag width
)(
    input wire                    clk,
    input wire                    rstn,

    // wire for build
    input wire                    idEn,             // whether the pair needs to be built
    input wire [ADDR_WIDTH - 1:0] idPC,             // instruction pair to build
    input wire                    idUsefulLower,    // whether instructions are useful
    input wire                    idUsefulUpper,    // whether instructions are useful
    input wire              [1:0] idTypeLower,      // type of instruction1
    input wire              [1:0] idTypeUpper,      // type of instruciton2
    input wire [ADDR_WIDTH - 1:0] idPCTarLower,     // branch target of instruction1
    input wire [ADDR_WIDTH - 1:0] idPCTarUpper,     // branch target of instrustion2

    output wire                   idExist,          // whether the pair already exists
    output wire                   idInsert,         // whether the pair can insert here
    output wire                   idIsPair,         // whether it is a pair here

    // wire for check tag
    input wire [ADDR_WIDTH - 1:0] exPC,             // used for update
    output wire                   exExist,          // whether this pair exist

    // wire for predict
    input wire [ADDR_WIDTH - 1:0] ifPC,             // instruction pair used to predict
    /* 
     * structure for data
     * addr     30      the target address of this instruction
     * type     2       the type of this instruction
     */
    output wire                    ifExist,         // whether pair exists
    output wire [ADDR_WIDTH - 1:0] ifDataLower,     // result data
    output wire [ADDR_WIDTH - 1:0] ifDataUpper      // result data
);
    wire [HASH_DEPTH - 1:0] idWaddr = idPC[HASH_DEPTH + 2:3];
    wire [HASH_DEPTH - 1:0] exRaddr = exPC[HASH_DEPTH + 2:3];
    wire [HASH_DEPTH - 1:0] ifRaddr = ifPC[HASH_DEPTH + 2:3];

    wire [HASH_WIDTH - 1:0] idPCTag =
        idPC[HASH_WIDTH + HASH_DEPTH + 2:HASH_DEPTH + 3];
    wire [HASH_WIDTH - 1:0] exPCTag =
        exPC[HASH_WIDTH + HASH_DEPTH + 2:HASH_DEPTH + 3];
    wire [HASH_WIDTH - 1:0] ifPCTag =
        exPC[HASH_WIDTH + HASH_DEPTH + 2:HASH_DEPTH + 3];

    wire [HASH_WIDTH - 1:0] idTagLower, idTagUpper,
        exTagLower, exTagUpper, ifTagLower, ifTagUpper;

    wire idHitLower = idPCTag == idTagLower;
    wire idHitUpper = idPCTag == idTagUpper;
    wire exHitLower = exPCTag == exTagLower;
    wire exHitUpper = exPCTag == exTagUpper;
    wire ifHitLower = ifPCTag == ifTagLower;
    wire ifHitUpper = ifPCTag == ifTagUpper;

    reg [(1 << HASH_DEPTH) - 1:0] vldLower, vldUpper;
    initial begin
        vldLower <= 32'b0;
        vldUpper <= 32'b0;
    end

    assign idIsPair = vldLower[idWaddr] & vldUpper[idWaddr] & ifTagLower == ifTagUpper;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            vldLower <= 32'b0;
            vldUpper <= 32'b0;
        end
        else if (idEn) begin
            if (idIsPair) begin
                // it's a pair, so vld totally depends on new pair
                vldLower[idWaddr] <= idUsefulLower;
                vldUpper[idWaddr] <= idUsefulUpper;
            end begin
                // it's not a pair, we can conclude as follows:
                vldLower[idWaddr] <= vldLower[idWaddr] | idUsefulLower;
                vldUpper[idWaddr] <= vldUpper[idWaddr] | idUsefulUpper;
            end
        end
    end

    wire idVldUsefulLower = vldLower[idWaddr] & idUsefulLower;
    wire idVldUsefulUpper = vldUpper[idWaddr] & idUsefulUpper;
    wire idEnLower = idEn & idUsefulLower;
    wire idEnUpper = idEn & idUsefulUpper;

    assign idExist = idVldUsefulLower & idHitLower 
                   | idVldUsefulUpper & idHitUpper;
    assign idInsert = ~(idVldUsefulLower | idVldUsefulUpper);

    triple_port_memory #(
        .ADDR_WIDTH (HASH_DEPTH),
        .DATA_WIDTH (HASH_WIDTH)
    ) hash_lower (
        .clk        (clk),
        .wt_en      (idEnLower),
        .wtaddr     (idWaddr),
        .wtdata     (idPCTag),
        .raddr1     (idWaddr),
        .rdata1     (idTagLower),
        .raddr2     (exRaddr),
        .rdata2     (exTagLower),
        .raddr3     (ifRaddr),
        .rdata3     (ifTagLower)
    );

    triple_port_memory #(
        .ADDR_WIDTH (HASH_DEPTH),
        .DATA_WIDTH (HASH_WIDTH)
    ) hash_upper (
        .clk        (clk),
        .wt_en      (idEnUpper),
        .wtaddr     (idWaddr),
        .wtdata     (idPCTag),
        .raddr1     (idWaddr),
        .rdata1     (idTagUpper),
        .raddr2     (exRaddr),
        .rdata2     (exTagUpper),
        .raddr3     (ifRaddr),
        .rdata3     (ifTagUpper)
    );

    wire exExistLower = vldLower[exRaddr] & exHitLower;
    wire exExistUpper = vldUpper[exRaddr] & exHitUpper;
    assign exExist = exPC[2] ? exExistUpper : exExistLower;

    wire [ADDR_WIDTH - 1:0] idWdataLower =
        {idPCTarLower[ADDR_WIDTH - 1:2], idTypeLower};
    wire [ADDR_WIDTH - 1:0] idWdataUpper =
        {idPCTarUpper[ADDR_WIDTH - 1:2], idTypeUpper};

    single_port_memory #(
        .ADDR_WIDTH (HASH_DEPTH),
        .DATA_WIDTH (ADDR_WIDTH)
    ) data_lower (
        .clk        (clk),
        .wt_en      (idEnLower),
        .wtaddr     (idWaddr),
        .wtdata     (idWdataLower),
        .raddr1     (ifRaddr),
        .rdata1     (ifDataLower)
    );

    single_port_memory #(
        .ADDR_WIDTH (HASH_DEPTH),
        .DATA_WIDTH (ADDR_WIDTH)
    ) data_upper (
        .clk        (clk),
        .wt_en      (idEnUpper),
        .wtaddr     (idWaddr),
        .wtdata     (idWdataUpper),
        .raddr1     (ifRaddr),
        .rdata1     (ifDataUpper)
    );

    wire ifExistLower = vldLower[ifRaddr] & ifHitLower;
    wire ifExistUpper = vldUpper[ifRaddr] & ifHitUpper;
    assign ifExist = ifExistLower | ifExistUpper;

endmodule


module fact #(
    parameter ADDR_WIDTH = 32,
              HASH_DEPTH = 5,
              HASH_WIDTH = 24
)(
    input wire                    clk,
    input wire                    rstn,

    // wire for build
    input wire                    idEn,             // whether the pair needs to be built
    input wire [ADDR_WIDTH - 1:0] idPC,             // instruction pair to build
    input wire              [1:0] idTypeLower,      // type of instruction1
    input wire              [1:0] idTypeUpper,      // type of instruciton2
    input wire [ADDR_WIDTH - 1:0] idPCTarLower,     // branch target of instruction1
    input wire [ADDR_WIDTH - 1:0] idPCTarUpper,     // branch target of instrustion2

    output wire             [1:0] erSel,            // which block to erase
    output wire                   erLower,          // whether past needs to be erased
    output wire                   erUpper,          // whether past needs to be erased

    // wire for check tag
    input wire [ADDR_WIDTH - 1:0] exPC,             // used for update
    output wire                   exExist,          // whether this pair exist
    output wire             [1:0] exSel,            // if exist, which block

    // wire for predict
    input wire [ADDR_WIDTH - 1:0] ifPC,             // instruction pair used to predict
    /* 
     * structure for data
     * addr     30      the target address of this instruction
     * type     2       the type of this instruction
     */
    output wire                    ifExist,         // whether pair exists
    output wire              [1:0] ifSel,           // if exist, which block
    output wire [ADDR_WIDTH - 1:0] ifDataLower,     // result data
    output wire [ADDR_WIDTH - 1:0] ifDataUpper      // result data
);
    /*
    wire [ADDR_DEPTH - 1:0] wtaddr = bPC[ADDR_DEPTH + 2:3];
    wire [ADDR_DEPTH - 1:0] r1addr = uPC[ADDR_DEPTH + 2:3];
    wire [ADDR_DEPTH - 1:0] r2addr = pPC[ADDR_DEPTH + 2:3];

    reg [(1 << ADDR_DEPTH) - 1:0] vld;
    initial vld <= 32'b0;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) vld <= 32'b0;
        else if (en) vld[wtaddr] <= 1'b1;
    end

    wire [ADDR_DEPTH - 1:0] hash_wtaddr = bPC[ADDR_DEPTH + 2:3];
    wire [ADDR_DEPTH - 1:0] hash_r1addr = uPC[ADDR_DEPTH + 2:3];
    wire [ADDR_DEPTH - 1:0] hash_r2addr = pPC[ADDR_DEPTH + 2:3];
    wire [HASH_WIDTH - 1:0] hash_wtdata = 
        bPC[HASH_WIDTH + ADDR_DEPTH + 2:ADDR_DEPTH + 3];
    wire [HASH_WIDTH - 1:0] hash_r1data;
    wire [HASH_WIDTH - 1:0] hash_r2data;
    double_port_memory #(
        .DATA_DEPTH     (ADDR_DEPTH),
        .DATA_WIDTH     (HASH_WIDTH)
    ) hash (
        .clk        (clk),
        .write_en   (en),
        .wtaddr     (hash_wtaddr),
        .wtdata     (hash_wtdata),
        .r1addr     (hash_r1addr),
        .r1data     (hash_r1data),
        .r2addr     (hash_r2addr),
        .r2data     (hash_r2data)
    );

    parameter DATA_WIDTH = ADDR_WIDTH * 2;
    wire [ADDR_DEPTH - 1:0] data_wtaddr = bPC[ADDR_DEPTH + 2:3];
    wire [ADDR_DEPTH - 1:0] data_r1addr = uPC[ADDR_DEPTH + 2:3];
    wire [ADDR_DEPTH - 1:0] data_r2addr = pPC[ADDR_DEPTH + 2:3];
    wire [DATA_WIDTH - 1:0] data_wtdata = {
        bPCTar1[ADDR_WIDTH - 1:2], bType1,
        bPCTar2[ADDR_WIDTH - 1:2], bType2
    };
    wire [DATA_WIDTH - 1:0] data_r1data;
    wire [DATA_WIDTH - 1:0] data_r2data;
    double_port_memory #(
        .DATA_DEPTH     (ADDR_DEPTH),
        .DATA_WIDTH     (DATA_WIDTH)
    ) data (
        .clk        (clk),
        .write_en   (en),
        .wtaddr     (data_wtaddr),
        .wtdata     (data_wtdata),
        .r1addr     (data_r1addr),
        .r1data     (data_r1data),
        .r2addr     (data_r2addr),
        .r2data     (data_r2data)
    );

    assign uVld = vld[hash_r1addr];
    assign pVld = vld[hash_r2addr];
    assign uHit = hash_r1data == uPC[HASH_WIDTH + 2:3];
    assign pHit = hash_r2data == pPC[HASH_WIDTH + 2:3];
    assign uData = data_r1data;
    assign pData = data_r2data;
    */
endmodule


module log_init (
    input wire       branch,
    input wire       back,
    input wire [1:0] type,

    output reg [9:0]  log
);
    always @(*) begin
        if (type[1]) log = 10'b11_11_11_11_11;
        else begin
            if (type[0]) begin
                log = {back, branch, back ? 
                    8'b10_10_10_01 : 8'b10_01_01_01};
            end else log = 10'b00_00_00_00_00;
        end
    end

endmodule


module log_update(
    input wire       branch,
    input wire [9:0] old,
    output reg [9:0] new
);
    reg [1:0] tar;
    reg [1:0] learn;

    always @(*) begin
        case (old[9:8])
        2'b00: begin
            tar = old[1:0];
            new = {old[8], branch, old[7:2], learn};
        end
        2'b01: begin
            tar = old[3:2];
            new = {old[8], branch, old[7:4], learn, old[1:0]};
        end
        2'b10: begin
            tar = old[5:4];
            new = {old[8], branch, old[7:6], learn, old[3:0]};
        end
        2'b11: begin
            tar = old[7:6];
            new = {old[8], branch, learn, old[5:0]};
        end
        endcase
    end

    always @(*) begin
        if (branch) begin
            case (tar)
            2'b00: learn = 2'b01;
            2'b01: learn = 2'b10;
            2'b10: learn = 2'b11;
            2'b11: learn = 2'b11;
            endcase
        end else begin
            case (tar)
            2'b00: learn = 2'b00;
            2'b01: learn = 2'b00;
            2'b10: learn = 2'b01;
            2'b11: learn = 2'b10;
            endcase
        end
    end

endmodule


module para #(
    parameter ADDR_WIDTH = 32,
              HASH_DEPTH = 6,
              PARA_WIDTH = 10
)(
    input wire                    clk,
    input wire                    rstn,

    input wire                    erEn,             // whether we need to erase
    input wire [ADDR_WIDTH - 1:0] erPC,             // erase place
    input wire                    eraseLower,       // how to erase the pair
    input wire                    eraseUpper,       // how to erase the pair

    input wire                    bdEn,             // whether we need to update 
    input wire [ADDR_WIDTH - 1:0] bdPC,             // instruction PC
    input wire [ADDR_WIDTH - 1:0] bdBack,           // instruction branch direction
    input wire              [1:0] bdType,           // instruction type
    input wire                    bdBranch,         // whether a branch is needed

    // wire for prediction
    input wire [ADDR_WIDTH - 1:0] ifPC,
    /**
     * para structure (from high to low):
     * name     bits    function
     * fact     2       the jump-or-not note
     * log      8       the experience for 11-10-01-00
     *                  each case has 2 bits
     */
    output wire [PARA_WIDTH - 1:0] ifParaLower,
    output wire [PARA_WIDTH - 1:0] ifParaUpper
);
    wire [HASH_DEPTH - 1:0] erAddrLower = {erPC[HASH_DEPTH + 1:3], 1'b0};
    wire [HASH_DEPTH - 1:0] erAddrUpper = {erPC[HASH_DEPTH + 1:3], 1'b1};
    wire [HASH_DEPTH - 1:0] bdAddr = bdPC[HASH_DEPTH + 1:2];

    reg [(1 << HASH_DEPTH) - 1:0] vld;
    initial vld <= 64'b0;
    always @(posedge clk or negedge rstn) begin
        if (rstn) vld <= 64'b0;
        else if (erEn) begin
            // erPC needs to be invalidated
            if (eraseLower) begin
                vld[erAddrLower] <= 1'b0;
                if (erAddrLower != bdAddr && bdEn)
                    vld[bdAddr] <= 1'b1;
            end
            if (eraseUpper) begin
                vld[erAddrUpper] <= 1'b0;
                if (erAddrUpper != bdAddr && bdEn)
                    vld[bdAddr] <= 1'b1;
            end
        end else if (bdEn)
            vld[bdAddr] <= 1'b1;
    end

    wire [HASH_DEPTH - 1:0] waddr_ex = bdPC[HASH_DEPTH + 1:2];
    wire [HASH_DEPTH - 1:0] raddr_ex = bdPC[HASH_DEPTH + 1:2];
    wire [HASH_DEPTH - 1:0] raddr_p1 = {ifPC[HASH_DEPTH + 1:3], 1'b0};
    wire [HASH_DEPTH - 1:0] raddr_p2 = {ifPC[HASH_DEPTH + 1:3], 1'b1};

    wire [PARA_WIDTH - 1:0] wdata_ex;
    wire [PARA_WIDTH - 1:0] rdata_ex;
    wire [PARA_WIDTH - 1:0] rdata_p1;
    wire [PARA_WIDTH - 1:0] rdata_p2;

    triple_port_memory #(
        .ADDR_WIDTH     (HASH_DEPTH),
        .DATA_WIDTH     (PARA_WIDTH)
    ) inst_para (
        .clk        (clk),
        .wt_en      (bdEn),
        .wtaddr     (waddr_ex),
        .wtdata     (wdata_ex),
        .raddr1     (raddr_ex),
        .rdata1     (rdata_ex),
        .raddr2     (raddr_p1),
        .rdata2     (rdata_p1),
        .raddr3     (raddr_p2),
        .rdata3     (rdata_p2)
    );

    wire [PARA_WIDTH - 1:0] init;
    log_init log_init(
        .branch (bdBranch),
        .back   (bdBack),
        .type   (bdType),
        .log    (init)
    );

    wire [PARA_WIDTH - 1:0] update;
    log_update log_update(
        .branch (bdBranch),
        .old    (rdata_ex),
        .new    (update)
    );

    assign wdata_ex = vld[waddr_ex] ? update : init;

    assign ifParaLower = rdata_p1;
    assign ifParaUpper = rdata_p2;

endmodule


module past #(
    parameter ADDR_WIDTH = 32,
              HASH_DEPTH = 6,
              PARA_WIDTH = 10
)(
    input wire                    clk,
    input wire                    rstn,

    input wire                    erEn,             // whether we need to erase
    input wire              [1:0] erSel,            // which block to erase
    input wire [ADDR_WIDTH - 1:0] erPC,             // erase place

    input wire                    bdEn,             // whether we need to update
    input wire              [1:0] bdSel,            // which block to update 
    input wire [ADDR_WIDTH - 1:0] bdPC,             // instruction PC
    input wire [ADDR_WIDTH - 1:0] bdPCTar,          // instruction branch target
    input wire              [1:0] bdType,           // instruction type
    input wire                    bdBranch,         // whether a branch is needed

    // wire for prediction
    input wire [ADDR_WIDTH - 1:0] pdPC,
    input wire              [1:0] pdSel,
    /**
     * para structure (from high to low):
     * name     bits    function
     * fact     2       the jump-or-not note
     * log      8       the experience for 11-10-01-00
     *                  each case has 2 bits
     */
    output wire [PARA_WIDTH - 1:0] p1Para,
    output wire [PARA_WIDTH - 1:0] p2Para
);
    /*
    reg [(1 << HASH_DEPTH) - 1:0] vld;
    initial vld <= 64'b0;
    always @(posedge clk or negedge rstn) begin
        if (erEn) begin
            // erPC needs to be invalidated for sure
            vld[{erPC[HASH_DEPTH + 1:3], 1'b0}] <= 1'b0;
            vld[{erPC[HASH_DEPTH + 1:3], 1'b1}] <= 1'b0;
            if (erPC[ADDR_WIDTH - 1:3] != bdPC[ADDR_WIDTH - 1:3] && bdEn)
                vld[bdPC[HASH_DEPTH + 1:2]] <= 1'b1;
        end else if (erPC[ADDR_WIDTH - 1:3] != bdPC[ADDR_WIDTH - 1:3] && bdEn)
                vld[bdPC[HASH_DEPTH + 1:2]] <= 1'b1;
    end

    wire [HASH_DEPTH - 1:0] waddr_ex = bdPC[HASH_DEPTH + 1:2];
    wire [HASH_DEPTH - 1:0] raddr_ex = bdPC[HASH_DEPTH + 1:2];
    wire [HASH_DEPTH - 1:0] raddr_p1 = {pdPC[HASH_DEPTH + 1:3], 1'b0};
    wire [HASH_DEPTH - 1:0] raddr_p2 = {pdPC[HASH_DEPTH + 1:3], 1'b1};

    wire [PARA_WIDTH - 1:0] wdata_ex;
    wire [PARA_WIDTH - 1:0] rdata_ex;
    wire [PARA_WIDTH - 1:0] rdata_p1 = p1Para;
    wire [PARA_WIDTH - 1:0] rdata_p2 = p2Para;

    triple_port_memory #(
        .DATA_DEPTH     (HASH_DEPTH),
        .DATA_WIDTH     (PARA_WIDTH)
    ) inst_para (
        .clk        (clk),
        .write_en   (en),
        .waddr      (waddr_ex),
        .wdata      (wdata_ex),
        .raddr1     (raddr_ex),
        .rdata1     (rdata_ex),
        .raddr2     (raddr_p1),
        .rdata2     (rdata_p1),
        .raddr3     (raddr_p2),
        .rdata3     (rdata_p2)
    );

    wire [PARA_WIDTH - 1:0] init;
    wire back = bdPCTar[ADDR_WIDTH - 1:2] < bdPC[ADDR_WIDTH - 1:2];
    log_init log_init(
        .branch (branch),
        .back   (back),
        .type   (type),
        .log    (init)
    );

    wire [9:0] update;
    log_update log_update(
        .branch (branch),
        .old    (rdata_ex),
        .new    (update)
    );

    assign wdata_ex = vld[waddr_ex] ? update : init;

    single_port_memory #(
        .ADDR_DEPTH (HASH_DEPTH),
        .ADDR_WIDTH (ADDR_WIDTH)
    ) para (
        .clk        (clk),
        .write_en   (en),
        .wtaddr     (data_wtaddr),
        .wtdata     (data_wtdata),
        .r1addr     (data_r1addr),
        .r1data     (data_r1data)
    );
    */
endmodule