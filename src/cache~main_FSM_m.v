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
    input i_uncache,
    input d_uncache,
    input [7:0] hit,
    input cache_hit,
    input dirty_data,
    input dirty_data_mbuf,
    input wrt_AXI_finish,


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
            if(awready) begin
                if(i_uncache || d_uncache) nxt = WAIT_WRITE;
                else nxt = REPLACE;
            end
            else nxt = MISS;
        end
        REPLACE: begin
            if(arready) begin
                
            end
        end
    end
        
endmodule
