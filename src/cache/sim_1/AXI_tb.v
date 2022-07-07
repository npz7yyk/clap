`timescale 1ns / 1ps
module AXI_tb(
    output [31:0] rdata
    );
    reg clk;
    initial begin 
        clk = 0;
        forever begin
            #1 clk = ~clk;
        end
    end
    //reg [3:0] arid;
    wire [31:0] araddr;
    //reg [7:0] arlen;
    //reg [2:0] arsize;
    // arbrust = 2'b01
    wire arvalid;
    wire arready;
    wire [3:0] rid;
    
    wire rlast;
    wire rvalid;
    wire rready;
    assign rready = 1;
    assign araddr = 32'b0;
    assign arvalid = 1;
    AXI_memory mem(
        .s_aclk         (clk),
        .s_aresetn      (1'b1),
        .s_axi_araddr   (araddr),
        .s_axi_arburst  (2'b01),
        .s_axi_arid     (4'b0),
        .s_axi_arlen    (8'd15),
        .s_axi_arsize   (3'b010),
        .s_axi_arvalid  (arvalid),
        .s_axi_arready  (arready),

        .s_axi_rid     (rid),
        .s_axi_rlast    (rlast),
        .s_axi_rready   (rready),
        .s_axi_rvalid   (rvalid),
        .s_axi_rdata    (rdata)
    );

endmodule
