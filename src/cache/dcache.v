`timescale 1ns / 1ps

module dcache(
    input clk, rstn,
    /* for CPU */
    input valid,                // valid request
    input op,                   // write: 1, read: 0
    input [31:0] addr,
    input [3:0] write_type,     // byte write enable
    input [31:0] w_data_CPU,    // write data
    //output addr_valid,          // read: addr has been accepted; write: addr and data have been accepted
    output data_valid,          // read: data has returned; write: data has been written in
    output [31:0] r_data_CPU,   // read data to CPU
    /* for AXI */
    // read
    output r_req,               // send read request
    output r_data_ready,
    //output [2:0] r_type,        // read type, 0: 8bit, 1: 16bit, 2: 32bit, 4: cache line
    output [31:0] r_addr,       // start location of read
    input r_rdy,                // AXI signal, means "shake hands success"
    input ret_valid,            // return data is valid
    input ret_last,             // the last returned data
    input [31:0] r_data_AXI,    // read data from AXI
    // write
    output w_req,               // send write request
    output [2:0] w_type,        // write type, 0: 8bit, 1: 16bit, 2: 32bit, 4: cache line
    output [31:0] w_addr,       // start location of write
    output [3:0] w_strb,        // byte mask, valid when type is 0, 1, 2
    output [31:0] w_data_AXI,   // write data
    input w_rdy                 // AXI signal, means "shake hands success"
    );
    wire op_rbuf, hit_write, r_data_sel, wrt_data_sel, cache_hit;
    wire wbuf_AXI_we, fill_finish, way_sel_en, mbuf_we, dirty_data;
    wire w_dirty_data;
    wire [3:0] mem_en, hit, way_replace, way_replace_mbuf, tagv_we, dirty_we;
    wire [31:0] addr_rbuf, w_data_CPU_rbuf;
    wire [63:0] mem_we, mem_we_normal;
    wire [511:0] r_line_AXI, w_line_AXI, miss_sel_data, w_line_to_AXI, mem_din;
    wire [2047:0] mem_dout;

    /* request buffer*/
    // addr, w_data_CPU, op
    register#(65) req_buf(
        .clk        (clk),
        .rstn       (rstn),
        .we         (valid),
        .din        ({addr, w_data_CPU, op}),
        .dout       ({addr_rbuf, w_data_CPU_rbuf, op_rbuf})
    );

    /* write buffer AXI */
    register#(512) wrt_buf_AXI(
        .clk        (clk),
        .rstn       (rstn),
        .we         (wbuf_AXI_we),
        .din        (miss_sel_data),
        .dout       (w_line_to_AXI)
    );

    /* miss buffer */
    // way to be replaced, dirty data
    register#(4) miss_buf(
        .clk        (clk),
        .rstn       (rstn),
        .we         (mbuf_we),
        .din        (way_replace),
        .dout       (way_replace_mbuf)
    );

    /* return buffer */
    ret_buf_d ret_buf(
        .clk                (clk),
        .addr_rbuf          (addr_rbuf),
        .wrt_type           (write_type),
        .op_rbuf            (op_rbuf),
        .r_data_AXI         (r_data_AXI),
        .w_data_CPU_rbuf    (w_data_CPU_rbuf),
        .ret_valid          (ret_valid),
        .ret_last           (ret_last),
        .fill_finish        (fill_finish),
        .w_data_AXI         (w_line_AXI)
    );

    /* cache memory */
    memory cache_mem(
        .clk            (clk),
        .r_addr         (addr),
        .w_addr         (addr_rbuf),
        .mem_din        (mem_din),
        .mem_we         (mem_we),
        .mem_en         (mem_en),
        .mem_dout       (mem_dout)
    );
    
    /* TagV list */
    TagV_memory tagv_mem(
        .clk            (clk),
        .r_addr         (addr),
        .w_addr         (addr_rbuf),
        .we             (tagv_we),
        .hit            (hit),
        .cache_hit      (cache_hit)
    );

    /* dirty table */
    reg_file dirty_table(
        .clk        (clk),
        .we         (dirty_we),
        .re         (way_replace),
        .r_addr     (addr_rbuf[11:6]),
        .w_addr     (addr_rbuf[11:6]),
        .w_data     (w_dirty_data),
        .r_data     (dirty_data)
    );

    /* miss way sel */
    way_sel_lru way_sel(
        .clk            (clk),
        .en             (way_sel_en),
        .visit          (hit),
        .lru_way_sel    (way_replace)
    );

    /* mem write control */
    mem_wrt_ctrl_d mem_wrt_ctrl(
        .w_data_CPU         (w_data_CPU_rbuf),
        .w_data_AXI         (w_line_AXI),
        .wrt_data_sel       (wrt_data_sel),
        .mem_din            (mem_din),

        .addr_rbuf          (addr_rbuf),
        .wrt_type           (write_type),
        .mem_we_normal      (mem_we_normal)
    );

    /* mem read control */
    mem_rd_ctrl_d mem_rd_ctrl(
        .addr_rbuf      (addr_rbuf),
        .r_way_sel      (hit),
        .mem_dout       (mem_dout),
        .r_data_AXI     (r_line_AXI),
        .r_data_sel     (r_data_sel),
        .miss_way_sel   (way_replace),
        .way_data       (r_way_data),
        .miss_sel_data  (miss_sel_data),
        .r_data         (r_data_CPU)
    );

    /* main FSM */
    main_FSM_d main_FSM(
        .clk                (clk),
        .rstn               (rstn),
        .valid              (valid),
        .op                 (op_rbuf),
        .cache_hit          (cache_hit),
        .r_rdy_AXI          (r_rdy),
        .w_rdy_AXI          (w_rdy),
        .fill_finish        (fill_finish),
        .lru_way_sel        (way_replace_mbuf),
        .hit                (hit),
        .mem_we_normal      (mem_we_normal),
        .mbuf_we            (mbuf_we),
        .wbuf_AXI_we        (wbuf_AXI_we),
        .way_sel_en         (way_sel_en),
        .rdata_sel          (r_data_sel),
        .wrt_data_sel       (wrt_data_sel),
        .mem_we             (mem_we),
        .mem_en             (mem_en),
        .tagv_we            (tagv_we),
        .r_req              (r_req),
        .w_req              (w_req),
        .r_data_ready       (r_data_ready),
        .data_valid         (data_valid)
    );
endmodule
