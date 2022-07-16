module icache
#(COOKIE_WIDHT = 32)(
    input clk, rstn,
    /* for CPU */
    input valid,                // valid request
    input flush,
    input [31:0] pc_in,
    input [31:0] p_addr,
    input [COOKIE_WIDHT-1:0] cookie_in,
    //output addr_valid,         // read: addr has been accepted; write: addr and data have been accepted
    output data_valid,          // read: data has returned; write: data has been written in
    output [63:0] r_data_CPU,   // read data to CPU
    output [31:0] pc_out,
    output [COOKIE_WIDHT-1:0] cookie_out,
    output cache_ready,
    /* for AXI */
    // read
    output r_req,               // send read request
    output r_data_ready,
    //output [2:0] r_type,        // read type, 0: 8bit, 1: 16bit, 2: 32bit, 4: cache line
    output [31:0] r_addr,       // start location of read
    input r_rdy,                // AXI signal, means "shake hands success"
    input ret_valid,            // return data is valid
    input ret_last,             // the last returned data
    input [31:0] r_data_AXI,     // read data from AXI

    output [6:0] exception
    );
    wire[31+COOKIE_WIDHT:0] addr_rbuf;
    wire [31:0] addr_pbuf;
    wire[3:0] hit, mem_we, tagv_we, tagv, way_visit;
    wire[2047:0] mem_dout;
    wire[511:0] mem_din;
    wire[3:0] way_replace, way_replace_mbuf;
    wire mbuf_we, rdata_sel, fill_finish, pbuf_we;
    wire cache_hit, rbuf_we;
    wire way_sel_en;

    assign r_addr = {addr_pbuf[31:6], 6'b0};
    assign {cookie_out,pc_out} = addr_rbuf;
    reg valid_reg;
    always @(posedge clk)
        if(flush) valid_reg <= 0;
        else if(rbuf_we) valid_reg <= valid;
    register#(32+COOKIE_WIDHT) req_buf(
        .clk    (clk),
        .rstn   (rstn),
        .we     (rbuf_we),
        .din    ({cookie_in,pc_in}),
        .dout   (addr_rbuf)
    );
    register#(32) phy_buf(
        .clk        (clk),
        .rstn       (rstn),
        .we         (pbuf_we),
        .din        (p_addr),
        .dout       (addr_pbuf)
    );

    cache_excption_i exp_cope(
        .addr_rbuf      (addr_rbuf[31:0]),
        .exception      (exception)
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
        .r_addr     (pc_in),
        .w_addr     (addr_pbuf),
        .tag        (p_addr[31:12]),
        .we         (tagv_we),
        .hit        (hit),
        .cache_hit  (cache_hit)
    );
    inst_memory cache_memory(
        .clk        (clk),
        .r_addr     (pc_in),
        .w_addr     (addr_rbuf[31:0]),
        .mem_din    (mem_din),
        .mem_we     (mem_we),
        .mem_dout   (mem_dout)
    );
    miss_way_sel_lru way_sel(
        .clk            (clk),
        .addr_rbuf      (addr_rbuf[31:0]),
        .visit          (way_visit),
        .en             (way_sel_en),
        .way_sel        (way_replace)
    );
    
    mem_rd_ctrl_i rd_ctrl(
        .addr_rbuf      (addr_rbuf[31:0]),
        .r_way_sel      (hit),
        .mem_dout       (mem_dout),
        .r_data_AXI     (mem_din),
        .rdata_sel      (rdata_sel),
        .r_data         (r_data_CPU)
    );
    wire data_valid_oIzprAXodb8T;
    main_FSM_i main_FSM(
        .clk            (clk),
        .rstn           (rstn),
        .valid          (valid),
        .cache_hit      (cache_hit),
        .r_rdy_AXI      (r_rdy),
        .fill_finish    (fill_finish),
        .lru_way_sel    (way_replace_mbuf),
        .hit            (hit),
        .way_visit      (way_visit),
        .mbuf_we        (mbuf_we),
        .pbuf_we        (pbuf_we),
        .rbuf_we        (rbuf_we),
        .rdata_sel      (rdata_sel),
        .way_sel_en     (way_sel_en),
        .mem_we         (mem_we),
        .tagv_we        (tagv_we),
        .r_req          (r_req),
        .r_data_ready   (r_data_ready),
        .data_valid     (data_valid_oIzprAXodb8T),
        .cache_ready    (cache_ready)
    );

    assign data_valid = data_valid_oIzprAXodb8T&valid_reg;
endmodule