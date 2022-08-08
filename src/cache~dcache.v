`include "clap_config.vh"
`include "exception.vh"
/* verilator lint_off DECLFILENAME */
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
    input             [6:0] tlb_exception,
    output           [31:0] badv,
    //cacop
    input [            1:0] cacop_code,
    input                   cacop_en,
    output                  cacop_complete,
    output                  cacop_ready,
    //atom load
    input                   is_atom,
    output                  llbit_set,
    //atom store
    input                   llbit,
    output                  llbit_clear
    // diff test
    `ifdef CLAP_CONFIG_DIFFTEST
    ,output            [31:0] vaddr_diff,
    output            [31:0] paddr_diff,
    output            [31:0] data_diff
    `endif

    //,output                  miss_signal
    );
    wire op_rbuf, r_data_sel, wrt_data_sel, cache_hit, data_valid_temp, cache_ready_temp;
    wire fill_finish, way_sel_en, mbuf_we, dirty_data, dirty_data_mbuf;
    wire w_dirty_data, rbuf_we, wbuf_AXI_we, wbuf_AXI_reset, wrt_AXI_finish;
    wire pbuf_we, cacop_en_rbuf, is_atom_rbuf, llbit_rbuf, exp_sel;
    wire [3:0] mem_en, hit, way_replace, way_replace_mbuf, tagv_we, dirty_we, write_type_rbuf, way_visit;
    wire [1:0] cacop_code_rbuf;
    wire [6:0] exception_cache, exception_temp, exception_obuf, exception_mbuf;
    wire [19:0] replace_tag, store_data;
    wire [31:0] r_data_CPU_temp, addr_rbuf, w_data_CPU_rbuf, addr_pbuf, w_addr_mbuf;
    wire [63:0] mem_we, mem_we_normal;
    wire [511:0] w_line_AXI, miss_sel_data, mem_din;
    wire [2047:0] mem_dout;
    wire signed_ext_rbuf, uncache_rbuf, tagv_clear;
    `ifdef CLAP_CONFIG_DIFFTEST
        assign paddr_diff = addr_pbuf;
        register#(64) diff_buffer(
            .clk        (clk),
            .rstn       (rstn),
            .we         (1'b1),
            .din        ({addr_rbuf, w_data_CPU_rbuf}),
            .dout       ({vaddr_diff, data_diff})
        );
    `endif
    
    assign r_addr = uncache_rbuf || cacop_en ? addr_pbuf : {addr_pbuf[31:6], 6'b0};
    assign w_addr = uncache_rbuf || cacop_en ? addr_pbuf : w_addr_mbuf;
    assign badv = addr_rbuf[31:0];
    assign exception_temp = {7{!((cacop_en_rbuf && cacop_code_rbuf != 2'd2) || (op_rbuf && is_atom_rbuf && !llbit_rbuf))}} 
                            & (tlb_exception == `EXP_ADEM ? 
                            tlb_exception : (exception_cache == 0 ? tlb_exception : exception_cache));
    /* exception */
    cache_exception_d exp(
        .addr_rbuf      (addr_rbuf),
        .type_          (write_type_rbuf),
        .cacop_en_rbuf  (cacop_en_rbuf),
        .exception      (exception_cache),
        .is_atom_rbuf   (is_atom_rbuf),
        .llbit_rbuf     (llbit_rbuf),
        .op_rbuf        (op_rbuf)
    );

    /* request buffer*/
    // addr, w_data_CPU, op, write_type
    register#(76) req_buf(
        .clk        (clk),
        .rstn       (rstn),
        .we         (rbuf_we),
        .din        ({signed_ext, addr, w_data_CPU, op, 
                      cacop_en ? 4'b1111 : write_type, uncache, cacop_code, cacop_en, is_atom, llbit}),
        .dout       ({signed_ext_rbuf, addr_rbuf, w_data_CPU_rbuf, op_rbuf, 
                      write_type_rbuf, uncache_rbuf, cacop_code_rbuf, cacop_en_rbuf, is_atom_rbuf, llbit_rbuf})
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
        .bvalid             (b_valid),
        .awvalid            (w_req),
        .awready            (w_rdy),
        .uncache            (uncache_rbuf),
        .wrt_reset          (wbuf_AXI_reset),
        .w_line_mem         (miss_sel_data),
        .wvalid             (w_data_req),
        .wready             (w_data_ready),
        .wlast              (w_last),
        .bready             (b_ready),
        .w_data_AXI         (w_data_AXI),
        .wrt_AXI_finish     (wrt_AXI_finish)
    );

    /* miss buffer */
    // addr to be write, way to be replaced, dirty_data
    register#(44) miss_buf(
        .clk        (clk),
        .rstn       (rstn),
        .we         (mbuf_we),
        .din        ({replace_tag, addr_rbuf[11:6], 6'b0, way_replace, dirty_data, exception_temp}),
        .dout       ({w_addr_mbuf, way_replace_mbuf, dirty_data_mbuf, exception_mbuf})
    );

    /* return buffer */
    ret_buf_d ret_buf(
        .clk                (clk),
        .rstn               (rstn),
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
        .addr_rbuf      (addr_rbuf),
        .tag            (p_addr[31:12]),
        .we             (tagv_we),
        .way_sel        (way_replace),
        .hit            (hit),
        .cache_hit      (cache_hit),
        .replace_tag    (replace_tag)
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
    miss_way_sel_lru u_way_sel(
        .clk            (clk),
        .addr_rbuf      (addr_rbuf),
        .cacop_en_rbuf  (cacop_en_rbuf),
        .cacop_code_rbuf(cacop_code_rbuf),
        .visit          (way_visit),
        .hit            (hit),
        .en             (way_sel_en),
        .way_sel        (way_replace)
    );

    /* mem write control */
    mem_wrt_ctrl_d mem_wrt_ctrl(
        .w_data_CPU         (w_data_CPU_rbuf),
        .w_data_AXI         (w_line_AXI),
        .wrt_data_sel       (wrt_data_sel),
        .mem_din            (mem_din),
        .cacop_en_rbuf      (cacop_en_rbuf),
        .uncache_rbuf       (uncache_rbuf),


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
        .llbit_rbuf         (llbit_rbuf),
        .is_atom_rbuf       (is_atom_rbuf),
        .op_rbuf            (op_rbuf),
        .r_data             (r_data_CPU_temp)
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
        .wrt_AXI_finish     (wrt_AXI_finish),
        .lru_way_sel        (way_replace_mbuf),
        .hit                (hit),
        .mem_we_normal      (mem_we_normal),
        .uncache            (uncache_rbuf),
        .visit_type         (write_type_rbuf),
        .addr_rbuf          (addr_rbuf),
        .exception          (exception),
        .exception_temp     (exception_temp),
        .is_atom_rbuf       (is_atom_rbuf),
        .llbit_rbuf         (llbit_rbuf),

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
        .data_valid         (data_valid_temp),
        .cache_ready        (cache_ready_temp),

        .cacop_code         (cacop_code_rbuf),
        .cacop_en_rbuf      (cacop_en_rbuf),
        .cacop_en           (cacop_en),
        .tagv_clear         (tagv_clear),
        .cacop_complete     (cacop_complete),
        .cacop_ready        (cacop_ready),
        .llbit_set          (llbit_set),
        .llbit_clear        (llbit_clear),
        .exp_sel            (exp_sel),
        
        .dirty_data_ibar    (0)

        //.tlb_exception      (tlb_exception)
    );
    
    register #(41) output_buffer(
        .clk        (clk),
        .rstn       (rstn),
        .we         (1'b1),
        .din        ({r_data_CPU_temp, data_valid_temp, (data_valid_temp || cacop_en_rbuf) ? 
                    (exp_sel ? exception_mbuf : exception_temp) : 7'b0, cache_ready_temp}),
        .dout       ({r_data_CPU, data_valid, exception_obuf, cache_ready})
    );
    reg [6:0] exception_old;
    wire [6:0] exception_new;
    assign exception_new = exception_obuf;
    always @(posedge clk) 
        if(~rstn) exception_old <= 0;
        else exception_old <= exception_new;
    assign exception = ~exception_old & exception_new;
endmodule
