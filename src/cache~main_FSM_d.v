module main_FSM_d(
    input clk, 
    input rstn,
    input valid,
    input op,
    input uncache,
    input cache_hit,
    input r_rdy_AXI,
    input w_rdy_AXI,
    input fill_finish,
    input dirty_data,
    input dirty_data_mbuf,
    input vld,
    input vld_mbuf,
    input wrt_AXI_finish,
    input [3:0] lru_way_sel,
    input [3:0] hit,
    input [63:0] mem_we_normal,
    input [3:0] visit_type,
    input [31:0] addr_rbuf,
    input [6:0] exception,

    output reg [3:0] way_visit,
    output reg mbuf_we,
    output reg rbuf_we,
    output reg pbuf_we,
    output reg wbuf_AXI_we,
    output reg wbuf_AXI_reset,
    output reg way_sel_en,
    output reg rdata_sel,
    output reg wrt_data_sel,
    output reg [63:0] mem_we,
    output reg [3:0] mem_en,
    output reg [3:0] tagv_we,
    output reg w_dirty_data,
    output reg [3:0] dirty_we,

    output reg r_req,
    output reg r_data_ready,
    output reg w_req,
    output reg [7:0] r_length,
    output reg [2:0] r_size,
    output reg [7:0] w_length,
    output reg [2:0] w_size,

    output reg data_valid,
    output reg cache_ready,

    input [4:0] cacop_code,
    input cacop_en,
    output reg tagv_clear,

    input [6:0] tlb_exception
    );
    parameter IDLE          = 6'b000001;
    parameter LOOKUP        = 6'b000010;
    parameter MISS          = 6'b000100;
    parameter REPLACE       = 6'b001000;
    parameter REFILL        = 6'b010000;
    parameter WAIT_WRITE    = 6'b100000;

    parameter READ          = 1'd0;
    parameter WRITE         = 1'd1;

    parameter BYTE          = 4'b0001;
    parameter HALF          = 4'b0011;
    parameter WORD          = 4'b1111;

    parameter STORE_TAG         = 2'b00;
    parameter INDEX_INVALIDATE  = 2'b01;
    parameter HIT_INVALIDATE    = 2'b10;

    parameter DCACHE_OP = 3'b001;
    parameter ICACHE_OP = 3'b000;


    reg [2:0] un_visit_type;
    always @(*) begin
        case(visit_type)
        BYTE: un_visit_type = 3'b000;
        HALF: un_visit_type = 3'b001;
        WORD: un_visit_type = 3'b010;
        default: un_visit_type = 3'b000;
        endcase
    end
    reg [3:0] tagv_we_inst;
    always @(*) begin
        case(addr_rbuf[1:0])
        2'd0: tagv_we_inst = 4'b0001;
        2'd1: tagv_we_inst = 4'b0010;
        2'd2: tagv_we_inst = 4'b0100;
        2'd3: tagv_we_inst = 4'b1000;
        endcase
    end

    reg[5:0] crt, nxt;

    always @(posedge clk) begin
        if(!rstn) crt <= IDLE;
        else crt <= nxt;
    end

    always @(*) begin
        case(crt)
        IDLE: begin
            if(valid) nxt = LOOKUP;
            else nxt = IDLE;
        end
        LOOKUP: begin
            // check instruction
            if(exception != 0 || tlb_exception != 0) nxt = IDLE;
            else if(cacop_en && cacop_code == {STORE_TAG, DCACHE_OP}) begin 
                if(valid) nxt = LOOKUP;
                else nxt = IDLE;
            end 

            else if(cacop_en && cacop_code == {INDEX_INVALIDATE, DCACHE_OP}) begin 
                if(dirty_data) nxt = MISS;
                else begin
                    if(valid) nxt = LOOKUP;
                    else nxt = IDLE;
                end
            end

            else if(cacop_en && cacop_code == {HIT_INVALIDATE, DCACHE_OP}) begin
                if(cache_hit && dirty_data) nxt = MISS;
                else begin
                    if(valid) nxt = LOOKUP;
                    else nxt = IDLE;
                end
            end

            // check uncache
            else if(uncache) begin
                if(op == READ) nxt = REPLACE;
                else nxt = MISS;
            end

            // check cache_hit
            else if(cache_hit) begin
                if(valid) nxt = LOOKUP;
                else nxt = IDLE;
            end

            // all not
            else begin
                if(op == WRITE && dirty_data && vld) nxt = MISS;
                else nxt = REPLACE;
            end
        end
        MISS: begin
            if(w_rdy_AXI) begin
                if(uncache || (cacop_en && (cacop_code == 5'b01001 || cacop_code == 5'b10001))) nxt = WAIT_WRITE;
                else nxt = REPLACE;
            end
            else nxt = MISS;
        end
        REPLACE: begin
            if(r_rdy_AXI) nxt = REFILL;
            else nxt = REPLACE;
        end
        REFILL: begin
            if(fill_finish) begin
                nxt = WAIT_WRITE;
            end
            else nxt = REFILL;
        end
        WAIT_WRITE: begin
            if(cacop_en) begin
                if(wrt_AXI_finish) begin
                    if(valid) nxt = LOOKUP;
                    else nxt = IDLE;
                end
                else nxt = WAIT_WRITE;
            end
            else if(uncache && (wrt_AXI_finish || op == READ) || 
              !uncache && (wrt_AXI_finish || op == READ || !dirty_data_mbuf || !vld_mbuf)) begin
                if(valid) nxt = LOOKUP;
                else nxt = IDLE;
            end
            else nxt = WAIT_WRITE;
        end
        default: nxt = IDLE;
        endcase
    end
    
    always @(*)begin
        mbuf_we = 0;    wbuf_AXI_we = 0;    mem_we = 0;     mem_en = 0;
        rdata_sel = 0;  wrt_data_sel = 0;   tagv_we = 0;
        r_req = 0;      w_req = 0;          data_valid = 0; dirty_we = 0; 
        w_dirty_data = 0;                   r_data_ready = 0; 
        rbuf_we = 0;    way_sel_en = 0;     wbuf_AXI_reset = 0;
        way_visit = 0;  cache_ready = 0;    pbuf_we = 0;
        r_size = 3'b010;                    w_size = 3'b010;
        r_length = 8'd15;                   w_length = 8'd15;
        tagv_clear = 0;
        case(crt)
        IDLE: begin
            rbuf_we     = 1;
            cache_ready = 1;
        end
        LOOKUP: begin
            if(exception == 0 && tlb_exception == 0) begin
                rdata_sel       = 1;
                wrt_data_sel    = 1;
                pbuf_we         = 1;
                if(cacop_en && cacop_code == {STORE_TAG, DCACHE_OP}) begin
                    tagv_clear          = 1;
                    tagv_we             = tagv_we_inst;
                    dirty_we            = tagv_we_inst;
                    w_dirty_data        = 1'b0;
                    data_valid          = 1;
                end 
                else if(cacop_en && cacop_code == {INDEX_INVALIDATE, DCACHE_OP}) begin
                    tagv_clear          = 1;
                    tagv_we             = tagv_we_inst;
                    dirty_we            = tagv_we_inst;
                    w_dirty_data        = 1'b0;
                    if(!dirty_data) begin
                        data_valid      = 1;
                        rbuf_we         = 1;
                        wbuf_AXI_reset  = 1;
                        cache_ready     = 1;
                    end

                end
                else if(cacop_en && cacop_code == {HIT_INVALIDATE, DCACHE_OP}) begin
                    tagv_clear          = 1;
                    tagv_we             = hit;
                    dirty_we            = hit;
                    w_dirty_data        = 1'b0;
                    if(!(cache_hit && dirty_data)) begin
                        data_valid      = 1;
                        rbuf_we         = 1;
                        wbuf_AXI_reset  = 1;
                        cache_ready     = 1;
                    end
                end
                //else if(exception != 0) data_valid = 1;
                else if(!cache_hit || uncache) begin
                    mbuf_we     = 1;
                    wbuf_AXI_we = 1;
                end
                else begin
                    data_valid  = 1;
                    rbuf_we     = 1;
                    way_visit   = hit;
                    way_sel_en  = 1;
                    cache_ready = 1;
                    if(op == WRITE)begin
                        mem_en          = hit;
                        mem_we          = mem_we_normal;
                        dirty_we        = hit;
                        w_dirty_data    = 1;
                    end
                end
            end
        end
        MISS: begin
            w_req   = 1;
            if(uncache) begin
                w_length    = 8'd0;
                w_size      = un_visit_type;
            end
        end
        REPLACE: begin
            r_req   = 1;
            if(uncache) begin
                r_length    = 8'd0;
                r_size      = un_visit_type;
            end
        end
        REFILL: begin
            r_data_ready = 1;
            if(fill_finish) begin
                if(!uncache) begin
                    mem_we          = {64{1'b1}};
                    mem_en          = lru_way_sel;
                    tagv_we         = lru_way_sel;
                    dirty_we        = lru_way_sel;
                    w_dirty_data    = (op == READ ? 1'b0 : 1'b1);
                    way_sel_en      = 1;
                    way_visit       = lru_way_sel;
                end
            end
        end
        WAIT_WRITE: begin
            if(cacop_en) begin
                if(wrt_AXI_finish) begin
                    data_valid      = 1;
                    rbuf_we         = 1;
                    wbuf_AXI_reset  = 1;
                    cache_ready     = 1;
                end
            end
            else if(uncache && (wrt_AXI_finish || op == READ) || 
              !uncache && (wrt_AXI_finish || op == READ || !dirty_data_mbuf || !vld_mbuf) )begin
                data_valid      = 1;
                rbuf_we         = 1;
                wbuf_AXI_reset  = 1;
                cache_ready     = 1;
            end
        end
        endcase
    end



endmodule
