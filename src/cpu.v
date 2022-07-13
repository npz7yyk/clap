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
    assign wid = awid;
    assign arlock[1] = 0;
    assign awlock[1] = 0;
    wire [3:0]  i_axi_awid;         wire [3:0]  d_axi_awid;
    wire [31:0] i_axi_awaddr;       wire [31:0] d_axi_awaddr;
    wire [7:0]  i_axi_awlen;        wire [7:0]  d_axi_awlen;
    wire [2:0]  i_axi_awsize;       wire [2:0]  d_axi_awsize;
    wire [1:0]  i_axi_awburst;      wire [1:0]  d_axi_awburst;
    wire [0:0]  i_axi_awlock;       wire [0:0]  d_axi_awlock;
    wire [3:0]  i_axi_awcache;      wire [3:0]  d_axi_awcache;
    wire [2:0]  i_axi_awprot;       wire [2:0]  d_axi_awprot;
    wire [3:0]  i_axi_awqos;        wire [3:0]  d_axi_awqos;
    wire [3:0]  i_axi_awregion;     wire [3:0]  d_axi_awregion;
    wire [0:0]  i_axi_awvalid;      wire [0:0]  d_axi_awvalid;
    wire [0:0]  i_axi_awready;      wire [0:0]  d_axi_awready;
    wire [31:0] i_axi_wdata;        wire [31:0] d_axi_wdata;
    wire [3:0]  i_axi_wstrb;        wire [3:0]  d_axi_wstrb;
    wire [0:0]  i_axi_wlast;        wire [0:0]  d_axi_wlast;
    wire [0:0]  i_axi_wvalid;       wire [0:0]  d_axi_wvalid;
    wire [0:0]  i_axi_wready;       wire [0:0]  d_axi_wready;
    wire [3:0]  i_axi_bid;          wire [3:0]  d_axi_bid;
    wire [1:0]  i_axi_bresp;        wire [1:0]  d_axi_bresp;
    wire [0:0]  i_axi_bvalid;       wire [0:0]  d_axi_bvalid;
    wire [0:0]  i_axi_bready;       wire [0:0]  d_axi_bready;
    wire [3:0]  i_axi_arid;         wire [3:0]  d_axi_arid;
    wire [31:0] i_axi_araddr;       wire [31:0] d_axi_araddr;
    wire [7:0]  i_axi_arlen;        wire [7:0]  d_axi_arlen;
    wire [2:0]  i_axi_arsize;       wire [2:0]  d_axi_arsize;
    wire [1:0]  i_axi_arburst;      wire [1:0]  d_axi_arburst;
    wire [0:0]  i_axi_arlock;       wire [0:0]  d_axi_arlock;
    wire [3:0]  i_axi_arcache;      wire [3:0]  d_axi_arcache;
    wire [2:0]  i_axi_arprot;       wire [2:0]  d_axi_arprot;
    wire [3:0]  i_axi_arqos;        wire [3:0]  d_axi_arqos;
    wire [3:0]  i_axi_arregion;     wire [3:0]  d_axi_arregion;
    wire [0:0]  i_axi_arvalid;      wire [0:0]  d_axi_arvalid;
    wire [0:0]  i_axi_arready;      wire [0:0]  d_axi_arready;
    wire [3:0]  i_axi_rid;          wire [3:0]  d_axi_rid;
    wire [31:0] i_axi_rdata;        wire [31:0] d_axi_rdata;
    wire [1:0]  i_axi_rresp;        wire [1:0]  d_axi_rresp;
    wire [0:0]  i_axi_rlast;        wire [0:0]  d_axi_rlast;
    wire [0:0]  i_axi_rvalid;       wire [0:0]  d_axi_rvalid;
    wire [0:0]  i_axi_rready;       wire [0:0]  d_axi_rready;
    //CPU是slave，RAM才是master
    axi_crossbar #(
        .S_COUNT(2),
        .M_COUNT(1),
        .S_ID_WIDTH(2),
        .M_ID_WIDTH(4)
    ) the_axi_crossbar(
        .clk(aclk),.rst(~aresetn),

        //master
        .m_axi_awid(awid),
        .m_axi_awaddr(awaddr),
        .m_axi_awlen(awlen),
        .m_axi_awsize(awsize),
        .m_axi_awburst(awburst),
        .m_axi_awlock(awlock[0]),
        .m_axi_awcache(awcache),
        .m_axi_awprot(awprot),
        //https://developer.arm.com/documentation/ihi0022/e/AMBA-AXI3-and-AXI4-Protocol-Specification/AXI4-Additional-Signaling/QoS-signaling/QoS-interface-signals?lang=en
        .m_axi_awqos(),
        .m_axi_awregion(),
        .m_axi_awuser(),
        .m_axi_awvalid(awvalid),
        .m_axi_awready(awready),

        //wid was removed in AXI4
        .m_axi_wdata(wdata),
        .m_axi_wstrb(wstrb),
        .m_axi_wlast(wlast),
        .m_axi_wuser(),
        .m_axi_wvalid(wvalid),
        .m_axi_wready(wready),

        .m_axi_bid(bid),
        .m_axi_bresp(bresp),
        .m_axi_buser(0),
        .m_axi_bvalid(bvalid),
        .m_axi_bready(bready),

        .m_axi_arid(arid),
        .m_axi_araddr(araddr),
        .m_axi_arlen(arlen),
        .m_axi_arsize(arsize),
        .m_axi_arburst(arburst),
        .m_axi_arlock(arlock[0]),
        .m_axi_arcache(arcache),
        .m_axi_arprot(arprot),
        .m_axi_arqos(),
        .m_axi_arregion(),
        .m_axi_aruser(),
        .m_axi_arvalid(arvalid),
        .m_axi_arready(arready),

        .m_axi_rid(rid),
        .m_axi_rdata(rdata),
        .m_axi_rresp(rresp),
        .m_axi_rlast(rlast),
        .m_axi_ruser(0),
        .m_axi_rvalid(rvalid),
        .m_axi_rready(rready),

        //slave
        .s_axi_awid     ({ i_axi_awid[1:0],  d_axi_awid[1:0]}),
        .s_axi_awaddr   ({ i_axi_awaddr   ,  d_axi_awaddr   }),
        .s_axi_awlen    ({ i_axi_awlen    ,  d_axi_awlen    }),
        .s_axi_awsize   ({ i_axi_awsize   ,  d_axi_awsize   }),
        .s_axi_awburst  ({ i_axi_awburst  ,  d_axi_awburst  }),
        .s_axi_awlock   ({ i_axi_awlock   ,  d_axi_awlock   }),
        .s_axi_awcache  ({ i_axi_awcache  ,  d_axi_awcache  }),
        .s_axi_awprot   ({ i_axi_awprot   ,  d_axi_awprot   }),
        .s_axi_awqos    (0),
        .s_axi_awuser   (0),
        .s_axi_awvalid  ({ i_axi_awvalid  ,  d_axi_awvalid  }),
        .s_axi_awready  ({ i_axi_awready  ,  d_axi_awready  }),
        .s_axi_wdata    ({ i_axi_wdata    ,  d_axi_wdata    }),
        .s_axi_wstrb    ({ i_axi_wstrb    ,  d_axi_wstrb    }),
        .s_axi_wlast    ({ i_axi_wlast    ,  d_axi_wlast    }),
        .s_axi_wuser    (0),
        .s_axi_wvalid   ({ i_axi_wvalid   ,  d_axi_wvalid   }),
        .s_axi_wready   ({ i_axi_wready   ,  d_axi_wready   }),
        .s_axi_bid      ({ i_axi_bid[1:0] ,  d_axi_bid[1:0] }),
        .s_axi_bresp    ({ i_axi_bresp    ,  d_axi_bresp    }),
        .s_axi_buser    (),
        .s_axi_bvalid   ({ i_axi_bvalid   ,  d_axi_bvalid   }),
        .s_axi_bready   ({ i_axi_bready   ,  d_axi_bready   }),
        .s_axi_arid     ({ i_axi_arid[1:0],  d_axi_arid[1:0]}),
        .s_axi_araddr   ({ i_axi_araddr   ,  d_axi_araddr   }),
        .s_axi_arlen    ({ i_axi_arlen    ,  d_axi_arlen    }),
        .s_axi_arsize   ({ i_axi_arsize   ,  d_axi_arsize   }),
        .s_axi_arburst  ({ i_axi_arburst  ,  d_axi_arburst  }),
        .s_axi_arlock   ({ i_axi_arlock   ,  d_axi_arlock   }),
        .s_axi_arcache  ({ i_axi_arcache  ,  d_axi_arcache  }),
        .s_axi_arprot   ({ i_axi_arprot   ,  d_axi_arprot   }),
        .s_axi_arqos    (0),
        .s_axi_aruser   (0),
        .s_axi_arvalid  ({ i_axi_arvalid  ,  d_axi_arvalid  }),
        .s_axi_arready  ({ i_axi_arready  ,  d_axi_arready  }),
        .s_axi_rid      ({ i_axi_rid[1:0] ,  d_axi_rid[1:0] }),
        .s_axi_rdata    ({ i_axi_rdata    ,  d_axi_rdata    }),
        .s_axi_rresp    ({ i_axi_rresp    ,  d_axi_rresp    }),
        .s_axi_rlast    ({ i_axi_rlast    ,  d_axi_rlast    }),
        .s_axi_ruser    (),
        .s_axi_rvalid   ({ i_axi_rvalid   ,  d_axi_rvalid   }),
        .s_axi_rready   ({ i_axi_rready   ,  d_axi_rready   })
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
    reg [6:0] pc_exception;
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
    wire [31:0] id_pc_for_predict,ex_branch_pc;
    wire [31:0] id_jmpdist0,id_jmpdist1;
    wire [1:0] id_category0,id_category1,ex_br_category;
    wire ex_feedback_valid,ex_did_jump;
    wire pred_known;
    wire pd_branch,pd_reason;
    branch_unit the_branch_predict
    (
        .clk(aclk),.rstn(aresetn),

        .ifVld(pc_stall_n),.ifPC(pc),

        .idVld(id_feedback_valid),
        .idPC(id_pc_for_predict),
        .idPCTar1(id_jmpdist0), .idPCTar2(id_jmpdist1),
        .idType1(id_category0), .idType2(id_category1),
        
        .exVld(ex_feedback_valid),
        .exPC(ex_branch_pc),
        .exPCTar(pc_executer),
        .exType(ex_br_category),
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
        
        .r_req          (i_axi_arvalid),
        .r_addr         (i_axi_araddr),
        .r_rdy          (i_axi_arready),
        .ret_valid      (i_axi_rvalid),
        .ret_last       (i_axi_rlast),
        .r_data_ready   (i_axi_rready),
        .r_data_AXI     (i_axi_rdata)
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
        .exception_in(0),//TODO: 处理icache阶段的exception
        .exception0_out(id_exception0),.exception1_out(id_exception1),
       
        .feedback_valid(id_feedback_valid),
        .pc_for_predict(id_pc_for_predict),
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
    wire  [6:0]  rf_eu0_exp,rf_eu1_exp;
    wire  [31:0]  rf_eu0_read_dataj, rf_eu1_read_dataj;
    wire  [31:0]  rf_eu0_read_datak, rf_eu1_read_datak;
    wire  [31:0]  rf_eu0_imm;

    wire rf_wen0;
    wire rf_wen1;
    wire [4:0]rf_waddr0;
    wire [4:0]rf_waddr1;
    wire [31:0]rf_wdata0;
    wire [31:0]rf_wdata1;

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

        .write_en_0   (rf_wen0  ),
        .write_en_1   (rf_wen1  ),
        .write_addr_0 (rf_waddr0),
        .write_addr_1 (rf_waddr1),
        .write_data_0 (rf_wdata0),
        .write_data_1 (rf_wdata1)
    );

    wire  ex_eu0_en, ex_eu1_en;
    wire  [31:0]  ex_eu0_data,ex_eu1_data;
    wire  [4:0]  ex_eu0_rd,ex_eu1_rd;
    wire  [6:0] ex_eu0_exp;
    wire  [31:0] ex_eu0_pc;
    
    wire  ex_mem_valid;
    wire  [0:0]  ex_mem_op;
    wire  [ 31:0 ]  ex_mem_addr;
    wire  [ 3:0 ]  ex_mem_write_type;
    wire  [ 31:0 ]  ex_mem_w_data_CPU,ex_mem_r_data_CPU;
    wire ex_mem_data_valid;

    assign ex_stall=0;

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
        .eu0_pc_out(ex_eu0_pc),

        //TODO
        //.stall                   ( ex_stall              ),
        .flush                   ( ex_flush              ),
        .branch_status           ( ex_did_jump ),
        .branch_valid            ( ex_feedback_valid ),
        .branch_pc               ( ex_branch_pc ),
        .category_out            ( ex_br_category ),
        .branch_addr_calculated  ( pc_executer   ),

        .valid                   ( ex_mem_valid                    ),
        .op                      ( ex_mem_op                       ),
        //????
        .addr(ex_mem_addr),
        // .index                   ( ex_mem_index                    ),
        // .tag                     ( ex_mem_tag                      ),
        // .offset                  ( ex_mem_offset                   ),
        .write_type              ( ex_mem_write_type               ),
        .w_data_CPU              ( ex_mem_w_data_CPU               ),
        //.addr_valid             (addr_valid),
        .data_valid             ( ex_mem_data_valid),
        .r_data_CPU             ( ex_mem_r_data_CPU)
    );

    //TODO: connect it
    dcache the_dcache
    (
        .clk(aclk),.rstn(aresetn),
        .valid(ex_mem_valid),
        .op(ex_mem_op),
        .addr(ex_mem_addr), //TODO: connect it to exe
        //.read_type(ex_mem_write_type),//TODO: write type in exe equals to read type in dcache???
        .write_type(ex_mem_write_type),
        .data_valid(ex_mem_data_valid),
        .r_data_CPU(ex_mem_r_data_CPU),
        .w_data_CPU(ex_mem_w_data_CPU),

        .r_req(d_axi_arvalid),
        .r_data_ready(d_axi_rready),
        //.r_type(),
        .r_addr(d_axi_araddr),
        .r_rdy(d_axi_arready),
        .ret_valid(d_axi_rvalid),
        .ret_last(d_axi_rlast),

        .w_req(d_axi_awvalid),
        .w_data_req(d_axi_wvalid),
        .w_last(d_axi_wlast),
        .b_ready(d_axi_bready),
        //.w_type(),
        .w_addr(d_axi_awaddr),
        .w_strb(d_axi_wstrb),
        .w_data_AXI(d_axi_wdata),
        .w_rdy(d_axi_awready),
        .b_valid(d_axi_bvalid)
    );

    assign set_pc_by_executer = ex_flush;

    writeback the_writeback
    (
        .eu0_valid(ex_eu0_en), .eu1_valid(ex_eu1_en),
        .eu0_data(ex_eu0_data),.eu1_data(ex_eu1_data),
        .eu0_rd(ex_eu0_rd),    .eu1_rd(ex_eu1_rd),
        .eu0_pc(ex_eu0_pc),
        .eu0_exception(ex_eu0_exp),

        .wen0(rf_wen0),.wen1(rf_wen1),
        .waddr0(rf_waddr0),.waddr1(rf_waddr1),
        .wdata0(rf_wdata0),.wdata1(rf_wdata1),

        .set_pc(set_pc_by_writeback),
        .pc(pc_writeback)
    );
endmodule 
