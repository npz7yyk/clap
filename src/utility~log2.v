module utility_log2_4
(
    input [3:0] in,
    output [1:0] out
);
    reg [1:0] a;
    always @* begin
        case(in)
            4'h0: a = 0;
            4'h1: a = 0;
            4'h2: a = 1;
            4'h3: a = 1;
            4'h4: a = 2;
            4'h5: a = 2;
            4'h6: a = 2;
            4'h7: a = 2;
            4'h8: a = 3;
            4'h9: a = 3;
            4'ha: a = 3;
            4'hb: a = 3;
            4'hc: a = 3;
            4'hd: a = 3;
            4'he: a = 3;
            4'hf: a = 3;
        endcase
    end
    assign out = a;
endmodule

module utility_log2_8
(
    input [7:0] in,
    output [2:0] out
);
    reg [2:0] a;
    reg [7:0] b;
    always @* begin
        b = in;
        a = 0;
        if(b>=16)   begin a = a+ 4; b = {4'b0,b[7:4]};  end
        case(b[3:0])
            4'h0: a = a+0;
            4'h1: a = a+0;
            4'h2: a = a+1;
            4'h3: a = a+1;
            4'h4: a = a+2;
            4'h5: a = a+2;
            4'h6: a = a+2;
            4'h7: a = a+2;
            4'h8: a = a+3;
            4'h9: a = a+3;
            4'ha: a = a+3;
            4'hb: a = a+3;
            4'hc: a = a+3;
            4'hd: a = a+3;
            4'he: a = a+3;
            4'hf: a = a+3;
        endcase
    end
    assign out = a;
endmodule

module utility_log2_16
(
    input [15:0] in,
    output [3:0] out
);
    reg [3:0] a;
    reg [15:0] b;
    always @* begin
        b = in;
        a = 0;
        if(b>=256)  begin a = a+ 8; b = { 8'b0,b[15:8]}; end
        if(b>=16)   begin a = a+ 4; b = {12'b0,b[7:4]};  end
        case(b[3:0])
            4'h0: a = a+0;
            4'h1: a = a+0;
            4'h2: a = a+1;
            4'h3: a = a+1;
            4'h4: a = a+2;
            4'h5: a = a+2;
            4'h6: a = a+2;
            4'h7: a = a+2;
            4'h8: a = a+3;
            4'h9: a = a+3;
            4'ha: a = a+3;
            4'hb: a = a+3;
            4'hc: a = a+3;
            4'hd: a = a+3;
            4'he: a = a+3;
            4'hf: a = a+3;
        endcase
    end
    assign out = a;
endmodule

module utility_log2_32
(
    input [31:0] in,
    output [4:0] out
);
    reg [4:0] a;
    reg [31:0] b;
    always @* begin
        b = in;
        a = 0;
        if(b>=65536)begin a = a+16; b = {16'b0,b[31:16]};end
        if(b>=256)  begin a = a+ 8; b = {24'b0,b[15:8]}; end
        if(b>=16)   begin a = a+ 4; b = {28'b0,b[7:4]};  end
        case(b[3:0])
            4'h0: a = a+0;
            4'h1: a = a+0;
            4'h2: a = a+1;
            4'h3: a = a+1;
            4'h4: a = a+2;
            4'h5: a = a+2;
            4'h6: a = a+2;
            4'h7: a = a+2;
            4'h8: a = a+3;
            4'h9: a = a+3;
            4'ha: a = a+3;
            4'hb: a = a+3;
            4'hc: a = a+3;
            4'hd: a = a+3;
            4'he: a = a+3;
            4'hf: a = a+3;
        endcase
    end
    assign out = a;
endmodule

module utility_log2_64
(
    input [63:0] in,
    output [5:0] out
);
    reg [5:0] a;
    reg [63:0] b;
    always @* begin
        b = in;
        a = 0;
        if(b>=64'd4294967296)begin a = a+32; b = {32'b0,b[63:31]};end
        if(b>=64'd65536)     begin a = a+16; b = {48'b0,b[31:16]};end
        if(b>=64'd256)       begin a = a+ 8; b = {56'b0,b[15:8]}; end
        if(b>=64'd16)        begin a = a+ 4; b = {60'b0,b[7:4]};  end
        case(b[3:0])
            4'h0: a = a+0;
            4'h1: a = a+0;
            4'h2: a = a+1;
            4'h3: a = a+1;
            4'h4: a = a+2;
            4'h5: a = a+2;
            4'h6: a = a+2;
            4'h7: a = a+2;
            4'h8: a = a+3;
            4'h9: a = a+3;
            4'ha: a = a+3;
            4'hb: a = a+3;
            4'hc: a = a+3;
            4'hd: a = a+3;
            4'he: a = a+3;
            4'hf: a = a+3;
        endcase
    end
    assign out = a;
endmodule

module utility_log2_128
(
    input [127:0] in,
    output [6:0] out
);
    reg [6:0] a;
    reg [127:0] b;
    always @* begin
        b = in;
        a = 0;
        if(b>=128'd18446744073709551616)begin a = a+64; b = {64'b0,b[127:64]};end
        if(b>=128'd4294967296)          begin a = a+32; b = {96'b0,b[63:31]}; end
        if(b>=128'd65536)               begin a = a+16; b = {112'b0,b[31:16]};end
        if(b>=128'd256)                 begin a = a+ 8; b = {120'b0,b[15:8]}; end
        if(b>=128'd16)                  begin a = a+ 4; b = {124'b0,b[7:4]};  end
        case(b[3:0])
            4'h0: a = a+0;
            4'h1: a = a+0;
            4'h2: a = a+1;
            4'h3: a = a+1;
            4'h4: a = a+2;
            4'h5: a = a+2;
            4'h6: a = a+2;
            4'h7: a = a+2;
            4'h8: a = a+3;
            4'h9: a = a+3;
            4'ha: a = a+3;
            4'hb: a = a+3;
            4'hc: a = a+3;
            4'hd: a = a+3;
            4'he: a = a+3;
            4'hf: a = a+3;
        endcase
    end
    assign out = a;
endmodule

module utility_log2
#(
    parameter LOG2_WIDTH = 6
)(
    input [2**LOG2_WIDTH-1:0] in,
    output [LOG2_WIDTH-1:0] out
);
    generate
        if(LOG2_WIDTH==2) begin
            utility_log2_4 log2_4(in,out);
        end else if(LOG2_WIDTH==3) begin
            utility_log2_8 log2_8(in,out);
        end else if(LOG2_WIDTH==4) begin
            utility_log2_16 log2_16(in,out);
        end else if(LOG2_WIDTH==5) begin
            utility_log2_32 log2_32(in,out);
        end else if(LOG2_WIDTH==6) begin
            utility_log2_64 log2_64(in,out);
        end else if(LOG2_WIDTH==7) begin
            utility_log2_128 log2_128(in,out);
        end
    endgenerate
endmodule
