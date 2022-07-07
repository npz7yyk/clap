`timescale 1ns / 1ps

module write_FSM(
    input clk, rstn,
    input hit_write,
    output reg out_valid,
    output reg dirty_we
    );
    parameter IDLE = 1'd0;
    parameter WRITE = 1'd1;
    reg crt, nxt;
    reg [31:0] write_buffer;
    always @(posedge clk)begin
        if(!rstn) crt <= IDLE;
        else crt <= nxt;
    end
    always @(*)begin
        case(crt)
        IDLE: begin
            if(hit_write) nxt = WRITE;
            else nxt = IDLE;
        end
        WRITE: begin
            nxt = WRITE;
        end
        default: nxt = IDLE;
        endcase
    end
    always @(*) begin
        case(crt)
        IDLE: begin
            out_valid = 0;
            dirty_we = 1;
        end
        WRITE: begin
            out_valid = 1;
            dirty_we = 1;
        end
        endcase
    end
endmodule
