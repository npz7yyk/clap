`include "clap_config.vh"

/* verilator lint_off DECLFILENAME */
module ret_buf_d(
    input clk,rstn,
    input [31:0] addr_rbuf,
    input [3:0] wrt_type,
    input op_rbuf,
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
    reg [3:0] count;

    reg finish_pos;
    wire ret_finish;
    always @(posedge clk) 
        if(~rstn) finish_pos <= 0;
        else finish_pos <= ret_last & ret_valid;
    assign ret_finish = !finish_pos & ret_last & ret_valid;
    always @(posedge clk) 
        if(~rstn) begin
            count <= 0;
            w_data_AXI <= 0;
            fill_finish <=0 ;
        end else begin
        if(ret_valid)begin
            if(uncache_rbuf) begin
                w_data_AXI <= {480'b0, r_data_AXI};
            end
            else if(op_rbuf == READ || count != addr_rbuf[5:2]) begin
                w_data_AXI <= {r_data_AXI, w_data_AXI[511:32]};
            end
            else begin
                case(wrt_type)
                BYTE: begin
                    case(addr_rbuf[1:0])
                    2'b00: w_data_AXI <= {r_data_AXI[31:8], w_data_CPU_rbuf[7:0], w_data_AXI[511:32]};
                    2'b01: w_data_AXI <= {r_data_AXI[31:16], w_data_CPU_rbuf[7:0], r_data_AXI[7:0], w_data_AXI[511:32]};
                    2'b10: w_data_AXI <= {r_data_AXI[31:24], w_data_CPU_rbuf[7:0], r_data_AXI[15:0], w_data_AXI[511:32]};
                    2'b11: w_data_AXI <= {w_data_CPU_rbuf[7:0], r_data_AXI[23:0], w_data_AXI[511:32]};
                    endcase
                end
                HALF: begin
                    case(addr_rbuf[1])
                        1'b0: w_data_AXI <= {r_data_AXI[31:16], w_data_CPU_rbuf[15:0], w_data_AXI[511:32]};
                        1'b1: w_data_AXI <= {w_data_CPU_rbuf[15:0], r_data_AXI[15:0], w_data_AXI[511:32]};
                    endcase
                end
                WORD: w_data_AXI <= {w_data_CPU_rbuf, w_data_AXI[511:32]};
                default: w_data_AXI <= {r_data_AXI, w_data_AXI[511:32]};
                endcase
            end
            count <= count + 1;
        end
        if(ret_finish) begin
            count <= 0;
            fill_finish <= 1;
        end
        else fill_finish <= 0;
    end
endmodule
