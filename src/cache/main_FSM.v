`timescale 1ns / 1ps
module main_FSM(
    input clk, rstn,
    /* state trasfer signal */
    input valid,
    input cache_hit,
    input w_rdy_AXI,
    input r_rdy_AXI,
    input ret_valid, ret_last,
    /* other signal */
    input op,
    /* output */
    output reg gre_mat_en, 
    output reg hit_write,
    output reg miss_buf_we,
    output reg miss_buf_rstn,
    output reg data_valid,
    output reg addr_valid,
    output reg replace_en,
    output reg refill_en
    );
    /* state parameter */
    parameter IDLE = 3'd0;
    parameter LOOKUP = 3'd1;
    parameter MISS = 3'd2;
    parameter REPLACE = 3'd3;
    parameter REFILL = 3'd4;
    /* store or load */
    parameter LOAD = 1'd0;
    parameter WRITE = 1'd1;

    /* state */
    reg [2:0] crt, nxt;
    always @(posedge clk) begin
        if(!rstn) crt <= IDLE;
        else crt <= nxt;
    end
    /* state transfer */
    always @(*) begin
        case(crt)
        IDLE: begin
            if(valid) nxt = LOOKUP;
            else nxt = IDLE;
        end
        LOOKUP: begin
            if(cache_hit && valid) nxt = LOOKUP;
            else if(cache_hit && !valid) nxt = IDLE;
            else nxt = MISS;
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
            if(ret_valid && ret_last) nxt = IDLE;
            else nxt = REFILL;
        end
        default: nxt = IDLE;
        endcase
    end
    /* output */
    always @(*) begin
        addr_valid  = 0;
        miss_buf_we = 0;
        hit_write   = 0;
        data_valid  = 0;
        gre_mat_en  = 0;
        replace_en  = 0;
        refill_en   = 0;
        miss_buf_rstn = 1;
        case(crt)
        LOOKUP: begin
            addr_valid = 1;
            data_valid = 1;
            gre_mat_en = 1;
            if(cache_hit && op == WRITE) hit_write = 1;
        end
        MISS: begin
            if(w_rdy_AXI) miss_buf_we = 1;
        end
        REPLACE: begin
            replace_en = 1;
            if(r_rdy_AXI) miss_buf_rstn = 0;
        end
        REFILL: begin
            refill_en = 1;

        end
        endcase
    end
    
endmodule
