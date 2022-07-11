`include "uop.vh"

module core_top(
    input           aclk,
    input           aresetn,
    input    [ 7:0] intrpt, 
    //AXI interface 
    //read reqest
    output   [ 3:0] arid,
    output   [31:0] araddr,
    output   [ 7:0] arlen,
    output   [ 2:0] arsize,
    output   [ 1:0] arburst,
    output   [ 1:0] arlock,
    output   [ 3:0] arcache,
    output   [ 2:0] arprot,
    output          arvalid,
    input           arready,
    //read back
    input    [ 3:0] rid,
    input    [31:0] rdata,
    input    [ 1:0] rresp,
    input           rlast,
    input           rvalid,
    output          rready,
    //write request
    output   [ 3:0] awid,
    output   [31:0] awaddr,
    output   [ 7:0] awlen,
    output   [ 2:0] awsize,
    output   [ 1:0] awburst,
    output   [ 1:0] awlock,
    output   [ 3:0] awcache,
    output   [ 2:0] awprot,
    output          awvalid,
    input           awready,
    //write data
    output   [ 3:0] wid,
    output   [31:0] wdata,
    output   [ 3:0] wstrb,
    output          wlast,
    output          wvalid,
    input           wready,
    //write back
    input    [ 3:0] bid,
    input    [ 1:0] bresp,
    input           bvalid,
    output          bready,

    output [31:0] debug0_wb_pc,
    output [ 3:0] debug0_wb_rf_wen,
    output [ 4:0] debug0_wb_rf_wnum,
    output [31:0] debug0_wb_rf_wdata,
    output [31:0] debug0_wb_inst
);
    wire data_valid;
    wire if_buf_full;
    reg just_reset;
    always @(posedge aclk)
        if(~aresetn)just_reset<=1;
        else just_reset<=0;
    //stall信号与valid信号不同，
    //在没有读请求时，i-cache的data_valid=0，但是PC不能在此时stall，否则待到data_valid=1时，相同的指令会被取出两次
    // 这种情况只会发生在刚刚reset后，解决方法是令刚刚reset后的data_valid=1
    wire pc_stall_n=data_valid | just_reset;
    
    reg [31:0] pc;
    wire [31:0] pc_next = pc+8;
    always @(posedge aclk)
        if(~aresetn)
            pc <= 0;
        else if(pc_stall_n) pc <= pc_next;

    wire [63:0] r_data_CPU;
    wire [31:0] if_pc,if_pc_next;
    icache the_icache (
        .clk            (aclk),
        .rstn           (aresetn),
        .valid          (~if_buf_full),
        .pc_in          (pc),
        .pc_next_in     (pc_next),
        .data_valid     (data_valid),
        .r_data_CPU     (r_data_CPU),
        .pc_out         (if_pc),
        .pc_next_out    (if_pc_next),
        
        .r_req          (arvalid),
        .r_addr         (araddr),
        .r_rdy          (arready),
        .ret_valid      (rvalid),
        .ret_last       (rlast),
        .r_data_ready   (rready),
        .r_data_AXI     (rdata)
    );
    
    wire [1:0] id_read_en;
    wire [`WIDTH_UOP-1:0] id_uop0,id_uop1;
    wire [31:0] id_imm0,id_imm1;
    wire [4:0] id_rd0,id_rd1,id_rk0,id_rk1,id_rj0,id_rj1;
    wire id_invalid0,id_invalid1;
    wire [31:0] id_pc0,id_pc1,id_pc_next0,id_pc_next1;
    
    id_stage the_decoder (
        .clk(aclk), .rstn(aresetn),
        .flush(0),
        .read_en(id_read_en),
        .full(if_buf_full),
        .input_valid(data_valid),
        .inst0(r_data_CPU[31:0]),
        .inst1(r_data_CPU[63:32]),
        .first_inst_jmp(0),
        
        .pc_in(if_pc),.pc_next_in(if_pc_next),
        .pc0_out(id_pc0),.pc1_out(id_pc1),
        .pc_next0_out(id_pc_next0),.pc_next1_out(id_pc_next1)
        
        //.jmpdist0(),.jmpdist1(),
        //.categroy0(),.categroy1(),
    );
    
    wire is_eu0_en,is_eu1_en;
    wire [`WIDTH_UOP-1:0] is_eu0_uop,is_eu1_uop;
    wire [4:0] is_eu0_rd,is_eu0_rj,is_eu0_rk;
    wire [4:0] is_eu1_rd,is_eu1_rj,is_eu1_rk;
    wire [31:0] is_eu0_imm,is_eu1_imm;
    wire [31:0] is_eu0_pc,is_eu0_pc_next;
    wire [31:0] is_eu1_pc,is_eu1_pc_next;
    wire is_eu0_invalid,is_eu1_invalid;
    is_stage the_issue (
        .clk(aclk),.rstn(aresetn),
        .num_read(id_read_en),
        .flush(0),
        
        .uop0(id_uop0),.uop1(id_uop1),
        .rd0(id_rd0),.rd1(id_rd1),.rk0(id_rk0),.rk1(id_rk1),.rj0(id_rj0),.rj1(id_rj1),
        .imm0(id_imm0),.imm1(id_imm1),
        .invalid0(id_invalid0),.invalid1(id_invalid1),
        .pc0(id_pc0),.pc1(id_pc1),
        .pc_next0(id_pc_next0),.pc_next1(id_pc_next1),
        
        .eu0_en(is_eu0_en),
        .eu0_ready(1),
        .eu0_finish(1),
        .eu0_uop(is_eu0_uop),
        .eu0_rd(is_eu0_rd),
        .eu0_rj(is_eu0_rj),
        .eu0_rk(is_eu0_rk),
        .eu0_imm(is_eu0_imm),
        .eu0_pc(is_eu0_pc),
        .eu0_pc_next(is_eu0_pc_next),
        .eu0_invalid(is_eu0_invalid),
        
        .eu1_en(is_eu1_en),
        .eu1_ready(1),
        .eu1_finish(1),
        .eu1_uop(is_eu1_uop),
        .eu1_rd(is_eu1_rd),
        .eu1_rj(is_eu1_rj),
        .eu1_rk(is_eu1_rk),
        .eu1_imm(is_eu1_imm),
        .eu1_pc(is_eu1_pc),
        .eu1_pc_next(is_eu1_pc_next),
        .eu1_invalid(is_eu1_invalid)
    );
endmodule 
