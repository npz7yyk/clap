`include "clap_config.vh"

/* verilator lint_off DECLFILENAME */
module ret_buf_d(
    input clk,
    input [31:0] addr_rbuf,
    input [3:0] wrt_type,
    input uncache_rbuf,
    input [31:0] r_data_AXI,
    input [31:0] w_data_CPU_rbuf,
    input ret_valid, ret_last,
    output reg [511:0] w_data_AXI,
    output reg fill_finish
    );
    parameter BYTE = 4'b0001;
    parameter HALF = 4'b0011;
    parameter WORD = 4'b1111;
    parameter READ = 1'b0;
    initial begin
        w_data_AXI = 0;
    end

    reg finish_pos;
    wire ret_finish;
    always @(posedge clk) begin
        finish_pos <= ret_last & ret_valid;
    end
    assign ret_finish = !finish_pos & ret_last & ret_valid;
    always @(posedge clk) begin
        if(ret_valid)begin
            if(uncache_rbuf) begin
                w_data_AXI <= {480'b0, r_data_AXI};
            end
            else begin
                w_data_AXI <= {r_data_AXI, w_data_AXI[511:32]};
            end
        end
        if(ret_finish) begin
            fill_finish <= 1;
        end
        else fill_finish <= 0;
    end
endmodule
