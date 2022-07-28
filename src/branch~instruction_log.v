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

/* verilator lint_off DECLFILENAME */
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
     * structure of data
     * addr     30      the target address of this instruction
     * type     2       the type of this instruction
     */
    output wire                    ifExistLower,    // whether instruction exists
    output wire                    ifExistUpper,    // whether instruction exists
    output wire [ADDR_WIDTH - 1:0] ifDataLower,     // result data
    output wire [ADDR_WIDTH - 1:0] ifDataUpper      // result data
);
    wire [0:0] idUsefulLower;
    wire [0:0] idUsefulUpper;
    assign idUsefulLower = ^idTypeLower;
    assign idUsefulUpper = ^idTypeUpper;

    wire [HASH_DEPTH - 1:0] idWaddr = idPC[HASH_DEPTH + 2:3];
    wire [HASH_DEPTH - 1:0] exRaddr = exPC[HASH_DEPTH + 2:3];
    wire [HASH_DEPTH - 1:0] ifRaddr = ifPC[HASH_DEPTH + 2:3];

    wire [HASH_WIDTH - 1:0] idPCTag =
        idPC[HASH_WIDTH + HASH_DEPTH + 2:HASH_DEPTH + 3];
    wire [HASH_WIDTH - 1:0] exPCTag =
        exPC[HASH_WIDTH + HASH_DEPTH + 2:HASH_DEPTH + 3];
    wire [HASH_WIDTH - 1:0] ifPCTag =
        ifPC[HASH_WIDTH + HASH_DEPTH + 2:HASH_DEPTH + 3];

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
        vldLower = 32'b0;
        vldUpper = 32'b0;
    end

    assign idIsPair = vldLower[idWaddr] & vldUpper[idWaddr] & idTagLower == idTagUpper;

    always @(posedge clk) begin
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

    assign ifExistLower = vldLower[ifRaddr] & ifHitLower;
    assign ifExistUpper = vldUpper[ifRaddr] & ifHitUpper;

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

    output reg              [3:0] erSel,            // which block to erase
    output wire                   erLower,          // whether past needs to be erased
    output wire                   erUpper,          // whether past needs to be erased

    // wire for check tag
    input wire                    exVld,            // whether we update queue
    input wire [ADDR_WIDTH - 1:0] exPC,             // used for update
    output wire                   exExist,          // whether this pair exist
    output reg              [3:0] exSel,            // if exist, which block

    // wire for predict
    input wire [ADDR_WIDTH - 1:0] ifPC,             // instruction pair used to predict
    /* 
     * structure of data
     * addr     30      the target address of this instruction
     * type     2       the type of this instruction
     */
    output wire                   ifExistLower,     // whether instruction exists
    output wire                   ifExistUpper,     // whether instruction exists
    output reg              [1:0] ifSel,            // if exist, which block
    output reg [ADDR_WIDTH - 1:0] ifDataLower,      // result data
    output reg [ADDR_WIDTH - 1:0] ifDataUpper       // result data
);
    wire [ADDR_WIDTH - 1:0] ifDataLower1, ifDataLower2,
        ifDataLower3, ifDataLower4, ifDataUpper1, 
        ifDataUpper2, ifDataUpper3, ifDataUpper4;
    wire [0:0] idIsPair1;
    wire [0:0] idExist1;
    wire [0:0] idInsert1;
    wire [0:0] exExist1;
    wire [0:0] ifExistLower1;
    wire [0:0] ifExistUpper1;
    data #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .HASH_DEPTH (HASH_DEPTH),
        .HASH_WIDTH (HASH_WIDTH)
    ) way1 (
        .clk            (clk),
        .rstn           (rstn),

        .idEn           (erSel[0]),
        .idPC           (idPC),
        .idTypeLower    (idTypeLower),
        .idTypeUpper    (idTypeUpper),
        .idPCTarLower   (idPCTarLower),
        .idPCTarUpper   (idPCTarUpper),

        .idIsPair       (idIsPair1),
        .idExist        (idExist1),
        .idInsert       (idInsert1),

        .exPC           (exPC),
        .exExist        (exExist1),

        .ifPC           (ifPC),
        .ifExistLower   (ifExistLower1),
        .ifExistUpper   (ifExistUpper1),
        .ifDataLower    (ifDataLower1),
        .ifDataUpper    (ifDataUpper1)
    );
    wire [0:0] idIsPair2;
    wire [0:0] idExist2;
    wire [0:0] idInsert2;
    wire [0:0] exExist2;
    wire [0:0] ifExistLower2;
    wire [0:0] ifExistUpper2;
    data #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .HASH_DEPTH (HASH_DEPTH),
        .HASH_WIDTH (HASH_WIDTH)
    ) way2 (
        .clk            (clk),
        .rstn           (rstn),

        .idEn           (erSel[1]),
        .idPC           (idPC),
        .idTypeLower    (idTypeLower),
        .idTypeUpper    (idTypeUpper),
        .idPCTarLower   (idPCTarLower),
        .idPCTarUpper   (idPCTarUpper),

        .idIsPair       (idIsPair2),
        .idExist        (idExist2),
        .idInsert       (idInsert2),

        .exPC           (exPC),
        .exExist        (exExist2),

        .ifPC           (ifPC),
        .ifExistLower   (ifExistLower2),
        .ifExistUpper   (ifExistUpper2),
        .ifDataLower    (ifDataLower2),
        .ifDataUpper    (ifDataUpper2)
    );
    wire [0:0] idIsPair3;
    wire [0:0] idExist3;
    wire [0:0] idInsert3;
    wire [0:0] exExist3;
    wire [0:0] ifExistLower3;
    wire [0:0] ifExistUpper3;
    data #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .HASH_DEPTH (HASH_DEPTH),
        .HASH_WIDTH (HASH_WIDTH)
    ) way3 (
        .clk            (clk),
        .rstn           (rstn),

        .idEn           (erSel[2]),
        .idPC           (idPC),
        .idTypeLower    (idTypeLower),
        .idTypeUpper    (idTypeUpper),
        .idPCTarLower   (idPCTarLower),
        .idPCTarUpper   (idPCTarUpper),

        .idIsPair       (idIsPair3),
        .idExist        (idExist3),
        .idInsert       (idInsert3),

        .exPC           (exPC),
        .exExist        (exExist3),

        .ifPC           (ifPC),
        .ifExistLower   (ifExistLower3),
        .ifExistUpper   (ifExistUpper3),
        .ifDataLower    (ifDataLower3),
        .ifDataUpper    (ifDataUpper3)
    );
    wire [0:0] idIsPair4;
    wire [0:0] idExist4;
    wire [0:0] idInsert4;
    wire [0:0] exExist4;
    wire [0:0] ifExistLower4;
    wire [0:0] ifExistUpper4;
    data #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .HASH_DEPTH (HASH_DEPTH),
        .HASH_WIDTH (HASH_WIDTH)
    ) way4 (
        .clk            (clk),
        .rstn           (rstn),

        .idEn           (erSel[3]),
        .idPC           (idPC),
        .idTypeLower    (idTypeLower),
        .idTypeUpper    (idTypeUpper),
        .idPCTarLower   (idPCTarLower),
        .idPCTarUpper   (idPCTarUpper),

        .idIsPair       (idIsPair4),
        .idExist        (idExist4),
        .idInsert       (idInsert4),

        .exPC           (exPC),
        .exExist        (exExist4),

        .ifPC           (ifPC),
        .ifExistLower   (ifExistLower4),
        .ifExistUpper   (ifExistUpper4),
        .ifDataLower    (ifDataLower4),
        .ifDataUpper    (ifDataUpper4)
    );

    wire [3:0] visit = {exExist4, exExist3, exExist2, exExist1};
    // erase or not decided by numbers
    wire [3:0] select;
    way_select #(
        .HASH_DEPTH (HASH_DEPTH)
    ) way_select (
        .clk    (clk),
        .en     (exVld & |visit),
        .waddr  (exPC[HASH_DEPTH + 2:3]),
        .visit  (visit),
        .raddr  (idPC[HASH_DEPTH + 2:3]),
        .select (select)
    );

    // this "always" deals with idEn1 ~ 4
    wire [0:0] dataExist;
    assign dataExist = idExist1 | idExist2 | idExist3 | idExist4;
    always @(*) begin
        if (!idEn | dataExist) erSel = 4'b0000;
        else if (idInsert1) erSel = 4'b0001;
        else if (idInsert2) erSel = 4'b0010;
        else if (idInsert3) erSel = 4'b0100;
        else if (idInsert4) erSel = 4'b1000;
        else erSel = select;
    end

    wire isPair = erSel[0] & idIsPair1 
                | erSel[1] & idIsPair2
                | erSel[2] & idIsPair3
                | erSel[3] & idIsPair4;
    
    assign erLower = isPair ? 1'b1 : ^idTypeLower;
    assign erUpper = isPair ? 1'b1 : ^idTypeUpper;

    always @(*) begin
        if      (exExist1) exSel = {3'b0, exVld};
        else if (exExist2) exSel = {2'b0, exVld, 1'b0};
        else if (exExist3) exSel = {1'b0, exVld, 2'b0};
        else if (exExist4) exSel = {exVld, 3'b0};
        else               exSel = 4'b0000;
    end

    assign exExist = exExist1 | exExist2 | exExist3 | exExist4;

    always @(*) begin
        if (ifExistLower1 | ifExistUpper1) begin
            ifSel = 2'b00;
            ifDataLower = ifDataLower1;
            ifDataUpper = ifDataUpper1;
        end
        else if (ifExistLower2 | ifExistUpper2) begin
            ifSel = 2'b01;
            ifDataLower = ifDataLower2;
            ifDataUpper = ifDataUpper2;
        end
        else if (ifExistLower3 | ifExistUpper3) begin
            ifSel = 2'b10;
            ifDataLower = ifDataLower3;
            ifDataUpper = ifDataUpper3;
        end
        else begin
            ifSel = 2'b11;
            ifDataLower = ifDataLower4;
            ifDataUpper = ifDataUpper4;
        end
    end

    assign ifExistLower = 
        ifExistLower1 | ifExistLower2 | ifExistLower3 | ifExistLower4;
    assign ifExistUpper = 
        ifExistUpper1 | ifExistUpper2 | ifExistUpper3 | ifExistUpper4;

endmodule


module log_init (
    input wire       branch,
    input wire       back,
    input wire [1:0] type_,

    output reg [9:0] log
);
    always @(*) begin
        if (type_[1]) log = 10'b11_11_11_11_11;
        else begin
            if (type_[0]) begin
                log = {back, branch, back ? 
                    8'b10_10_10_01 : 8'b10_01_01_01};
            end else log = 10'b00_00_00_00_00;
        end
    end

endmodule


module log_update(
    input wire       branch,
    input wire [9:0] old,
    output reg [9:0] new_
);
    reg [1:0] tar;
    reg [1:0] learn;

    always @(*) begin
        case (old[9:8])
        2'b00: begin
            tar = old[1:0];
            new_ = {old[8], branch, old[7:2], learn};
        end
        2'b01: begin
            tar = old[3:2];
            new_ = {old[8], branch, old[7:4], learn, old[1:0]};
        end
        2'b10: begin
            tar = old[5:4];
            new_ = {old[8], branch, old[7:6], learn, old[3:0]};
        end
        2'b11: begin
            tar = old[7:6];
            new_ = {old[8], branch, learn, old[5:0]};
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
    input wire                    erLower,          // how to erase the pair
    input wire                    erUpper,          // how to erase the pair

    input wire                    bdEn,             // whether we need to update 
    input wire [ADDR_WIDTH - 1:0] bdPC,             // instruction PC
    input wire                    bdBack,           // instruction branch direction
    input wire              [1:0] bdType,           // instruction type
    input wire                    bdBranch,         // whether a branch is needed

    // wire for prediction
    input wire [ADDR_WIDTH - 1:0] ifPC,
    /**
     * structure of para (from high to low):
     * name     bits    function
     * fact     2       the jump-or-not note
     * log      8       the experience for 11-10-01-00
     *                  each case has 2 bits
     */
    output wire                    ifVldLower,
    output wire                    ifVldUpper,
    output wire [PARA_WIDTH - 1:0] ifParaLower,
    output wire [PARA_WIDTH - 1:0] ifParaUpper
);
    wire [HASH_DEPTH - 1:0] erAddrLower = {erPC[HASH_DEPTH + 1:3], 1'b0};
    wire [HASH_DEPTH - 1:0] erAddrUpper = {erPC[HASH_DEPTH + 1:3], 1'b1};
    wire [HASH_DEPTH - 1:0] bdAddr = bdPC[HASH_DEPTH + 1:2];

    reg [(1 << HASH_DEPTH) - 1:0] vld;
    initial vld = 64'b0;
    always @(posedge clk) begin
        if (!rstn) vld <= 64'b0;
        else if (erEn) begin
            // erPC needs to be invalidated
            if (erLower) begin
                vld[erAddrLower] <= 1'b0;
                if (erAddrLower != bdAddr && bdEn)
                    vld[bdAddr] <= 1'b1;
            end
            if (erUpper) begin
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
        .type_  (bdType),
        .log    (init)
    );

    wire [PARA_WIDTH - 1:0] update;
    log_update log_update(
        .branch (bdBranch),
        .old    (rdata_ex),
        .new_   (update)
    );

    assign wdata_ex = vld[waddr_ex] ? update : init;

    assign ifVldLower = vld[raddr_p1];
    assign ifVldUpper = vld[raddr_p2];
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

    input wire              [3:0] erSel,            // which block to erase
    input wire [ADDR_WIDTH - 1:0] erPC,             // erase place
    input wire                    erLower,          // how to erase the pair
    input wire                    erUpper,          // how to erase the pair

    input wire              [3:0] bdSel,            // which block to update 
    input wire [ADDR_WIDTH - 1:0] bdPC,             // instruction PC
    input wire                    bdBack,           // instruction branch target
    input wire              [1:0] bdType,           // instruction type
    input wire                    bdBranch,         // whether a branch is needed

    // wire for prediction
    input wire [ADDR_WIDTH - 1:0] ifPC,
    input wire              [1:0] ifSel,
    /**
     * structure of (from high to low):
     * name     bits    function
     * fact     2       the jump-or-not note
     * log      8       the experience for 11-10-01-00
     *                  each case has 2 bits
     */
    output reg                    ifVldLower,
    output reg                    ifVldUpper,
    output reg [PARA_WIDTH - 1:0] ifParaLower,
    output reg [PARA_WIDTH - 1:0] ifParaUpper
);
    wire [PARA_WIDTH - 1:0] ifParaLower1, ifParaLower2,
        ifParaLower3, ifParaLower4, ifParaUpper1,
        ifParaUpper2, ifParaUpper3, ifParaUpper4;
    wire [0:0] ifVldLower1;
    wire [0:0] ifVldUpper1;
    para #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .HASH_DEPTH (HASH_DEPTH),
        .PARA_WIDTH (PARA_WIDTH)
    ) way1 (
        .clk            (clk),
        .rstn           (rstn),

        .erEn           (erSel[0]),
        .erPC           (erPC),
        .erLower        (erLower),
        .erUpper        (erUpper),

        .bdEn           (bdSel[0]),
        .bdPC           (bdPC),
        .bdBack         (bdBack),
        .bdType         (bdType),
        .bdBranch       (bdBranch),

        .ifPC           (ifPC),
        .ifVldLower     (ifVldLower1),
        .ifVldUpper     (ifVldUpper1),
        .ifParaLower    (ifParaLower1),
        .ifParaUpper    (ifParaUpper1)
    );
    wire [0:0] ifVldLower2;
    wire [0:0] ifVldUpper2;
    para #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .HASH_DEPTH (HASH_DEPTH),
        .PARA_WIDTH (PARA_WIDTH)
    ) way2 (
        .clk            (clk),
        .rstn           (rstn),

        .erEn           (erSel[1]),
        .erPC           (erPC),
        .erLower        (erLower),
        .erUpper        (erUpper),

        .bdEn           (bdSel[1]),
        .bdPC           (bdPC),
        .bdBack         (bdBack),
        .bdType         (bdType),
        .bdBranch       (bdBranch),

        .ifPC           (ifPC),
        .ifVldLower     (ifVldLower2),
        .ifVldUpper     (ifVldUpper2),
        .ifParaLower    (ifParaLower2),
        .ifParaUpper    (ifParaUpper2)
    );
    wire [0:0] ifVldLower3;
    wire [0:0] ifVldUpper3;
    para #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .HASH_DEPTH (HASH_DEPTH),
        .PARA_WIDTH (PARA_WIDTH)
    ) way3 (
        .clk            (clk),
        .rstn           (rstn),

        .erEn           (erSel[2]),
        .erPC           (erPC),
        .erLower        (erLower),
        .erUpper        (erUpper),

        .bdEn           (bdSel[2]),
        .bdPC           (bdPC),
        .bdBack         (bdBack),
        .bdType         (bdType),
        .bdBranch       (bdBranch),

        .ifPC           (ifPC),
        .ifVldLower     (ifVldLower3),
        .ifVldUpper     (ifVldUpper3),
        .ifParaLower    (ifParaLower3),
        .ifParaUpper    (ifParaUpper3)
    );
    wire [0:0] ifVldLower4;
    wire [0:0] ifVldUpper4;
    para #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .HASH_DEPTH (HASH_DEPTH),
        .PARA_WIDTH (PARA_WIDTH)
    ) way4 (
        .clk            (clk),
        .rstn           (rstn),

        .erEn           (erSel[3]),
        .erPC           (erPC),
        .erLower        (erLower),
        .erUpper        (erUpper),

        .bdEn           (bdSel[3]),
        .bdPC           (bdPC),
        .bdBack         (bdBack),
        .bdType         (bdType),
        .bdBranch       (bdBranch),

        .ifPC           (ifPC),
        .ifVldLower     (ifVldLower4),
        .ifVldUpper     (ifVldUpper4),
        .ifParaLower    (ifParaLower4),
        .ifParaUpper    (ifParaUpper4)
    );
    

    always @(*) begin
        case (ifSel)
        2'b00: begin
            ifVldLower = ifVldLower1;
            ifVldUpper = ifVldUpper1;
            ifParaLower = ifParaLower1;
            ifParaUpper = ifParaUpper1;
        end
        2'b01: begin
            ifVldLower = ifVldLower2;
            ifVldUpper = ifVldUpper2;
            ifParaLower = ifParaLower2;
            ifParaUpper = ifParaUpper2;
        end
        2'b10: begin
            ifVldLower = ifVldLower3;
            ifVldUpper = ifVldUpper3;
            ifParaLower = ifParaLower3;
            ifParaUpper = ifParaUpper3;
        end
        2'b11: begin
            ifVldLower = ifVldLower4;
            ifVldUpper = ifVldUpper4;
            ifParaLower = ifParaLower4;
            ifParaUpper = ifParaUpper4;
        end
        endcase
    end

endmodule
