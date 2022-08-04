`include "clap_config.vh"

/* verilator lint_off DECLFILENAME */
module ret_buf_m(
    input               clk,
    input        [31:0] addr_rbuf,
    input         [3:0] wstrb,
    input               op_rbuf,
    input               uncache_rbuf,
    input        [31:0] rdata_AXI,
    input        [31:0] wdata_rbuf,
    input               rvalid,
    input               rlast,
    output reg  [511:0] rline_AXI,
    output reg          fill_finish
    );
    localparam 
        BYTE0 = 4'b0001,
        BYTE1 = 4'b0010,
        BYTE2 = 4'b0100,
        BYTE3 = 4'b1000,
        HALF0 = 4'b0011,
        HALF1 = 4'b1100,
        WORD  = 4'b1111;
    localparam 
        READ  = 1'b0,
        write = 1'b1;
    reg [3:0] count;

    initial begin
        count = 0;
    end

    reg finish_pos;
    wire ret_finish;
    
    always @(posedge clk) begin
        finish_pos <= rlast & rvalid;
    end
    assign ret_finish = !finish_pos & rlast & rvalid;

    always @(posedge clk) begin
        if(rvalid)begin
            if(uncache_rbuf) begin
                rline_AXI <= {480'b0, rdata_AXI};
            end
            else if(op_rbuf == READ || count != addr_rbuf[5:2]) begin
                rline_AXI <= {rdata_AXI, rline_AXI[511:32]};
            end
            else begin
                case(wstrb)
                BYTE0: rline_AXI <= {rdata_AXI[31:8],   wdata_rbuf[7:0],                        rline_AXI[511:32]};
                BYTE1: rline_AXI <= {rdata_AXI[31:16],  wdata_rbuf[7:0],    rdata_AXI[7:0],     rline_AXI[511:32]};
                BYTE2: rline_AXI <= {rdata_AXI[31:24],  wdata_rbuf[7:0],    rdata_AXI[15:0],    rline_AXI[511:32]};
                BYTE3: rline_AXI <= {                   wdata_rbuf[7:0],    rdata_AXI[23:0],    rline_AXI[511:32]};
                HALF0: rline_AXI <= {rdata_AXI[31:16],  wdata_rbuf[15:0],                       rline_AXI[511:32]};
                HALF1: rline_AXI <= {                   wdata_rbuf[15:0],   rdata_AXI[15:0],    rline_AXI[511:32]};
                WORD:  rline_AXI <= {                   wdata_rbuf,                             rline_AXI[511:32]};
                endcase
            end
            count <= count + 1;
        end
        if(ret_finish) begin
            count       <= 0;
            fill_finish <= 1;
        end
        else fill_finish <= 0;
    end
endmodule
