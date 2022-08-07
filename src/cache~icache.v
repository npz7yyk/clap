`include "clap_config.vh"
`include "exception.vh"
/* verilator lint_off DECLFILENAME */
module icache
#(COOKIE_WIDHT = 32)(
    input clk, rstn,
    /* for CPU */
    input valid,                // valid request
    input flush,
    input [31:0] pc_in,
    input [31:0] p_addr,
    input [COOKIE_WIDHT-1:0] cookie_in,
    input uncache,
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
    output [7:0] r_length,
    output [31:0] r_addr,       // start location of read
    input r_rdy,                // AXI signal, means "shake hands success"
    input ret_valid,            // return data is valid
    input ret_last,             // the last returned data
    input [31:0] r_data_AXI,     // read data from AXI
    output [31:0] badv,
    output [6:0] exception,

    input cacop_en,
    input [1:0] cacop_code,
    output cacop_ready,
    output cacop_complete,

    input [6:0] tlb_exception
    );
    wire[31+COOKIE_WIDHT:0] addr_rbuf;
    wire [31:0] addr_pbuf;
    wire[3:0] hit, mem_we, tagv_we, way_visit;
    wire[2047:0] mem_dout;
    wire[511:0] mem_din;
    wire[3:0] way_replace, way_replace_mbuf;
    wire [1:0] cacop_code_rbuf;
    wire mbuf_we, rdata_sel, fill_finish, pbuf_we;
    wire cache_hit, rbuf_we;
    wire way_sel_en, cacop_en_rbuf;
    wire uncache_rbuf, tagv_clear;


    wire [6:0] exception_temp, exception_normal, exception_mbuf;
    wire exp_sel;
    assign r_addr = uncache_rbuf ? {addr_pbuf[31:3], 3'b0} : {addr_pbuf[31:6], 6'b0};
    assign exception_normal = (exception_temp == 0 || tlb_exception == `EXP_ADEF)? tlb_exception : exception_temp;
    assign badv = exception != 0 ? addr_rbuf[31:0] : 0;
    assign {cookie_out,pc_out} = addr_rbuf;
    assign exception = exp_sel ? exception_mbuf : exception_normal;
    reg valid_reg;
    always @(posedge clk)
        if(flush) valid_reg <= 0;
        else if(rbuf_we) valid_reg <= valid;
    register#(36+COOKIE_WIDHT) req_buf(
        .clk    (clk),
        .rstn   (rstn),
        .we     (rbuf_we),
        .din    ({cookie_in,pc_in, uncache, cacop_code, cacop_en}),
        .dout   ({addr_rbuf, uncache_rbuf, cacop_code_rbuf, cacop_en_rbuf})
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
        .cacop_en_rbuf  (cacop_en_rbuf),
        .exception      (exception_temp)
    );
    
    ret_buf_i ret_buf(    
        .clk            (clk),
        .r_data_AXI     (r_data_AXI),
        .ret_valid      (ret_valid),
        .ret_last       (ret_last),
        .fill_finish    (fill_finish),
        .mem_din        (mem_din)
    );
    register#(11) miss_buf(
        .clk    (clk),
        .rstn   (rstn),
        .we     (mbuf_we),
        .din    ({way_replace, exception_normal}),
        .dout   ({way_replace_mbuf, exception_mbuf})
    );
    TagV_memory tagv_mem(
        .clk        (clk),
        .r_addr     (pc_in),
        .w_addr     (addr_pbuf),
        .addr_rbuf  (addr_rbuf[31:0]),
        .tag        (p_addr[31:12]),
        .we         (tagv_we),
        .tagv_clear (tagv_clear),
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

    miss_way_sel_lru u_way_sel(
        .clk            (clk),
        .addr_rbuf      (addr_rbuf[31:0]),
        .cacop_en_rbuf  (cacop_en_rbuf),
        .cacop_code_rbuf(cacop_code_rbuf),
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
        .uncache_rbuf   (uncache_rbuf),
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
        .cache_ready    (cache_ready),
        .cacop_ready    (cacop_ready),
        .cacop_complete (cacop_complete),
        .addr_rbuf      (addr_rbuf[31:0]),
        .cacop_en_rbuf  (cacop_en_rbuf),

        .uncache        (uncache_rbuf),
        .r_length       (r_length),
        .cacop_en       (cacop_en),
        .cacop_code     (cacop_code_rbuf),
        .tagv_clear     (tagv_clear),
        .exception      (exception),
        .exp_sel        (exp_sel)
    );

    assign data_valid = data_valid_oIzprAXodb8T&valid_reg;
endmodule
