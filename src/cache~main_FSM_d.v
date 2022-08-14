`include "clap_config.vh"

/* verilator lint_off DECLFILENAME */
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
    input wrt_AXI_finish,
    input [3:0] lru_way_sel,
    input [3:0] hit,
    input [63:0] mem_we_normal,
    input [3:0] visit_type,
    input [31:0] addr_rbuf,
    input [6:0] exception_temp,
    input [6:0] exception,
    input is_atom_rbuf,
    input llbit_rbuf,

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

    input [1:0] cacop_code,
    input cacop_en,
    input cacop_en_rbuf,
    output reg cacop_complete,
    output reg cacop_ready,
    output reg tagv_clear,
    output reg llbit_set,
    output reg llbit_clear,
    output reg exp_sel

    );
    parameter IDLE          = 9'b000000001;
    parameter LOOKUP        = 9'b000000010;
    parameter MISS          = 9'b000000100;
    parameter REPLACE       = 9'b000001000;
    parameter REFILL        = 9'b000010000;
    parameter WAIT_WRITE    = 9'b000100000;
    parameter CACOP_COPE    = 9'b001000000;
    parameter EXTRA_READY   = 9'b010000000;
    parameter IBAR_COPE     = 9'b100000000;

    parameter READ          = 1'd0;
    parameter WRITE         = 1'd1;

    parameter BYTE          = 4'b0001;
    parameter HALF          = 4'b0011;
    parameter WORD          = 4'b1111;

    parameter STORE_TAG         = 2'b00;
    parameter INDEX_INVALIDATE  = 2'b01;
    parameter HIT_INVALIDATE    = 2'b10;



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

    reg[8:0] crt, nxt;
    reg count_en;

    always @(posedge clk) begin
        if(!rstn) crt <= IDLE;
        else crt <= nxt;
    end

    always @(*) begin
        case(crt)
        IDLE: begin
            if(exception != 0) nxt = IDLE;
            else if(cacop_en) nxt = CACOP_COPE;
            else if(valid) nxt = LOOKUP;
            else nxt = IDLE;
        end
        CACOP_COPE: begin
            if(exception_temp != 0) nxt = IDLE;
            else begin
                case(cacop_code)
                STORE_TAG: nxt = EXTRA_READY;
                INDEX_INVALIDATE: begin
                    if(dirty_data) nxt = MISS;
                    else nxt = EXTRA_READY;
                end
                HIT_INVALIDATE: begin
                    if(cache_hit && dirty_data) nxt = MISS;
                    else nxt = EXTRA_READY;
                end
                default: nxt = EXTRA_READY;
                endcase
            end
        end
        LOOKUP: begin
            if(exception_temp != 0) nxt = IDLE;
            // check uncache
            else if(uncache) begin
                if(op == READ) nxt = REPLACE;
                else if(is_atom_rbuf && op == WRITE && !llbit_rbuf) nxt = EXTRA_READY;
                else nxt = MISS;
            end
            else if(is_atom_rbuf && op == WRITE && !llbit_rbuf) begin
                nxt = EXTRA_READY;
            end
            // check cache_hit
            else if(cache_hit) begin 
                if(valid) nxt = LOOKUP;
                else nxt = IDLE;
            end

            // all not
            else begin
                if(dirty_data) nxt = MISS;
                else nxt = REPLACE;
            end
        end
        MISS: begin
            if(w_rdy_AXI) begin
                if(uncache || 
                  (cacop_en_rbuf && (cacop_code == INDEX_INVALIDATE || cacop_code == HIT_INVALIDATE))) nxt = WAIT_WRITE;
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
            if(cacop_en_rbuf) begin
                if(wrt_AXI_finish) begin
                    nxt = EXTRA_READY;
                end
                else nxt = WAIT_WRITE;
            end
            else if(uncache && (wrt_AXI_finish || op == READ) || 
              !uncache && (wrt_AXI_finish || op == READ || !dirty_data_mbuf)) begin
                nxt = EXTRA_READY;
            end
            else nxt = WAIT_WRITE;
        end
        EXTRA_READY: begin
            if(cacop_en) nxt = CACOP_COPE;
            else if(valid) nxt = LOOKUP;
            else nxt = IDLE;
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
        tagv_clear = 0;                     cacop_complete = 0;
        cacop_ready = 0;                    llbit_set = 0;
        llbit_clear = 0;                    exp_sel = 0;
        case(crt)
        IDLE: begin
            if(valid || cacop_en) rbuf_we     = 1;
            cache_ready = 1;
            cacop_ready = 1;
        end
        LOOKUP: begin
            if(exception_temp == 0) begin
                rdata_sel       = 1;
                wrt_data_sel    = 1;
                pbuf_we         = 1;
                mbuf_we         = 1;
                wbuf_AXI_we     = 1;
                way_visit       = hit;
                way_sel_en      = 1;
                if(cache_hit && !uncache) begin
                    data_valid = 1;
                    cacop_ready = 1;
                    cache_ready = 1;
                    if(valid || cacop_en) rbuf_we = 1;
                end
                if(op == READ) begin
                    if(is_atom_rbuf) llbit_set = 1;
                end
                else begin
                    if(is_atom_rbuf) llbit_clear = 1;
                    if(!is_atom_rbuf || llbit_rbuf) begin
                        mem_en          = hit;
                        mem_we          = mem_we_normal;
                        dirty_we        = hit;
                        w_dirty_data    = 1;
                    end
                end
            end
            else data_valid = 1;
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
            if(fill_finish && !uncache) begin
                mem_we          = {64{1'b1}};
                mem_en          = lru_way_sel;
                tagv_we         = lru_way_sel;
                dirty_we        = lru_way_sel;
                w_dirty_data    = (op == READ ? 1'b0 : 1'b1);
                way_sel_en      = 1;
                way_visit       = lru_way_sel;
            end
        end
        CACOP_COPE: begin
            if(exception_temp != 0) cacop_complete = 1;
            else if(cacop_code == STORE_TAG) begin
                tagv_clear          = 1;
                tagv_we             = tagv_we_inst;
                dirty_we            = tagv_we_inst;
                w_dirty_data        = 1'b0;
            end
            else if(cacop_code == INDEX_INVALIDATE) begin
                tagv_clear          = 1;
                tagv_we             = tagv_we_inst;
                dirty_we            = tagv_we_inst;
                w_dirty_data        = 1'b0;
                if(dirty_data) begin
                    mbuf_we = 1;
                    wbuf_AXI_we = 1;
                end
            end
            else if(cacop_code == HIT_INVALIDATE) begin
                tagv_clear          = 1;
                tagv_we             = hit;
                dirty_we            = hit;
                w_dirty_data        = 1'b0;
                if(dirty_data) begin
                    mbuf_we = 1;
                    wbuf_AXI_we = 1;
                end
            end
        end
        EXTRA_READY: begin
            data_valid      = 1;
            exp_sel         = 1;
            if(cacop_en_rbuf) cacop_complete  = 1;
            cacop_ready     = 1;
            if(valid || cacop_en) rbuf_we         = 1;
            wbuf_AXI_reset  = 1;
            cache_ready     = 1;
        end
        default:;
        endcase
    end



endmodule
