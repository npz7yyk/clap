/* verilator lint_off DECLFILENAME */
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

    output reg cacop_ready,
    output reg cacop_complete,

    input [1:0] cacop_code,
    input cacop_en,

    output reg tagv_clear,
    input [6:0] exception
    );
    parameter IDLE          = 3'd0;
    parameter LOOKUP        = 3'd1;
    parameter REPLACE       = 3'd2;
    parameter REFILL        = 3'd3;
    parameter CACOP_COPE    = 3'd4;
    parameter EXTRA_READY   = 3'd5;

    parameter STORE_TAG         = 2'b00;
    parameter INDEX_INVALIDATE  = 2'b01;
    parameter HIT_INVALIDATE    = 2'b10;

    reg [3:0] tagv_we_inst;
    always @(*) begin
        case(addr_rbuf[1:0])
        2'd0: tagv_we_inst = 4'b0001;
        2'd1: tagv_we_inst = 4'b0010;
        2'd2: tagv_we_inst = 4'b0100;
        2'd3: tagv_we_inst = 4'b1000;
        endcase
    end

    reg[2:0] crt, nxt;
    
    always @(posedge clk) begin
        if(!rstn) crt <= IDLE;
        else crt <= nxt;
    end

    always @(*) begin
        case(crt)
        IDLE: begin
            if(cacop_en) nxt = CACOP_COPE;
            else if(valid) nxt = LOOKUP;
            else nxt = IDLE;
        end
        LOOKUP: begin
            if(exception != 0) nxt = IDLE;
            else if(uncache) nxt = REPLACE;
            else if(cache_hit) begin
                if(cacop_en) nxt = CACOP_COPE;
                else if(valid) nxt = LOOKUP;
                else nxt = IDLE;
            end
            else nxt = REPLACE;
        end
        REPLACE: begin
            if(r_rdy_AXI) nxt = REFILL;
            else nxt = REPLACE;
        end
        REFILL: begin
            if(fill_finish) nxt = EXTRA_READY;
            else nxt = REFILL;
        end
        CACOP_COPE: begin
            if(exception != 0) nxt = IDLE;
            else nxt = EXTRA_READY;
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
        cacop_ready = 0;
        cacop_complete = 0;
        case(crt)//%Warning-CASEINCOMPLETE: /home/songxiao/Desktop/chiplab/IP/myCPU/cache~main_FSM_i.v:120:9: Case values incompletely covered (example pattern 0x6)
        IDLE: begin
            rbuf_we = 1;
            cache_ready = 1;
            cacop_ready = 1;
        end
        LOOKUP: begin
            if(exception == 0) begin
                rdata_sel = 1;
                pbuf_we = 1;
                if(!cache_hit || uncache) mbuf_we = 1;
                else begin
                    data_valid = 1;
                    rbuf_we = 1;
                    way_visit = hit;
                    way_sel_en = 1;
                    cache_ready = 1;
                    cacop_ready = 1;
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
            end
        end
        CACOP_COPE: begin
            if(cacop_code == STORE_TAG || cacop_code == INDEX_INVALIDATE) begin
                tagv_clear          = 1;
                tagv_we             = tagv_we_inst;
                data_valid          = 1;
            end
            else if(cacop_code == HIT_INVALIDATE) begin
                tagv_clear          = 1;
                tagv_we             = hit;
                data_valid          = 1;
            end
        end
        EXTRA_READY: begin
            data_valid = 1;
            rbuf_we = 1;
            cache_ready = 1;
            cacop_ready = 1;
            cacop_complete = 1;
        end
        endcase
    end
endmodule
