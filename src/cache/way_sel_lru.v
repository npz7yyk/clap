`timescale 1ns / 1ps
module way_sel_lru(
    input clk, en,
    input [3:0] visit,
    output reg [3:0] lru_way_sel
    );
    reg [7:0] hold_time [0:3];
    reg [3:0] gre_mat [0:3];
    integer i, j;
    initial begin
        for(i = 0; i < 4; i = i + 1)begin
            hold_time[i] = 3 - i;
        end

    end
    // update hold time
    always @(posedge clk) begin
        if(en)begin
            for(i = 0; i < 4; i = i + 1)begin
                if(visit[i]) hold_time[i] <= 0;
                else if(hold_time[i] != 8'd255) hold_time[i] <= hold_time[i] + 1;
            end
        end
    end
    //update matrix
    always @(*)begin
        for(i = 0; i < 4; i = i + 1)begin
            for(j = 0; j < 4; j = j + 1)begin
                gre_mat[i][j] = (hold_time[i] >= hold_time[j]);
            end
        end
    end
    //form lru way sel
    always @(*) begin
        // for(i = 0; i < 4; i = i + 1)begin
        //     lru_way_sel[i] = &gre_mat[i];
        // end
        if(&gre_mat[0]) lru_way_sel = 4'b0001;
        else if(&gre_mat[1]) lru_way_sel = 4'b0010;
        else if(&gre_mat[2]) lru_way_sel = 4'b0100;
        else lru_way_sel = 4'b1000;
    end
endmodule
