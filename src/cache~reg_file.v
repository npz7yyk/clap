/* verilator lint_off DECLFILENAME */
module reg_file(
    input clk, 
    input [3:0] we,
    input [3:0] re,
    input [5:0] r_addr,
    input [5:0] w_addr,
    input w_data,
    output reg r_data
    );
    reg [3:0] regs [0:63];
    parameter WAY0 = 4'b0001;
    parameter WAY1 = 4'b0010;
    parameter WAY2 = 4'b0100;
    parameter WAY3 = 4'b1000;
    integer i;
    initial begin
        for(i = 0; i < 64; i = i + 1) begin
            regs[i] = 4'b0000;
        end
    end
    //write
    always@(posedge clk)begin
        case(we)
        WAY0: regs[w_addr][0] <= w_data;
        WAY1: regs[w_addr][1] <= w_data;
        WAY2: regs[w_addr][2] <= w_data;
        WAY3: regs[w_addr][3] <= w_data;
        default:;
        endcase
    end
    //read
    always @(*)begin
        case(re)
        WAY0: r_data = regs[r_addr][0];
        WAY1: r_data = regs[r_addr][1];
        WAY2: r_data = regs[r_addr][2];
        WAY3: r_data = regs[r_addr][3];
        default: r_data = 0;
        endcase
    end
endmodule
