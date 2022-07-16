module main_FSM_d(
    input clk, rstn,
    input valid,
    input op,
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
    output reg data_valid,
    output reg cache_ready
    );
    parameter IDLE = 3'd0;
    parameter LOOKUP = 3'd1;
    parameter MISS = 3'd2;
    parameter REPLACE = 3'd3;
    parameter REFILL = 3'd4;
    parameter WAIT_WRITE = 3'd5;

    parameter READ = 1'd0;
    parameter WRITE = 1'd1;

    reg[2:0] crt, nxt;

    always @(posedge clk) begin
        if(!rstn) crt <= 0;
        else crt <= nxt;
    end

    always @(*) begin
        case(crt)
        IDLE: begin
            if(valid) nxt = LOOKUP;
            else nxt = IDLE;
        end
        LOOKUP: begin
            if(valid && cache_hit) nxt = LOOKUP;
            else if(!valid && cache_hit) nxt = IDLE;
            else begin
                if(op == WRITE && dirty_data && vld) nxt = MISS;
                else nxt = REPLACE;
            end
        end
        MISS: begin
            if(w_rdy_AXI) nxt = REPLACE;
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
            if(wrt_AXI_finish || op == READ || !dirty_data_mbuf || !vld_mbuf) begin
                if(valid) nxt = LOOKUP;
                else nxt = IDLE;
            end
            else nxt = WAIT_WRITE;
        end
        default: nxt = IDLE;
        endcase
    end
    always @(*)begin
        mbuf_we = 0; wbuf_AXI_we = 0; mem_we = 0; mem_en = 0;
        rdata_sel = 0; wrt_data_sel = 0; tagv_we = 0;
        r_req = 0; w_req = 0; data_valid = 0; dirty_we = 0; 
        w_dirty_data = 0; r_data_ready = 0; rbuf_we = 0;
        way_sel_en = 0; wbuf_AXI_reset = 0;
        way_visit = 0; cache_ready = 0; pbuf_we = 0;
        case(crt)
        IDLE: begin
            rbuf_we = 1;
            cache_ready = 1;
        end
        LOOKUP: begin
            rdata_sel = 1;
            wrt_data_sel = 1;
            pbuf_we = 1;
            if(!cache_hit) begin
                mbuf_we = 1;
                wbuf_AXI_we = 1;
            end
            else begin
                data_valid = 1;
                rbuf_we = 1;
                way_visit = hit;
                way_sel_en = 1;
                cache_ready = 1;
                if(op == WRITE)begin
                    mem_en = hit;
                    mem_we = mem_we_normal;
                    dirty_we = hit;
                    w_dirty_data = 1;
                end
            end
        end
        MISS: begin
            w_req = 1;
        end
        REPLACE: begin
            r_req = 1;
        end
        REFILL: begin
            r_data_ready = 1;
            if(fill_finish) begin
                mem_we = {64{1'b1}};
                mem_en = lru_way_sel;
                tagv_we = lru_way_sel;
                dirty_we = lru_way_sel;
                w_dirty_data = (op == READ ? 1'b0 : 1'b1);
                way_sel_en = 1;
                way_visit = lru_way_sel;
            end
        end
        WAIT_WRITE: begin
            if(wrt_AXI_finish || op == READ || !dirty_data_mbuf|| !vld_mbuf)begin
                data_valid = 1;
                rbuf_we = 1;
                wbuf_AXI_reset = 1;
                cache_ready = 1;
            end
        end
        endcase
    end
endmodule
