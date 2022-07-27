module main_FSM_i(
    input clk, rstn,
    input valid,
    input cache_hit,
    input r_rdy_AXI,
    input fill_finish,
    input uncache,
    input [3:0] lru_way_sel,
    input [3:0] hit,
    input [31:0] addr_rbuf,

    output reg [3:0] way_visit,
    output reg mbuf_we,
    output reg pbuf_we,
    output reg rdata_sel,
    output reg rbuf_we,
    output reg way_sel_en,
    output reg [7:0] r_length,
    output reg [3:0] mem_we,
    output reg [3:0] tagv_we,
    output reg r_req,
    output reg r_data_ready,
    output reg data_valid,
    output reg cache_ready,

    input [4:0] cacop_code,
    input cacop_en,
    output reg tagv_clear,
    input [6:0] tlb_exception
    );
    parameter IDLE = 2'd0;
    parameter LOOKUP = 2'd1;
    parameter REPLACE = 2'd2;
    parameter REFILL = 2'd3;

    parameter STORE_TAG         = 2'b00;
    parameter INDEX_INVALIDATE  = 2'b01;
    parameter HIT_INVALIDATE    = 2'b10;

    parameter DCACHE_OP = 3'b001;
    parameter ICACHE_OP = 3'b000;

    reg [3:0] tagv_we_inst;
    always @(*) begin
        case(addr_rbuf[1:0])
        2'd0: tagv_we_inst = 4'b0001;
        2'd1: tagv_we_inst = 4'b0010;
        2'd2: tagv_we_inst = 4'b0100;
        2'd3: tagv_we_inst = 4'b1000;
        endcase
    end

    reg[1:0] crt, nxt;
    
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
            if(tlb_exception != 0) nxt = IDLE;
            else if(cacop_en && cacop_code[2:0] == ICACHE_OP) begin
                if(valid) nxt = LOOKUP;
                else nxt = IDLE;
            end
            else if(uncache) nxt = REPLACE;
            else if(cache_hit) begin
                if(valid) nxt = LOOKUP;
                else nxt = IDLE;
            end
            else nxt = REPLACE;
        end
        REPLACE: begin
            if(r_rdy_AXI) nxt = REFILL;
            else nxt = REPLACE;
        end
        REFILL: begin
            if(fill_finish) begin
                if(valid) nxt = LOOKUP;
                else nxt = IDLE;
            end
            else nxt = REFILL;
        end
        default: nxt = IDLE;
        endcase
    end
    always @(*)begin
        mbuf_we = 0;
        rbuf_we = 0;
        mem_we = 0;
        rdata_sel = 0;
        tagv_we = 0;
        r_req = 0;
        data_valid = 0;
        way_sel_en = 0;
        r_data_ready = 0;
        way_visit = 0;
        cache_ready = 0;
        pbuf_we = 0;
        r_length = 8'd15;
        tagv_clear = 0;
        case(crt)
        IDLE: begin
            rbuf_we = 1;
            cache_ready = 1;
        end
        LOOKUP: begin
            if(tlb_exception == 0) begin
                rdata_sel = 1;
                pbuf_we = 1;
                if(cacop_en && (cacop_code == {STORE_TAG, ICACHE_OP} || cacop_code == {INDEX_INVALIDATE, ICACHE_OP})) begin
                    tagv_clear          = 1;
                    tagv_we             = tagv_we_inst;
                    data_valid          = 1;
                end
                else if(cacop_en && cacop_code == {HIT_INVALIDATE, ICACHE_OP}) begin
                    tagv_clear          = 1;
                    tagv_we             = hit;
                    data_valid          = 1;
                end
                else if(!cache_hit || uncache) begin
                    mbuf_we = 1;
                end
                else begin
                    if(!uncache) begin
                        data_valid = 1;
                        rbuf_we = 1;
                        way_visit = hit;
                        way_sel_en = 1;
                        cache_ready = 1;
                    end
                end
            end
            else data_valid = 1;
        end
        REPLACE: begin
            r_req = 1;
            if(uncache) begin
                r_length = 8'd1;
            end
        end
        REFILL: begin
            r_data_ready = 1;
            if(fill_finish) begin
                if(!uncache) begin
                    mem_we = lru_way_sel;
                    tagv_we = lru_way_sel;
                    way_visit = lru_way_sel;
                    way_sel_en = 1;
                end
                data_valid = 1;
                rbuf_we = 1;
                cache_ready = 1;
            end
        end
        endcase
    end
endmodule
