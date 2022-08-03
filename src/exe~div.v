/* verilator lint_off DECLFILENAME */
module div(
    input [0:0]         clk,
    input [0:0]         rstn,
    input flush_by_writeback,
             
    input [0:0]         div_en_in,
    input [0:0]         div_op,   
    input [0:0]         div_sign,
    input [ 31:0 ]      div_sr0,
    input [ 31:0 ]      div_sr1,
    input [ 4:0 ]       div_addr_in,
    input [31:0]        div_pc_in,
    input [31:0]        div_inst_in,

    output reg [0:0]    div_en_out,
    output reg [0:0]        stall_by_div,
    output reg [ 31:0 ] div_result,
    output reg [ 4:0 ]  div_addr_out,
    output [31:0]       div_pc_out,
    output [31:0]       div_inst_out
);

parameter IDLE      = 0;
parameter PREPARE   = 1;
parameter CALCULATE = 2;
parameter FINISH    = 3;
reg [1:0]   state;
reg [1:0]   next_state;
   
reg [5:0]   i;
reg [31:0]  dividend;
reg [31:0]  divisor;
reg [0:0]   op;
reg [0:0]   dividend_sign;
reg [0:0]   divisor_sign;
reg [4:0]   addr;
reg [31:0]  qoucient;
reg [5:0]   m;
reg [5:0]   n;
reg [31:0]  div_pc;
reg [31:0]  div_inst;
 
wire [5:0]  m_pre;
wire [5:0]  n_pre;
wire [31:0] a;
wire [31:0] b;

assign a                 = div_sign?div_sr0[31]==1?~div_sr0+1:div_sr0:div_sr0;
assign b                 = div_sign?div_sr1[31]==1?~div_sr1+1:div_sr1:div_sr1;
assign div_pc_out        = {32{div_en_out}}& div_pc;
assign div_inst_out      = {32{div_en_out}}&div_inst;

exe_log2_plus_one log2_1(a,m_pre);
exe_log2_plus_one log2_2(b,n_pre);

always @(posedge clk) begin
    if (!rstn||div_en_out||flush_by_writeback) begin
        state <= 0;
    end else begin
        state <= next_state;
    end
end

always @(*) begin
    case (state)
        IDLE: begin
            if(div_en_in)begin
                next_state = PREPARE;
            end else begin
                next_state = IDLE;
            end
        end
        PREPARE:begin
            if(m<n||n==0)begin
                next_state = FINISH;
            end else begin
                next_state = CALCULATE;
            end
        end
        CALCULATE:begin
            if(i==m-n+2)begin
                next_state = FINISH;
            end else begin
                next_state = CALCULATE;
            end
        end 
        FINISH:begin
            next_state     = IDLE;           
        end
    endcase
end

always @(posedge clk) begin
    case (state)
        IDLE: begin
            if(div_en_in)begin
                div_en_out             <= 0;
                stall_by_div <= 1;
                div_result             <= 0;
                div_addr_out           <= 0;
                i                      <= 0;
                dividend               <= a;
                divisor                <= b;
                op                     <= div_op;
                dividend_sign          <= div_sign?div_sr0[31]:0;
                divisor_sign           <= div_sign?div_sr1[31]:0;
                addr                   <= div_addr_in;
                qoucient               <= 0;
                m                      <= m_pre;
                n                      <= n_pre;
                div_pc                 <= div_pc_in;
                div_inst               <= div_inst_in;
            end else begin
                {div_en_out,
                stall_by_div,
                div_result,
                div_addr_out,
                i,
                dividend,
                divisor,
                op,
                dividend_sign,
                divisor_sign,
                addr,
                qoucient,
                m,
                n,
                div_pc,
                div_inst}               <= 0;
            end
        end
        PREPARE:begin
            if(m<n||n==0)begin
                div_en_out             <= 0;
                stall_by_div <= 1;
                div_result             <= op?(dividend_sign?~dividend+1:dividend):(divisor_sign==dividend_sign?qoucient:~qoucient+1);
                div_addr_out           <= addr;
                i                      <= 0;
                dividend               <= 0;
                divisor                <= 0;
                op                     <= 0;
                dividend_sign          <= 0;
                divisor_sign           <= 0;
                addr                   <= 0;
                qoucient               <= 0;
                m                      <= 0;
                n                      <= 0;
                div_pc                 <= div_pc;
                div_inst               <= div_inst;
            end else begin
                div_en_out             <= 0;
                stall_by_div <= 1;
                div_result             <= 0;
                div_addr_out           <= 0;
                i                      <= i+1;
                dividend               <= dividend;
                divisor                <= divisor<<m-n;
                op                     <= op;
                dividend_sign          <= dividend_sign;
                divisor_sign           <= divisor_sign;
                addr                   <= addr;
                qoucient               <= 0;
                m                      <= m;
                n                      <= n;
                div_pc                 <= div_pc;
                div_inst               <= div_inst;
            end
        end
        CALCULATE:begin
            if(i==m-n+2)begin
                div_en_out             <= 0;
                stall_by_div <= 1;
                div_result             <= op?(dividend_sign?~dividend+1:dividend):(divisor_sign==dividend_sign?qoucient:~qoucient+1);
                div_addr_out           <= addr;
                i                      <= 0;
                dividend               <= 0;
                divisor                <= 0;
                op                     <= 0;
                dividend_sign          <= 0;
                divisor_sign           <= 0;
                addr                   <= 0;
                qoucient               <= 0;
                m                      <= 0;
                n                      <= 0;
                div_pc                 <= div_pc;
                div_inst               <= div_inst;
            end else begin
                div_en_out             <= 0;
                stall_by_div <= 1;
                div_result             <= 0;
                div_addr_out           <= 0;
                i                      <= i+1;
                dividend               <= dividend>=divisor?dividend-divisor:dividend;
                divisor                <= {1'b0,divisor[31:1]};
                op                     <= op;
                dividend_sign          <= dividend_sign;
                divisor_sign           <= divisor_sign;
                addr                   <= addr;
                qoucient               <= dividend>=divisor?{qoucient[30:0],1'b1}:{qoucient[30:0],1'b0};
                m                      <= m;
                n                      <= n;
                div_pc                 <= div_pc;
                div_inst               <= div_inst;
            end
        end 
        FINISH:begin
            div_en_out                 <= 1;
            stall_by_div     <= 0;
            div_pc                     <= div_pc;
            div_inst                   <= div_inst;
            // div_result<=0;
            // div_addr_out<=0;
            // i<=0;
            // dividend<=0;
            // divisor<=0;
            // op<=0;
            // dividend_sign<=0;
            // divisor_sign<=0;
            // addr<=0;
            // qoucient<=0;
            // m<=0;
            // n<=0;
        end
    endcase
end
endmodule