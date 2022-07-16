`timescale 1ns / 1ps
module main_FSM_i(
    input clk, rstn,
    input valid,
    input cache_hit,
    input r_rdy_AXI,
    input fill_finish,
    input [3:0] lru_way_sel,
    input [3:0] hit,

    output reg [3:0] way_visit,
    output reg mbuf_we,
    output reg pbuf_we,
    output reg rdata_sel,
    output reg rbuf_we,
    output reg way_sel_en,
    output reg [3:0] mem_we,
    output reg [3:0] tagv_we,
    output reg r_req,
    output reg r_data_ready,
    output reg data_valid,
    output reg cache_ready
    );
    parameter IDLE = 2'd0;
    parameter LOOKUP = 2'd1;
    parameter REPLACE = 2'd2;
    parameter REFILL = 2'd3;

    reg[1:0] crt, nxt;

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
        case(crt)
        IDLE: begin
            rbuf_we = 1;
            cache_ready = 1;
        end
        LOOKUP: begin
            rdata_sel = 1;
            pbuf_we = 1;
            if(!cache_hit) begin
                mbuf_we = 1;
            end
            else begin
                data_valid = 1;
                rbuf_we = 1;
                way_visit = hit;
                way_sel_en = 1;
                cache_ready = 1;
            end
        end
        REPLACE: begin
            r_req = 1;
        end
        REFILL: begin
            r_data_ready = 1;
            if(fill_finish) begin
                mem_we = lru_way_sel;
                tagv_we = lru_way_sel;
                data_valid = 1;
                rbuf_we = 1;
                way_visit = lru_way_sel;
                way_sel_en = 1;
                cache_ready = 1;
            end
        end
        endcase
    end
endmodule
