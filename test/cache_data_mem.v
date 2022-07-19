module data_mem(
    input clk,
    input rstn,
    input valid,
    input op,
    input [31:0] addr,
    input [31:0] w_data_CPU,
    input [3:0] write_type,
    output data_valid,
    output [31:0] r_data_CPU,
    output [6:0] exp
    );
    wire r_req, r_rdy, ret_valid, ret_last, rready;
    wire [3:0] rid;
    wire [31:0] r_addr, r_data_AXI;
    wire [2:0] r_size;
    wire [7:0] r_length;
    wire cache_ready;

    wire w_req, w_data_req, w_last, b_ready;
    wire [31:0] w_addr, w_data_AXI;
    wire [3:0] w_strb;
    wire [2:0] w_size;
    wire [7:0] w_length;
    wire w_rdy, w_data_ready, b_valid;
    wire [3:0] bid;

    wire [1:0] r_resp;
    wire [1:0] b_resp;

    reg [31:0] p_addr;
    always @(posedge clk) begin
        p_addr <= addr;
    end

    dcache cache(
        .clk            (clk),
        .rstn           (rstn),
        .valid          (valid),
        .addr           (addr),
        .p_addr         (p_addr),
        .op             (op),
        .uncache        (1'b1),
        .write_type     (write_type),
        .w_data_CPU     (w_data_CPU),
        .signed_ext     (1'b1),
        .data_valid     (data_valid),
        .cache_ready    (cache_ready),
        .r_data_CPU     (r_data_CPU),

        .r_req          (r_req),
        .r_addr         (r_addr),
        .r_rdy          (r_rdy),
        .r_size         (r_size),
        .r_length       (r_length),
        .ret_valid      (ret_valid),
        .ret_last       (ret_last),
        .r_data_ready   (rready),
        .r_data_AXI     (r_data_AXI),

        .w_req          (w_req),
        .w_data_req     (w_data_req),
        .w_last         (w_last),
        .w_size         (w_size),
        .w_length       (w_length),
        .w_addr         (w_addr),
        .w_strb         (w_strb),
        .w_data_AXI     (w_data_AXI),
        .w_rdy          (w_rdy),
        .w_data_ready   (w_data_ready),

        .b_ready        (b_ready),
        .b_valid        (b_valid),

        .exception      (exp)
    );
    AXI_memory main_mem(
        .s_aclk             (clk),
        .s_aresetn          (rstn),

        .s_axi_araddr       (r_addr),
        .s_axi_arburst      (2'b01),
        .s_axi_arid         (4'b0),
        .s_axi_arlen        (r_length),
        .s_axi_arsize       (r_size),
        .s_axi_arvalid      (r_req),
        .s_axi_arready      (r_rdy),

        .s_axi_rid          (rid),
        .s_axi_rlast        (ret_last),
        .s_axi_rready       (rready),
        .s_axi_rvalid       (ret_valid),
        .s_axi_rdata        (r_data_AXI),
        .s_axi_rresp        (r_resp),

        .s_axi_awaddr       (w_addr),
        .s_axi_awburst      (2'b01),
        .s_axi_awid         (4'd2),
        .s_axi_awlen        (w_length),
        .s_axi_awready      (w_rdy),
        .s_axi_awsize       (w_size),
        .s_axi_awvalid      (w_req),
        
        .s_axi_bid          (bid),
        .s_axi_bready       (b_ready),
        .s_axi_bvalid       (b_valid),
        .s_axi_bresp        (b_resp),

        .s_axi_wdata        (w_data_AXI),
        .s_axi_wlast        (w_last),
        .s_axi_wready       (w_data_ready),
        .s_axi_wstrb        (w_strb),
        .s_axi_wvalid       (w_data_req)
        
    );

endmodule
