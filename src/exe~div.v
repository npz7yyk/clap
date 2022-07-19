module div(
    input clk,
    input rstn,
    
    input div_en_in,
    input div_op,   
    input div_sign,
    input [ 31:0 ] div_sr0,
    input [ 31:0 ] div_sr1,
    input [ 4:0 ]div_addr_in,

    output reg div_en_out,
    output reg stall_because_div,
    output reg [ 31:0 ] div_result,
    output reg[ 4:0 ]div_addr_out,

    output reg div_en_out_quick,
    output reg [ 31:0 ] div_result_quick,
    output reg[ 4:0 ]div_addr_out_quick
);

reg [5:0]i;
reg [63:0]dividend;
reg [63:0]divisor;
reg [0:0]op;
reg [0:0]dividend_sign;
reg [0:0]divisor_sign;
reg [4:0]addr;
reg [31:0]qoucient;

wire [31:0]dividend_one_hot;
wire [31:0]divisor_one_hot;
wire [5:0]m;
wire [5:0]n;
wire [31:0]a;
wire[31:0]b;


assign a=div_sign?div_sr0[31]==1?~div_sr0+1:div_sr0:div_sr0;
assign b=div_sign?div_sr1[31]==1?~div_sr1+1:div_sr1:div_sr1;

exe_log2_plus_one log2_1(a,m);
exe_log2_plus_one log2_2(b,n);

always @(posedge clk) begin
    if(!rstn||div_en_out)begin
        div_en_out<=0;
        stall_because_div<=0;
        div_result<=0;
        div_addr_out<=0;
        i<=0;
        dividend<=0;
        divisor<=0;
        op<=0;
        dividend_sign<=0;
        divisor_sign<=0;
        addr<=0;
        qoucient<=0;
    end else if(i==0&&div_en_in)begin
        if(m<n||n==0)begin
            div_result_quick<=div_op? div_sr0:0;
            div_en_out_quick<=1;
            div_addr_out_quick<=div_addr_in;
        end else begin
            op<=div_op;
            addr<=div_addr_in;
            dividend<=a;
            divisor<=b<<m-n;
            dividend_sign<=div_sign?div_sr0[31]:0;
            divisor_sign<=div_sign?div_sr1[31]:0;
            i<=i+m-n+2;
            stall_because_div<=1;
            div_en_out<=0;
            div_result<=0;
            qoucient<=0;
            div_result_quick<=0;
            div_en_out_quick<=0;
            div_addr_out_quick<=0;
        end
    end else if(i==1)begin
        i<=0;
        div_result<=op?(dividend_sign?~dividend+1:dividend):(divisor_sign==dividend_sign?qoucient:~qoucient+1);
        div_addr_out<=addr;
        div_en_out<=1;
        // div_result_quick<=op?(dividend_sign?~dividend+1:dividend):(divisor_sign==dividend_sign?qoucient:~qoucient+1);
        // div_addr_out_quick<=addr;
        // div_en_out_quick<=1;
    end else if(i>0)begin
        i<=i-1;
        if (dividend>=divisor) begin
            dividend<=dividend-divisor;
            qoucient<={qoucient[30:0],1'b1};
        end else begin
            qoucient<={qoucient[30:0],1'b0};
        end
        divisor <= divisor>>1;
    end else begin
        div_en_out<=0;
        div_result<=0;
        div_addr_out<=0;
        stall_because_div<=0;
        div_en_out_quick<=0;
        div_result_quick<=0;
        div_addr_out_quick<=0;
    end
end
endmodule
