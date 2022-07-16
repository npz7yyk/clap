module inst_mem(
    input clk,
    input rstn,
    input valid,
    input [31:0] addr,
    output data_valid,
    output [63:0] r_data_CPU
    );
    wire r_req, r_rdy, ret_valid, ret_last, rready;
    wire [3:0] rid;
    wire [31:0] r_addr, r_data_AXI;
    icache cache(
        .clk            (clk),
        .rstn           (rstn),
        .valid          (valid),
        .pc_in           (addr),
        .data_valid     (data_valid),
        .r_data_CPU     (r_data_CPU),
        .r_req          (r_req),
        .r_addr         (r_addr),
        .r_rdy          (r_rdy),
        .ret_valid      (ret_valid),
        .ret_last       (ret_last),
        .r_data_ready   (rready),
        .r_data_AXI     (r_data_AXI)
    );
    AXI_memory main_mem(
        .s_aclk         (clk),
        .s_aresetn      (1'b1),
        .s_axi_araddr   (r_addr),
        .s_axi_arburst  (2'b01),
        .s_axi_arid     (4'b0),
        .s_axi_arlen    (8'd15),
        .s_axi_arsize   (3'b010),
        .s_axi_arvalid  (r_req),
        .s_axi_arready  (r_rdy),

        .s_axi_rid      (rid),
        .s_axi_rlast    (ret_last),
        .s_axi_rready   (rready),
        .s_axi_rvalid   (ret_valid),
        .s_axi_rdata    (r_data_AXI)
        
    );

endmodule
