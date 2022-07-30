`include "clap_config.vh"

/* verilator lint_off DECLFILENAME */
module exe_log2_plus_one
(
    input [31:0] in,
    output [5:0] out
);
    reg [5:0] a;
    reg [31:0] b;
    always @* begin
        b = in;
        a = 0;
        if(b>=65536)begin a = a+16; b = {16'b0,b[31:16]};end
        if(b>=256)  begin a = a+ 8; b = {24'b0,b[15:8]}; end
        if(b>=16)   begin a = a+ 4; b = {28'b0,b[7:4]};  end
        case(b[3:0])
            4'h0: a = a+0;
            4'h1: a = a+1;
            4'h2: a = a+2;
            4'h3: a = a+2;
            4'h4: a = a+3;
            4'h5: a = a+3;
            4'h6: a = a+3;
            4'h7: a = a+3;
            4'h8: a = a+4;
            4'h9: a = a+4;
            4'ha: a = a+4;
            4'hb: a = a+4;
            4'hc: a = a+4;
            4'hd: a = a+4;
            4'he: a = a+4;
            4'hf: a = a+4;
        endcase
    end
    assign out = a;
endmodule
