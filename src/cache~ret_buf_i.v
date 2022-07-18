module ret_buf_i(
    input clk,
    input[31:0] r_data_AXI,
    input ret_valid, ret_last,
    output reg [511:0] mem_din,
    output reg fill_finish
    );
    reg finish_pos;
    wire ret_finish;
    always @(posedge clk) begin
        finish_pos <= ret_last & ret_valid;
    end
    assign ret_finish = !finish_pos & ret_last & ret_valid;

    always @(posedge clk) begin
        if(ret_valid)begin
            mem_din = (mem_din >> 32) | {r_data_AXI, 480'b0};
        end
        if(ret_finish) fill_finish = 1;
        else fill_finish = 0;
    end
endmodule
