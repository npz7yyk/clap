`include "clap_config.vh"

/* verilator lint_off DECLFILENAME */
module main_FSM_d(
    input clk, 
    input rstn,
    output reg visit_mode,
    input op,
    // avalid
    input i_avalid,
    input d_avalid,
    // aready
    output reg i_aready,
    output reg d_aready,
    // valid
    output reg i_valid,
    output reg d_valid,
    // AXI signal
    output arvalid_AXI,
    input arready_AXI,
    input rvalid_AXI,
    output rready_AXI,
    output awvalid_AXI,
    input awready_AXI,
    // ready
    input i_ready,
    input d_ready,
    // cache status
    input uncache,

    input [3:0] hit,
    input cache_hit,
    input dirty_data,
    input dirty_data_mbuf,
    input wrt_AXI_finish,
    input ret_buf_fill_finish,
    input [63:0] mem_we_normal,
    output reg [63:0] mem_we,
    output reg [3:0] mem_en,
    output reg [3:0] dirty_we,
    output reg wdata_dirty,

    output reg rbuf_we,
    output reg mbuf_we,
    output reg wbuf_AXI_we,
    output reg rdata_from_mem,
    output reg way_sel_en,
    output reg [3:0] way_visit,
    output reg [7:0] wlength,
    output reg [2:0] wsize,

    );
    localparam 
        IDLE        = 3'd0,
        LOOKUP      = 3'd1,
        MISS        = 3'd2,
        REPLACE     = 3'd3,
        REFILL      = 3'd4,
        WAIT_WRITE  = 3'd5,
        EXTRA_READY = 3'd6;
    
    reg i_set, d_set;
    reg [2:0] crt, nxt;

    always @(posedge clk) begin
        if(!rstn) crt <= IDLE;
        else crt <= nxt;
    end

    always @(posedge clk) begin
        if(i_set) visit_mode <= 1'b0;
        else if(d_set) d_set <= 1'b1;
    end

    always @(*) begin
        case(crt)
        IDLE: begin
            if(i_avalid || d_avalid) nxt = LOOKUP;
            else nxt = IDLE;
        end
        LOOKUP: begin
            if(visit_mode == 1'b1) begin
                if(i_uncache) nxt = REPLACE;
                else begin
                    if(cache_hit) nxt = IDLE;
                    else nxt = REPLACE;
                end
            end
            else begin
                if(d_uncache) begin
                    if(op == 1'b0) nxt = REPLACE;
                    else nxt = MISS;
                end
                else begin
                    if(cache_hit) nxt = IDLE;
                    else begin
                        if(dirty_data) nxt = MISS;
                        else nxt = REPLACE;
                    end
                end
            end
        end
        MISS: begin
            if(awready_AXI) begin
                if(uncache) nxt = WAIT_WRITE;
                else nxt = REPLACE;
            end
            else nxt = MISS;
        end
        REPLACE: begin
            if(arready_AXI) nxt = REFILL;
            else nxt = REPLACE;
        end
        REFILL: begin
            if(ret_buf_fill_finish) nxt = WAIT_WRITE;
            else nxt = REFILL;
        end
        WAIT_WRITE: begin
            if(uncache) begin
                if(wrt_AXI_finish || op == 1'b0) nxt = EXTRA_READY;
                else nxt = WAIT_WRITE;
            end
            else begin
                if(wrt_AXI_finish || op == 1'b0 || !dirty_data_mbuf) nxt = EXTRA_READY;
                else nxt = WAIT_WRITE;
            end
        end
        EXTRA_READY: begin
            nxt = IDLE;
        end
        default: nxt = IDLE;
        endcase
    end

    always @(*) begin
        rbuf_we = 0;
        mbuf_we = 0;
        d_ready = 0;
        i_ready = 0;
        rdata_from_mem = 0;
        i_set = 0;
        d_set = 0;
        way_sel_en = 0;
        way_visit = 0;
        mem_en = 0;
        mem_we = 0;
        awvalid_AXI = 0;
        case(crt)
        IDLE: begin
            if(i_avalid || d_avalid) begin
                rbuf_we = 1;
                if(d_avalid) begin
                    d_ready = 1;
                    d_set = 1;
                end
                else if(i_avalid) begin
                    i_ready = 1;
                    i_set = 1;
                end
            end
        end
        LOOKUP: begin
            rdata_from_mem = 1;
            mbuf_we = 1;
            wbuf_AXI_we = 1;
            way_sel_en = cache_hit;
            way_visit = hit;
            if(!uncache) begin
                if(cache_hit) begin
                    i_valid = !visit_mode;
                    d_valid = visit_mode;
                end
            end
            if(op == 1'b1) begin
                mem_en = hit;
                mem_we = mem_we_normal;
                dirty_we = hit;
                wdata_dirty = 1;
            end
        end
        MISS: begin
            awvalid_AXI = 1;
        end
    end
        
endmodule
