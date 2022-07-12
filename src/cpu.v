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
        else just_reset<=if_buf_full;
    //stall信号与valid信号不同，
    //在没有读请求时，i-cache的data_valid=0，但是PC不能在此时stall，否则待到data_valid=1时，相同的指令会被取出两次
    // 这种情况只会发生在刚刚reset后，解决方法是令刚刚reset后的data_valid=1
    wire pc_stall_n=(data_valid|just_reset) & ~if_buf_full;
    
    reg [31:0] pc;
    wire [31:0] pc_next;
    wire set_pc_by_decoder,set_pc_by_executer,set_pc_by_writeback;
    wire [31:0] pc_decoder,pc_executer,pc_writeback;
    reg [7:0] pc_exception;
    always @(posedge aclk)
        if(~aresetn)
            pc <= 0;
        else if(pc_stall_n) begin
            if(set_pc_by_writeback)
                pc <= pc_writeback;
            else if(set_pc_by_executer)
                pc <= pc_executer;
            else if(set_pc_by_decoder)
                pc <= pc_decoder;
            else
                pc <= pc_next;
        end
    
    wire id_feedback_valid;
    wire [31:0] pc_for_predict;
    wire [31:0] id_jmpdist0,id_jmpdist1;
    wire [1:0] id_category0,id_category1;
    wire ex_feedback_valid,ex_did_jump;
    wire pred_known;
    wire pd_branch,pd_reason;
    branch_unit the_branch_predict
    (
        .clk(aclk),.rstn(aresetn),

        .ifVld(pc_stall_n),.ifPC(pc),

        .idVld(id_feedback_valid),
        .idPC(pc_for_predict),
        .idPCTar1(id_jmpdist0), .idPCTar2(id_jmpdist1),
        .idType1(id_category0), .idType2(id_category1),
        
        .exVld(ex_feedback_valid),
        //.exPC(),
        .exPCTar(pc_executer),
        //.exType(),
        .exBranch(ex_did_jump),
        .exWrong(set_pc_by_executer),

        .pdPC(pc_next),
        .pdKnown(pred_known),
        .pdBranch(pd_branch),
        .pdReason(pd_reason)
    );

    wire [63:0] r_data_CPU;
    wire [31:0] if_pc,if_pc_next;
    wire if_known;
    wire first_inst_jmp;
    icache #(34) the_icache (
        .clk            (aclk),
        .rstn           (aresetn),
        .valid          (~if_buf_full),
        .pc_in          (pc),
        .cookie_in      ({pd_branch&~pd_reason,pred_known,pc_next}),
        .cookie_out     ({first_inst_jmp,if_known,if_pc_next}),
        .data_valid     (data_valid),
        .r_data_CPU     (r_data_CPU),
        .pc_out         (if_pc),
        
        .r_req          (arvalid),
        .r_addr         (araddr),
        .r_rdy          (arready),
        .ret_valid      (rvalid),
        .ret_last       (rlast),
        .r_data_ready   (rready),
        .r_data_AXI     (rdata)
    );
    
    wire  ex_flush;
    wire [1:0] id_read_en;
    wire [`WIDTH_UOP-1:0] id_uop0,id_uop1;
    wire [31:0] id_imm0,id_imm1;
    wire [4:0] id_rd0,id_rd1,id_rk0,id_rk1,id_rj0,id_rj1;
    wire [6:0] id_exception0,id_exception1;
    wire [31:0] id_pc0,id_pc1,id_pc_next0,id_pc_next1;
    
    id_stage the_decoder (
        .clk(aclk), .rstn(aresetn),
        .flush(ex_flush),
        .read_en(id_read_en),
        .full(if_buf_full),
        .input_valid(data_valid),
        .inst0(r_data_CPU[31:0]),
        .inst1(r_data_CPU[63:32]),
        .unknown0(~if_known),.unknown1(~if_known),
        .first_inst_jmp(first_inst_jmp),
        
        .uop0(id_uop0),.uop1(id_uop1),
        .imm0(id_imm0),.imm1(id_imm1),
        .rd0(id_rd0),.rd1(id_rd1),
        .rk0(id_rk0),.rk1(id_rk1),
        .rj0(id_rj0),.rj1(id_rj1),
        
        .pc_in(if_pc),.pc_next_in(if_pc_next),
        .pc0_out(id_pc0),.pc1_out(id_pc1),
        .pc_next0_out(id_pc_next0),.pc_next1_out(id_pc_next1),
        .exception_in(0),
        .exception0_out(id_exception0),.exception1_out(id_exception1),
       
        .feedback_valid(id_feedback_valid),
        .pc_for_predict(pc_for_predict),
        .jmpdist0(id_jmpdist0),.jmpdist1(id_jmpdist1),
        .category0(id_category0),.category1(id_category1),

        .probably_right_destination(pc_decoder),
        .set_pc(set_pc_by_decoder)

    );
    wire  ex_stall;
    wire is_eu0_en_3qW1U3J0hMn,is_eu1_en_3qW1U3J0hMn;
    wire [`WIDTH_UOP-1:0] is_eu0_uop_3qW1U3J0hMn,is_eu1_uop_3qW1U3J0hMn;
    wire [4:0] is_eu0_rd_3qW1U3J0hMn,is_eu0_rj_3qW1U3J0hMn,is_eu0_rk_3qW1U3J0hMn;
    wire [4:0] is_eu1_rd_3qW1U3J0hMn,is_eu1_rj_3qW1U3J0hMn,is_eu1_rk_3qW1U3J0hMn;
    wire [31:0] is_eu0_imm_3qW1U3J0hMn,is_eu1_imm_3qW1U3J0hMn;
    wire [31:0] is_eu0_pc_3qW1U3J0hMn,is_eu0_pc_next_3qW1U3J0hMn;
    wire [31:0] is_eu1_pc_3qW1U3J0hMn,is_eu1_pc_next_3qW1U3J0hMn;
    wire [6:0] is_eu0_exception_3qW1U3J0hMn,is_eu1_exception_3qW1U3J0hMn;
    is_stage the_issue (
        .clk(aclk),.rstn(aresetn),
        .num_read(id_read_en),
        .flush(ex_flush),
        
        .uop0(id_uop0),.uop1(id_uop1),
        .rd0(id_rd0),.rd1(id_rd1),.rk0(id_rk0),.rk1(id_rk1),.rj0(id_rj0),.rj1(id_rj1),
        .imm0(id_imm0),.imm1(id_imm1),
        .exception0(id_exception0),.exception1(id_exception1),
        .pc0(id_pc0),.pc1(id_pc1),
        .pc_next0(id_pc_next0),.pc_next1(id_pc_next1),
        
        .eu0_en(is_eu0_en_3qW1U3J0hMn),
        .eu0_ready(~ex_stall),
        .eu0_finish(1),
        .eu0_uop(is_eu0_uop_3qW1U3J0hMn),
        .eu0_rd(is_eu0_rd_3qW1U3J0hMn),
        .eu0_rj(is_eu0_rj_3qW1U3J0hMn),
        .eu0_rk(is_eu0_rk_3qW1U3J0hMn),
        .eu0_imm(is_eu0_imm_3qW1U3J0hMn),
        .eu0_pc(is_eu0_pc_3qW1U3J0hMn),
        .eu0_pc_next(is_eu0_pc_next_3qW1U3J0hMn),
        .eu0_exception(is_eu0_exception_3qW1U3J0hMn),
        
        .eu1_en(is_eu1_en_3qW1U3J0hMn),
        .eu1_ready(~ex_stall),
        .eu1_finish(1),
        .eu1_uop(is_eu1_uop_3qW1U3J0hMn),
        .eu1_rd(is_eu1_rd_3qW1U3J0hMn),
        .eu1_rj(is_eu1_rj_3qW1U3J0hMn),
        .eu1_rk(is_eu1_rk_3qW1U3J0hMn),
        .eu1_imm(is_eu1_imm_3qW1U3J0hMn),
        .eu1_pc(is_eu1_pc_3qW1U3J0hMn),
        .eu1_pc_next(is_eu1_pc_next_3qW1U3J0hMn),
        .eu1_exception(is_eu1_exception_3qW1U3J0hMn)
    );

    wire is_eu0_en,is_eu1_en;
    wire [`WIDTH_UOP-1:0] is_eu0_uop,is_eu1_uop;
    wire [4:0] is_eu0_rd,is_eu0_rj,is_eu0_rk;
    wire [4:0] is_eu1_rd,is_eu1_rj,is_eu1_rk;
    wire [31:0] is_eu0_imm,is_eu1_imm;
    wire [31:0] is_eu0_pc,is_eu0_pc_next;
    wire [31:0] is_eu1_pc,is_eu1_pc_next;
    wire [6:0] is_eu0_exception,is_eu1_exception;

    execute_unit_input_reg euir0
    (
        .clk(aclk),.rstn(aresetn),.flush(ex_flush),.stall(ex_stall),
        
        .en_in(is_eu0_en_3qW1U3J0hMn),.en_out(is_eu0_en),
        .uop_in(is_eu0_uop_3qW1U3J0hMn),.uop_out(is_eu0_uop),
        .rd_in(is_eu0_rd_3qW1U3J0hMn),.rd_out(is_eu0_rd),
        .rj_in(is_eu0_rj_3qW1U3J0hMn),.rj_out(is_eu0_rj),
        .rk_in(is_eu0_rk_3qW1U3J0hMn),.rk_out(is_eu0_rk),
        .imm_in(is_eu0_imm_3qW1U3J0hMn),.imm_out(is_eu0_imm),
        .pc_in(is_eu0_pc_3qW1U3J0hMn),.pc_out(is_eu0_pc),
        .pc_next_in(is_eu0_pc_next_3qW1U3J0hMn),.pc_next_out(is_eu0_pc_next),
        .exception_in(is_eu0_exception_3qW1U3J0hMn),.exception_out(is_eu0_exception)
    );

    execute_unit_input_reg euir1
    (
        .clk(aclk),.rstn(aresetn),.flush(ex_flush),.stall(ex_stall),
        
        .en_in(is_eu1_en_3qW1U3J0hMn),.en_out(is_eu1_en),
        .uop_in(is_eu1_uop_3qW1U3J0hMn),.uop_out(is_eu1_uop),
        .rd_in(is_eu1_rd_3qW1U3J0hMn),.rd_out(is_eu1_rd),
        .rj_in(is_eu1_rj_3qW1U3J0hMn),.rj_out(is_eu1_rj),
        .rk_in(is_eu1_rk_3qW1U3J0hMn),.rk_out(is_eu1_rk),
        .imm_in(is_eu1_imm_3qW1U3J0hMn),.imm_out(is_eu1_imm),
        .pc_in(is_eu1_pc_3qW1U3J0hMn),.pc_out(is_eu1_pc),
        .pc_next_in(is_eu1_pc_next_3qW1U3J0hMn),.pc_next_out(is_eu1_pc_next),
        .exception_in(is_eu1_exception_3qW1U3J0hMn),.exception_out(is_eu1_exception)
    );

    reg [63:0] stable_counter;
    always @(posedge aclk)
        if(~aresetn) stable_counter<=0;
        else stable_counter <= stable_counter+1;
    
    wire  [0:0]  rf_eu0_en,rf_eu1_en;
    wire  [`WIDTH_UOP-1:0]  rf_eu0_uop,rf_eu1_uop;
    wire  [4:0]  rf_eu0_rd,rf_eu1_rd;
    wire  [4:0]  rf_eu0_rj,rf_eu1_rj;
    wire  [4:0]  rf_eu0_rk,rf_eu1_rk;
    wire  [31:0]  rf_eu0_pc,rf_eu1_pc;
    wire  [31:0]  rf_eu0_pc_next,rf_eu1_pc_next;
    wire  [5:0]  rf_eu0_exp,rf_eu1_exp;
    wire  [31:0]  rf_eu0_read_dataj, rf_eu1_read_dataj;
    wire  [31:0]  rf_eu0_read_datak, rf_eu1_read_datak;
    wire  [31:0]  rf_eu0_imm;

    register_file  the_register (
        .clk                     ( aclk              ),
        
        .stable_counter(stable_counter),
        .eu0_en_in     (is_eu0_en     ), .eu1_en_in     (is_eu1_en     ),
        .eu0_uop_in    (is_eu0_uop    ), .eu1_uop_in    (is_eu1_uop    ),
        .eu0_rd_in     (is_eu0_rd     ), .eu1_rd_in     (is_eu1_rd     ),
        .eu0_rj_in     (is_eu0_rj     ), .eu1_rj_in     (is_eu1_rj     ),
        .eu0_rk_in     (is_eu0_rk     ), .eu1_rk_in     (is_eu1_rk     ),
        .eu0_pc_in     (is_eu0_pc     ), .eu1_pc_in     (is_eu1_pc     ),
        .eu0_pc_next_in(is_eu0_pc_next), .eu1_pc_next_in(is_eu1_pc_next),
        .eu0_exp_in    (is_eu0_exception), .eu1_exp_in    (is_eu1_exception),
        .eu0_imm_in    (is_eu0_imm    ), .eu1_imm_in    (is_eu1_imm    ),

        .eu0_en_out     (rf_eu0_en        ), .eu1_en_out     (rf_eu1_en        ),
        .eu0_uop_out    (rf_eu0_uop       ), .eu1_uop_out    (rf_eu1_uop       ),
        .eu0_rd_out     (rf_eu0_rd        ), .eu1_rd_out     (rf_eu1_rd        ),
        .eu0_rj_out     (rf_eu0_rj        ), .eu1_rj_out     (rf_eu1_rj        ),
        .eu0_rk_out     (rf_eu0_rk        ), .eu1_rk_out     (rf_eu1_rk        ),
        .eu0_pc_out     (rf_eu0_pc        ), .eu1_pc_out     (rf_eu1_pc        ),
        .eu0_pc_next_out(rf_eu0_pc_next   ), .eu1_pc_next_out(rf_eu1_pc_next   ),
        .eu0_exp_out    (rf_eu0_exp       ), .eu1_exp_out    (rf_eu1_exp       ),
        .read_data00    (rf_eu0_read_dataj), .read_data10    (rf_eu1_read_dataj),
        .read_data01    (rf_eu0_read_datak), .read_data11    (rf_eu1_read_datak),
        .eu0_imm_out    (rf_eu0_imm       ),  

        .write_en_0   (write_en_0  ),
        .write_en_1   (write_en_1  ),
        .write_addr_0 (write_addr_0),
        .write_addr_1 (write_addr_1),
        .write_data_0 (write_data_0),
        .write_data_1 (write_data_1)
    );

    wire  [0:0]  ex_eu0_en, ex_eu1_en;
    wire  [31:0]  ex_eu0_data,ex_eu1_data;
    wire  [4:0]  ex_eu0_rd,ex_eu1_rd;
    wire  [5:0] ex_eu0_exp,ex_eu1_exp;
    
    // wire  branch_addr_calculated;
    // wire  [0:0]  valid;
    // wire  [1:0]  op;
    // wire  [ 5:0 ]  index;
    // wire  [ 19:0 ]  tag;
    // wire  [ 5:0 ]  offset;
    // wire  [ 3:0 ]  write_type;
    // wire  [ 31:0 ]  w_data_CPU;

    exe  the_exe (
        .clk           (aclk          ),
        .rstn          (aresetn       ),
        .eu0_en_in     (rf_eu0_en     ), .eu1_en_in (rf_eu1_en ),
        .eu0_uop_in    (rf_eu0_uop    ), .eu1_uop_in(rf_eu1_uop),
        .eu0_rd_in     (rf_eu0_rd     ), .eu1_rd_in (rf_eu1_rd ),
        .eu0_rj_in     (rf_eu0_rj     ), .eu1_rj_in (rf_eu1_rj ),
        .eu0_rk_in     (rf_eu0_rk     ), .eu1_rk_in (rf_eu1_rk ),
        .eu0_imm_in    (rf_eu0_imm     ),
        .eu0_pc_in     (rf_eu0_pc     ),
        .eu0_pc_next_in(rf_eu0_pc_next),
        .eu0_exp_in    (rf_eu0_exp    ), //.eu1_exp_in    ( rf_eu1_exp    ),
        .data00        (rf_eu0_read_dataj), .data10(rf_eu1_read_dataj),
        .data01        (rf_eu0_read_datak), .data11(rf_eu1_read_datak),
        

        .en_out0  (ex_eu0_en  ), .en_out1  (ex_eu1_en  ),
        .data_out0(ex_eu0_data), .data_out1(ex_eu1_data),
        .addr_out0(ex_eu0_rd  ), .addr_out1(ex_eu1_rd  ),
        .exp_out  (ex_eu0_exp ), //.exp_out  (ex_eu1_exp ),

        .stall                   ( ex_stall              ),
        .flush                   ( ex_flush              ),
        .branch_status           ( ex_did_jump ),
        .branch_valid            ( ex_feedback_valid ),
        .branch_addr_calculated  ( pc_executer   )//,

        //TODO
        // .valid                   ( valid                    ),
        // .op                      ( op                       ),
        // .index                   ( index                    ),
        // .tag                     ( tag                      ),
        // .offset                  ( offset                   ),
        // .write_type              ( write_type               ),
        // .w_data_CPU              ( w_data_CPU               ),
        // .addr_valid(addr_valid),
        // .data_valid(data_valid),
        // .r_data_CPU(r_data_CPU)
    );
    assign set_pc_by_executer = ex_flush;
endmodule 
