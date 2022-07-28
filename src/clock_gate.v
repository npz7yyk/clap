module clock_gate
(
    input aclk,resetn,
    output clk,
    input clear_clock_gate,
    input set_clock_gate
);
    reg clear_clock_gate_last;
    always @(posedge aclk)
        if(~resetn) clear_clock_gate_last<=0;
        else clear_clock_gate_last <= clear_clock_gate;
    wire clear_ps = clear_clock_gate&~clear_clock_gate_last;
    reg pause;
    always @(posedge aclk)
        if(~resetn) pause<=0;
        else if(clear_ps) pause <= 1;
        else if(set_clock_gate) pause <= 0;
    reg l_pause;
    always @(aclk,pause)
        if(~aclk) l_pause<=pause;
    
    assign clk = aclk&~pause;
endmodule
