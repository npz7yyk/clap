`timescale 1ns / 1ps

module cpu_test1();
    // core_top Inputs
    reg   aclk;
    reg   aresetn;
    wire   [ 7:0]  intrpt;
    wire   arready;
    wire   [ 3:0]  rid;
    wire   [31:0]  rdata;
    wire   [ 1:0]  rresp;
    wire   rlast;
    wire   rvalid;
    wire   awready;
    wire   wready;
    wire   [ 3:0]  bid;
    wire   [ 1:0]  bresp;
    wire   bvalid;
    
    // core_top Outputs
    wire  [ 3:0]  arid;
    wire  [31:0]  araddr;
    wire  [ 7:0]  arlen;
    wire  [ 2:0]  arsize;
    wire  [ 1:0]  arburst;
    wire  [ 1:0]  arlock;
    wire  [ 3:0]  arcache;
    wire  [ 2:0]  arprot;
    wire  arvalid;
    wire  rready;
    wire  [ 3:0]  awid;
    wire  [31:0]  awaddr;
    wire  [ 7:0]  awlen;
    wire  [ 2:0]  awsize;
    wire  [ 1:0]  awburst;
    wire  [ 1:0]  awlock;
    wire  [ 3:0]  awcache;
    wire  [ 2:0]  awprot;
    wire  awvalid;
    wire  [ 3:0]  wid;
    wire  [31:0]  wdata;
    wire  [ 3:0]  wstrb;
    wire  wlast;
    wire  wvalid;
    wire  bready;
    wire  [31:0]  debug0_wb_pc;
    wire  [ 3:0]  debug0_wb_rf_wen;
    wire  [ 4:0]  debug0_wb_rf_wnum;
    wire  [31:0]  debug0_wb_rf_wdata;
    wire  [31:0]  debug0_wb_inst;

    core_top  core_top (
        .aclk                    ( aclk                 ),
        .aresetn                 ( aresetn              ),
        .intrpt                  ( intrpt               ),
        .arready                 ( arready              ),
        .rid                     ( rid                  ),
        .rdata                   ( rdata                ),
        .rresp                   ( rresp                ),
        .rlast                   ( rlast                ),
        .rvalid                  ( rvalid               ),
        .awready                 ( awready              ),
        .wready                  ( wready               ),
        .bid                     ( bid                  ),
        .bresp                   ( bresp                ),
        .bvalid                  ( bvalid               ),
    
        .arid                    ( arid                 ),
        .araddr                  ( araddr               ),
        .arlen                   ( arlen                ),
        .arsize                  ( arsize               ),
        .arburst                 ( arburst              ),
        .arlock                  ( arlock               ),
        .arcache                 ( arcache              ),
        .arprot                  ( arprot               ),
        .arvalid                 ( arvalid              ),
        .rready                  ( rready               ),
        .awid                    ( awid                 ),
        .awaddr                  ( awaddr               ),
        .awlen                   ( awlen                ),
        .awsize                  ( awsize               ),
        .awburst                 ( awburst              ),
        .awlock                  ( awlock               ),
        .awcache                 ( awcache              ),
        .awprot                  ( awprot               ),
        .awvalid                 ( awvalid              ),
        .wid                     ( wid                  ),
        .wdata                   ( wdata                ),
        .wstrb                   ( wstrb                ),
        .wlast                   ( wlast                ),
        .wvalid                  ( wvalid               ),
        .bready                  ( bready               ),
        .debug0_wb_pc            ( debug0_wb_pc         ),
        .debug0_wb_rf_wen        ( debug0_wb_rf_wen     ),
        .debug0_wb_rf_wnum       ( debug0_wb_rf_wnum    ),
        .debug0_wb_rf_wdata      ( debug0_wb_rf_wdata   ),
        .debug0_wb_inst          ( debug0_wb_inst       )
    );
    AXI_memory main_mem(
        .s_axi_araddr(araddr),
        .s_axi_arburst(arburst),
        .s_axi_arid(arid),
        .s_axi_arlen(arlen),
        .s_axi_arready(arready),
        .s_axi_arsize(arsize),
        .s_axi_arvalid(arvalid),
        .s_axi_awaddr(awaddr),
        .s_axi_awburst(awburst),
        .s_axi_awid(awid),
        .s_axi_awlen(awlen),
        .s_axi_awready(awready),
        .s_axi_awsize(awsize),
        .s_axi_awvalid(awvalid),
        .s_axi_bid(bid),
        .s_axi_bready(bready),
        .s_axi_bresp(bresp),
        .s_axi_bvalid(bvalid),
        .s_axi_rdata(rdata),
        .s_axi_rid(rid),
        .s_axi_rlast(rlast),
        .s_axi_rready(rready),
        .s_axi_rresp(rresp),
        .s_axi_rvalid(rvalid),
        .s_axi_wdata(wdata),
        .s_axi_wlast(wlast),
        .s_axi_wready(wready),
        .s_axi_wstrb(wstrb),
        .s_axi_wvalid(wvalid),
        
        .s_aclk(aclk),
        .s_aresetn(aresetn)
    );

    initial begin
        aclk = 1;
        forever
            #5 aclk <= ~aclk;
    end
    
    initial begin
        aresetn = 0;
        #10 aresetn = 1;
    end
endmodule
