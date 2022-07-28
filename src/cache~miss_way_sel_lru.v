/* verilator lint_off DECLFILENAME */
module miss_way_sel_lru(
    input clk,
    input [31:0] addr_rbuf,
    input [3:0] visit,
    input en,
    output reg [3:0] way_sel 
    );
    parameter WAY0 = 4'b0001;
    parameter WAY1 = 4'b0010;
    parameter WAY2 = 4'b0100;
    parameter WAY3 = 4'b1000;
    
    wire [5:0] index;
    assign index = addr_rbuf[11:6];

    reg [7:0] rank [0:63];
    reg [1:0] visit_num;
    wire [3:0] cmp_result;

    integer i;
    initial begin
        for(i = 0; i < 64; i = i + 1)begin
            rank[i] = 8'b00011011;
        end
    end
    // encoder
    always @(*) begin
        case(visit)
        WAY0: visit_num = 2'd0;
        WAY1: visit_num = 2'd1;
        WAY2: visit_num = 2'd2;
        WAY3: visit_num = 2'd3;
        default: visit_num = 0;
        endcase
    end
    assign cmp_result[0] = (visit_num == rank[index][1:0]);
    assign cmp_result[1] = (visit_num == rank[index][3:2]);
    assign cmp_result[2] = (visit_num == rank[index][5:4]);
    assign cmp_result[3] = (visit_num == rank[index][7:6]);

    always @(posedge clk) begin
        if(en)begin
            case(cmp_result)
            4'b0010: begin
                rank[index][1:0] <= rank[index][3:2];
                rank[index][3:2] <= rank[index][1:0];
            end
            4'b0100: begin
                rank[index][1:0] <= rank[index][5:4];
                rank[index][3:2] <= rank[index][1:0];
                rank[index][5:4] <= rank[index][3:2];
            end
            4'b1000: begin
                rank[index][1:0] <= rank[index][7:6];
                rank[index][3:2] <= rank[index][1:0];
                rank[index][5:4] <= rank[index][3:2];
                rank[index][7:6] <= rank[index][5:4];
            end
            default:;
            endcase
        end
    end

    always @(*) begin
        case(rank[index][7:6])
        2'd0: way_sel = 4'b0001;
        2'd1: way_sel = 4'b0010;
        2'd2: way_sel = 4'b0100;
        2'd3: way_sel = 4'b1000;
        endcase
    end
endmodule
