module utility_reverse_bits
#( parameter WIDHT=32)
(
    input [WIDHT-1:0] in,
    output [WIDHT-1:0] out
);
    generate
        for(genvar i=0;i<WIDHT;i=i+1) begin
            assign out[i] = in[WIDHT-1-i];
        end
    endgenerate
endmodule
