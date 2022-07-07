`timescale 1ns / 1ps
module icache(
    input clk, rstn,
    /* for CPU */
    input valid,                // valid request
    input [31:0] addr,
    //output addr_valid,         // read: addr has been accepted; write: addr and data have been accepted
    output data_valid,          // read: data has returned; write: data has been written in
    output [63:0] r_data_CPU,   // read data to CPU
    /* for AXI */
    // read
    output r_req,               // send read request
    output r_data_ready,
    //output [2:0] r_type,        // read type, 0: 8bit, 1: 16bit, 2: 32bit, 4: cache line
    output [31:0] r_addr,       // start location of read
    input r_rdy,                // AXI signal, means "shake hands success"
    input ret_valid,            // return data is valid
    input ret_last,             // the last returned data
    input [31:0] r_data_AXI     // read data from AXI
    );
    wire[31:0] addr_rbuf;
    wire[3:0] hit, mem_en, tagv_we;
    wire[2047:0] mem_dout;
    wire[511:0] mem_din;
    wire[63:0] mem_we, r_data_mem;
    wire[3:0] way_replace, way_replace_mbuf;
    wire mbuf_we, rdata_sel, fill_finish;
    wire cache_hit, rbuf_we;
    wire way_sel_en;

    assign r_addr = addr_rbuf;
    register#(32) req_buf(
        .clk    (clk),
        .rstn   (rstn),
        .we     (rbuf_we),
        .din    (addr),
        .dout   (addr_rbuf)
    );
    ret_buf_i ret_buf(
        .clk            (clk),
        .r_data_AXI     (r_data_AXI),
        .ret_valid      (ret_valid),
        .ret_last       (ret_last),
        .fill_finish    (fill_finish),
        .mem_din        (mem_din)
    );
    register#(4) miss_buf(
        .clk    (clk),
        .rstn   (rstn),
        .we     (mbuf_we),
        .din    (way_replace),
        .dout   (way_replace_mbuf)
    );
    TagV_memory tagv_mem(
        .clk        (clk),
        .r_addr     (addr),
        .w_addr     (addr_rbuf),
        .we         (tagv_we),
        .hit        (hit),
        .cache_hit  (cache_hit)
    );
    memory cache_memory(
        .clk        (clk),
        .r_addr     (addr),
        .w_addr     (addr_rbuf),
        .mem_din    (mem_din),
        .mem_we     (mem_we),
        .mem_en     (mem_en),
        .mem_dout   (mem_dout)
    );
    way_sel_lru way_sel(
        .clk            (clk),
        .en             (way_sel_en),
        .visit          (hit),
        .lru_way_sel    (way_replace)
    );
    mem_rd_ctrl_i rd_ctrl(
        .addr_rbuf      (addr_rbuf),
        .r_way_sel      (hit),
        .mem_dout       (mem_dout),
        .r_data_AXI     (mem_din),
        .rdata_sel      (rdata_sel),
        .r_data         (r_data_CPU)
    );
    main_FSM_i main_FSM(
        .clk            (clk),
        .rstn           (rstn),
        .valid          (valid),
        .cache_hit      (cache_hit),
        .r_rdy_AXI      (r_rdy),
        .fill_finish    (fill_finish),
        .lru_way_sel    (way_replace_mbuf),
        .mbuf_we        (mbuf_we),
        .rbuf_we        (rbuf_we),
        .rdata_sel      (rdata_sel),
        .way_sel_en     (way_sel_en),
        .mem_we         (mem_we),
        .mem_en         (mem_en),
        .tagv_we        (tagv_we),
        .r_req          (r_req),
        .r_data_ready   (r_data_ready),
        .data_valid     (data_valid)
    );

endmodule
