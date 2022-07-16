
//TODO: handle exception
module writeback
(   
    input eu0_valid,eu1_valid,
    input [31:0] eu0_data,eu1_data,
    input [4:0] eu0_rd,eu1_rd,
    input [31:0] eu0_pc,eu1_pc,
    input [6:0] eu0_exception,

    //connect to register file
    output wen0,wen1,
    output [4:0] waddr0,waddr1,
    output [31:0] wdata0,wdata1,
    output [31:0] debug0_wb_pc,
    output [ 3:0] debug0_wb_rf_wen,
    output [ 4:0] debug0_wb_rf_wnum,
    output [31:0] debug0_wb_rf_wdata,

    output [31:0] debug1_wb_pc,
    output [ 3:0] debug1_wb_rf_wen,
    output [ 4:0] debug1_wb_rf_wnum,
    output [31:0] debug1_wb_rf_wdata,
    
    //connect to PC
    output set_pc,
    output [31:0] pc
);

    assign pc=0;
    assign set_pc=0;
    assign wen0 = eu0_valid && eu0_rd!=0 && eu0_exception==0;
    assign wen1 = eu1_valid && eu1_rd!=0;
    assign waddr0 = eu0_rd;
    assign waddr1 = eu1_rd;
    assign wdata0 = eu0_data;
    assign wdata1 = eu1_data;

    assign debug0_wb_pc = eu0_pc;
    assign debug0_wb_rf_wen = wen0;
    assign debug0_wb_rf_wnum = eu0_rd;

    assign debug1_wb_pc = eu1_pc;
    assign debug1_wb_rf_wen = wen1;
    assign debug1_wb_rf_wnum = eu1_rd;
endmodule