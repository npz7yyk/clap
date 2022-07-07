`timescale 1ns / 1ps

module cache(
    input clk, rstn,
    /* for CPU */
    input valid,                // valid request
    input op,                   // write: 1, read: 0
    input [5:0] index,          // virtual addr[11:4]
    input [19:0] tag,           // physical addr[31:12]
    input [5:0] offset,         // bank offset:[3:2], byte offset[1:0]
    input [3:0] write_type,        // byte write enable
    input [31:0] w_data_CPU,    // write data
    output addr_valid,          // read: addr has been accepted; write: addr and data have been accepted
    output data_valid,          // read: data has returned; write: data has been written in
    output [31:0] r_data_CPU,   // read data to CPU
    /* for AXI */
    // read
    output r_req,               // send read request
    output [2:0] r_type,        // read type, 0: 8bit, 1: 16bit, 2: 32bit, 4: cache line
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
    parameter WRITE = 1;
    parameter READ = 0;
    /* --------declaration------ */
    wire [31:0] addr, addr_reqbuf, w_addr_wbuf, addr_miss, mem_w_addr, mem_r_addr;
    wire [31:0] w_data_CPU_reqbuf;
    wire [3:0] way_sel;
    wire [3:0] hit, mem_en_reqbuf, mem_en_wbuf, mem_en_mbuf, mem_en;
    wire [63:0] mem_we_wbuf, mem_we_reqbuf, mem_we_mbuf, mem_we;
    wire [511:0] mem_din_wbuf, mem_din_miss, mem_din_reqbuf;
    wire [511:0] w_data_AXI_all, r_data_AXI_all;
    wire [511:0] data_new, mem_din;
    wire [2047:0] mem_dout;
    wire dirty_update, dirty_data, drity_en;
    wire cache_hit;
    wire wbuf_oe, replace_en, refill_en;
    wire hit_write;
    wire op_reqbuf, op_miss;
    wire write_buf_forwarding;
    wire miss_buffer_we, miss_buf_rstn;
    wire gre_mat_en;

    /* ------operation------ */
    assign addr = {tag, index, offset};
    request_buffer request_buf(
        .clk                (clk),
        .rstn               (rstn),
        .valid              (valid),
        .write_type         (write_type),
        .w_data_CPU         (w_data_CPU),
        .addr               (addr),
        .op                 (op),
        .hit                (hit),
        .w_data_CPU_reqbuf  (w_data_CPU_reqbuf),
        .addr_reqbuf        (addr_reqbuf),
        .op_reqbuf          (op_reqbuf),
        .mem_we_reqbuf      (mem_we_reqbuf),
        .mem_en_reqbuf      (mem_en_reqbuf),
        .mem_din_reqbuf     (mem_din_reqbuf)
    );
    TagV_memory tagv_mem(
        .clk        (clk),
        .r_addr     (addr),
        .w_addr     (),
        .we         (),
        .hit        (hit),
        .cache_hit  (cache_hit)
    );
    mux2_1#(4) cache_mem_en(
        .din1   (mem_en_wbuf),
        .din2   (mem_en_mbuf),
        .sel    ({wbuf_oe, refill_en}),
        .dout   (mem_en)
    );
    mux2_1#(64) cache_mem_we(
        .din1   (mem_we_wbuf),
        .din2   ({64{1'b1}}),
        .sel    ({wbuf_oe, refill_en}),
        .dout   (mem_we)
    );
    mux2_1#(512) cache_mem_w_data(
        .din1   (mem_din_wbuf),
        .din2   (r_data_AXI_all),
        .sel    ({wbuf_oe, refill_en}),
        .dout   (mem_din)
    );
    mux2_1#(32) cache_mem_w_addr(
        .din1   (w_addr_wbuf),
        .din2   (addr_reqbuf),
        .sel    ({wbuf_oe, refill_en}),
        .dout   (mem_w_addr)
    );
    mux2_1#(32) cache_mem_r_addr(
        .din1   (addr),
        .din2   (addr_reqbuf),
        .sel    ({valid, replace_en}),
        .dout   (mem_r_addr)
    );
    memory cache_mem(
        .clk        (clk),
        .r_addr     (mem_r_addr),
        .w_addr     (mem_w_addr),
        .mem_din    (mem_din),
        .mem_we     (mem_we),
        .mem_en     (mem_en),
        .mem_dout   (mem_dout)
    );
    mem_rd_ctrl mr_ctrl(
        .bank_sel       (addr_reqbuf[5:2]),
        .mem_dout       (mem_dout),
        .mem_din        (mem_din_wbuf[31:0]),
        .hit            (hit),
        .way_sel        (way_sel),
        .forwarding     (write_buf_forwarding),
        .r_data         (r_data_CPU),
        .w_data_AXI_all (w_data_AXI_all)
    );
    reg_file dirty_table(
        .clk    (clk),
        .we     (hit && {4{hit_write}}),
        .re     (way_sel),
        .r_addr (addr_reqbuf[11:6]),
        .w_addr (w_addr_wbuf[11:6]), 
        .w_data (1),
        .r_data (dirty_r_data)
    );
    /* write buffer */
    // addr32, mem_din512, mem_we64, mem_en8
    register#(612) write_buffer(
        .clk    (clk),
        .rstn   (wbuf_oe),
        .we     (hit_write),
        .din    ({addr_reqbuf, mem_din_reqbuf, mem_we_reqbuf, mem_en_reqbuf}),
        .dout   ({w_addr_wbuf, mem_din_wbuf, mem_we_wbuf, mem_en_wbuf})
    );
    /* miss record */
    miss_buffer miss_buf(
        .clk            (clk),
        .way_rstn       (rstn),
        .way_we         (miss_buf_we),
        .way_din        (way_sel),
        .mem_en_mbuf    (mem_en_mbuf),
        .data_num_we    (ret_valid),
        .data_num_rstn  (miss_buf_rstn),
        .mem_we_mbuf    (mem_we_mbuf)
    );
    way_sel_lru miss_sel(
        .clk            (clk),
        .en             (gre_mat_en),
        .visit          (hit),
        .lru_way_sel    (way_sel)
    );
    write_hazard wr_forwarding(
        .clk        (clk),  
        .op         (op),
        .op_store   (op_reqbuf),
        .addr       (addr),
        .addr_store (addr_reqbuf),
        .forwarding (write_buf_forwarding)
    );
    main_FSM mainfsm(
        .clk            (clk),
        .rstn           (rstn),
        .valid          (valid),
        .cache_hit      (cache_hit),
        .w_rdy_AXI      (w_rdy_AXI),
        .r_rdy_AXI      (r_rdy_AXI),
        .ret_valid      (ret_valid),
        .ret_last       (ret_last),
        .op             (op_reqbuf),
        .hit_write      (hit_write),
        .miss_buf_we    (miss_buf_we),
        .miss_buf_rstn  (miss_buf_rstn),
        .data_valid     (data_valid),
        .addr_valid     (addr_valid),
        .gre_mat_en     (gre_mat_en),
        .replace_en     (replace_en),
        .refill_en      (refill_en)
    );
    write_FSM writefsm(
        .clk        (clk),
        .rstn       (rstn),
        .hit_write  (hit_write),
        .out_valid  (wbuf_oe),
        .dirty_we   (dirty_we)
    );
endmodule
