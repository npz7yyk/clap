module ret_buf_d(
    input clk,
    input [31:0] addr_rbuf,
    input [3:0] wrt_type,
    input op_rbuf,
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
    parameter WRITE = 1'b1;
    wire [31:0]test_hi;
    assign test_hi = w_data_AXI[511:480];
    reg [3:0] count;
    initial begin
        count = 0;
        w_data_AXI = 0;
    end
    reg ret_valid_pos;
    wire ret_finish;
    always @(posedge clk) begin
        ret_valid_pos <= ret_valid;
    end
    assign ret_finish = !ret_valid_pos & ret_valid;

    always @(posedge clk) begin
        if(ret_valid)begin
            if(op_rbuf == READ || count != addr_rbuf[5:2]) begin
                w_data_AXI <= (w_data_AXI >> 32) | {r_data_AXI, 480'b0};
            end
            else begin
                case(wrt_type)
                BYTE: w_data_AXI <= (w_data_AXI >> 32) | {r_data_AXI[31:8], w_data_CPU_rbuf[7:0], 480'b0};
                HALF: w_data_AXI <= (w_data_AXI >> 32) | {r_data_AXI[31:16], w_data_CPU_rbuf[15:0], 480'b0};
                WORD: w_data_AXI <= (w_data_AXI >> 32) | {w_data_CPU_rbuf, 480'b0};
                default: w_data_AXI <= (w_data_AXI >> 32) | {r_data_AXI, 480'b0};
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
