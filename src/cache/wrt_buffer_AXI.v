`timescale 1ns / 1ps

module wrt_buffer_AXI(
    input clk,
    input rstn,
    input w_buf_we,
    input wready,
    input bvalid,
    input awvalid,
    input awready,
    input wrt_reset,
    input [511:0] w_line_mem,

    output reg wvalid,
    output reg wlast,
    output reg bready,
    output reg [31:0] w_data_AXI,
    output reg wrt_AXI_finish
    );
    parameter IDLE = 2'b00;
    parameter REQUEST = 2'b01;
    parameter WAIT_FINISH = 2'b10;
    parameter FINISH = 2'b11;
    wire [511:0] w_data;
    reg [3:0] count;
    reg [1:0] crt, nxt;
    initial begin
        count = 0;
    end
    register #(512) wrt_buffer(
        .clk    (clk),
        .rstn   (rstn),
        .we     (w_buf_we),
        .din    (w_line_mem),
        .dout   (w_data)
    );

    //FSM
    always @(posedge clk) begin
        if(!rstn) crt <= IDLE;
        else crt <= nxt;
    end

    always @(*) begin
        case(crt)
        IDLE: begin
            if(awready && awvalid) nxt = REQUEST;
            else nxt = IDLE;
        end
        REQUEST: begin
            if(wlast) nxt = WAIT_FINISH;
            else nxt = REQUEST;
        end
        WAIT_FINISH: begin
            if(bvalid) nxt = FINISH;
            else nxt = WAIT_FINISH;
        end
        FINISH: begin
            if(wrt_reset) nxt = IDLE;
            else nxt = FINISH;
        end
        endcase
    end
    always @(*) begin
        wvalid = 0; wlast = 0; bready = 0;
        wrt_AXI_finish = 0;
        case(crt)
        REQUEST: begin
            wvalid = 1;
            if(count == 4'd15) wlast = 1;
        end
        WAIT_FINISH: begin
            bready = 1;
        end
        FINISH: begin
            wrt_AXI_finish = 1;
        end
        endcase
    end
    always @(posedge clk)begin
        case(crt)
        REQUEST: count <= count + 1;
        default: count <= 0;
        endcase
    end
    //w_data
    always @(*) begin
        case(count)
        4'h0: w_data_AXI = w_data[31:0];
        4'h1: w_data_AXI = w_data[63:32];
        4'h2: w_data_AXI = w_data[95:64];
        4'h3: w_data_AXI = w_data[127:96];
        4'h4: w_data_AXI = w_data[159:128];
        4'h5: w_data_AXI = w_data[191:160];
        4'h6: w_data_AXI = w_data[223:192];
        4'h7: w_data_AXI = w_data[255:224];
        4'h8: w_data_AXI = w_data[287:256];
        4'h9: w_data_AXI = w_data[319:288];
        4'ha: w_data_AXI = w_data[351:320];
        4'hb: w_data_AXI = w_data[383:352];
        4'hc: w_data_AXI = w_data[415:384];
        4'hd: w_data_AXI = w_data[447:416];
        4'he: w_data_AXI = w_data[479:448];
        4'hf: w_data_AXI = w_data[511:480];
        endcase
    end

endmodule
