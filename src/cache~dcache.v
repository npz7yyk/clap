module dcache(
    input clk, rstn,
    /* for CPU */
    input                   valid,            
    input                   op,                   
    input                   uncache,
    input            [31:0] addr,
    input            [31:0] p_addr,
    input             [3:0] write_type,     
    input            [31:0] w_data_CPU,  
    input                   signed_ext,       
    output                  data_valid,          
    output                  cache_ready,
    output           [31:0] r_data_CPU,  
    /* for AXI */
    // read
    output                  r_req,              
    output                  r_data_ready,
    output            [2:0] r_size,     
    output            [7:0] r_length,
    output           [31:0] r_addr,      
    input                   r_rdy,                
    input                   ret_valid,         
    input                   ret_last,   
    input            [31:0] r_data_AXI,    
    // write
    output                  w_req,               
    output                  w_data_req,
    output                  w_last,
    output            [2:0] w_size,      
    output            [7:0] w_length,
    output           [31:0] w_addr,       
    output            [3:0] w_strb,       
    output           [31:0] w_data_AXI, 
    input                   w_rdy,                 
    input                   w_data_ready,
    //back
    output                  b_ready,
    input                   b_valid,
    //exception 
    output            [6:0] exception,
    output           [31:0] badv,
    //cacop
    input [4:0] cacop_code,
    input cacop_en
    );
    wire op_rbuf, hit_write, r_data_sel, wrt_data_sel, cache_hit;
    wire fill_finish, way_sel_en, mbuf_we, dirty_data, dirty_data_mbuf;
    wire w_dirty_data, rbuf_we, wbuf_AXI_we, wbuf_AXI_reset, wrt_AXI_finish;
    wire vld, vld_mbuf, pbuf_we, cacop_en_rbuf;
    wire [3:0] mem_en, hit, way_replace, way_replace_mbuf, tagv_we, dirty_we, write_type_rbuf, way_visit, hit_mbuf;
    wire [4:0] cacop_code_rbuf;
    wire [19:0] replace_tag;
    wire [31:0] addr_rbuf, w_data_CPU_rbuf, addr_pbuf, w_addr_mbuf;
    wire [63:0] mem_we, mem_we_normal;
    wire [511:0] w_line_AXI, miss_sel_data, w_line_to_AXI, mem_din;
    wire [2047:0] mem_dout;
    wire signed_ext_rbuf, uncache_rbuf, tagv_clear;

    assign r_addr = uncache_rbuf ? addr_pbuf : {addr_pbuf[31:6], 6'b0};
    assign w_addr = uncache_rbuf ? addr_pbuf : w_addr_mbuf;
    assign badv = addr_rbuf[31:0];
    
    /* exception */
    cache_exception_d exp(
        .addr_rbuf      (addr_rbuf),
        .type_          (write_type_rbuf),
        .exception      (exception)
    );

    /* request buffer*/
    // addr, w_data_CPU, op, write_type
    register#(77) req_buf(
        .clk        (clk),
        .rstn       (rstn),
        .we         (rbuf_we),
        .din        ({signed_ext, addr, w_data_CPU, op, write_type, uncache, cacop_code, cacop_en}),
        .dout       ({signed_ext_rbuf, addr_rbuf, w_data_CPU_rbuf, op_rbuf, write_type_rbuf, uncache_rbuf, cacop_code_rbuf, cacop_en_rbuf})
    );
    /* physical addr buffer */
    register#(32) phy_buf(
        .clk        (clk),
        .rstn       (rstn),
        .we         (pbuf_we),
        .din        (p_addr),
        .dout       (addr_pbuf)
    );

    /* write buffer AXI */
    wrt_buffer_AXI wbuf(
        .clk                (clk),
        .rstn               (rstn),
        .w_buf_we           (wbuf_AXI_we),
        .wready             (w_data_ready),
        .bvalid             (b_valid),
        .awvalid            (w_req),
        .awready            (w_rdy),
        .uncache            (uncache_rbuf),
        .wrt_reset          (wbuf_AXI_reset),
        .w_line_mem         (miss_sel_data),
        .wvalid             (w_data_req),
        .wlast              (w_last),
        .bready             (b_ready),
        .w_data_AXI         (w_data_AXI),
        .wrt_AXI_finish     (wrt_AXI_finish)
    );

    /* miss buffer */
    // addr to be write, way to be replaced, dirty_data, vld
    register#(38) miss_buf(
        .clk        (clk),
        .rstn       (rstn),
        .we         (mbuf_we),
        .din        ({replace_tag, addr_rbuf[11:6], 6'b0, way_replace, dirty_data, vld}),
        .dout       ({w_addr_mbuf, way_replace_mbuf, dirty_data_mbuf, vld_mbuf})
    );

    /* return buffer */
    ret_buf_d ret_buf(
        .clk                (clk),
        .addr_rbuf          (addr_rbuf),
        .wrt_type           (write_type_rbuf),
        .op_rbuf            (op_rbuf),
        .r_data_AXI         (r_data_AXI),
        .w_data_CPU_rbuf    (w_data_CPU_rbuf),
        .ret_valid          (ret_valid),
        .ret_last           (ret_last),
        .uncache_rbuf       (uncache_rbuf),
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
    TagV_memory_d tagv_mem(
        .clk            (clk),
        .tagv_clear     (tagv_clear),
        .r_addr         (addr),
        .w_addr         (addr_pbuf),
        .tag            (p_addr[31:12]),
        .we             (tagv_we),
        .way_sel        (way_replace),
        .hit            (hit),
        .cache_hit      (cache_hit),
        .replace_tag    (replace_tag),
        .replace_vld    (vld)
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
    miss_way_sel_lru way_sel(
        .clk            (clk),
        .addr_rbuf      (addr_rbuf),
        .visit          (way_visit),
        .en             (way_sel_en),
        .way_sel        (way_replace)
    );

    /* mem write control */
    mem_wrt_ctrl_d mem_wrt_ctrl(
        .w_data_CPU         (w_data_CPU_rbuf),
        .w_data_AXI         (w_line_AXI),
        .wrt_data_sel       (wrt_data_sel),
        .mem_din            (mem_din),


        .addr_rbuf          (addr_rbuf),
        .wrt_type           (write_type_rbuf),
        .mem_we_normal      (mem_we_normal),
        .AXI_we             (w_strb)
    );

    /* mem read control */
    mem_rd_ctrl_d mem_rd_ctrl(
        .addr_rbuf          (addr_rbuf),
        .w_data_CPU         (mem_din[31:0]),
        .r_way_sel          (hit),
        .read_type_rbuf     (write_type_rbuf),
        .signed_ext         (signed_ext_rbuf),
        .mem_dout           (mem_dout),
        .uncache_rbuf       (uncache_rbuf),
        .r_data_AXI         (w_line_AXI),
        .r_data_sel         (r_data_sel),
        .cacop_en_rbuf      (cacop_en_rbuf),
        .cacop_code_rbuf    (cacop_code_rbuf),
        .miss_way_sel       (way_replace),
        .miss_sel_data      (miss_sel_data),
        .r_data             (r_data_CPU)
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
        .dirty_data         (dirty_data),
        .dirty_data_mbuf    (dirty_data_mbuf),
        .vld                (vld),
        .vld_mbuf           (vld_mbuf),
        .wrt_AXI_finish     (wrt_AXI_finish),
        .lru_way_sel        (way_replace_mbuf),
        .hit                (hit),
        .mem_we_normal      (mem_we_normal),
        .uncache            (uncache_rbuf),
        .visit_type         (write_type_rbuf),
        .addr_rbuf          (addr_rbuf),

        .way_visit          (way_visit),
        .mbuf_we            (mbuf_we),
        .pbuf_we            (pbuf_we),
        .rbuf_we            (rbuf_we),
        .wbuf_AXI_we        (wbuf_AXI_we),
        .wbuf_AXI_reset     (wbuf_AXI_reset),
        .dirty_we           (dirty_we),
        .way_sel_en         (way_sel_en),
        .rdata_sel          (r_data_sel),
        .wrt_data_sel       (wrt_data_sel),
        .mem_we             (mem_we),
        .mem_en             (mem_en),
        .tagv_we            (tagv_we),
        .w_dirty_data       (w_dirty_data),
        .r_req              (r_req),
        .w_req              (w_req),
        .r_length           (r_length),
        .w_length           (w_length),
        .r_size             (r_size),
        .w_size             (w_size),
        .r_data_ready       (r_data_ready),
        .data_valid         (data_valid),
        .cache_ready        (cache_ready),

        .cacop_code         (cacop_code_rbuf),
        .cacop_en           (cacop_en_rbuf),
        .tagv_clear         (tagv_clear)
    );
endmodule
