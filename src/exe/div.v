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
    output reg[ 4:0 ]div_addr_out
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
wire [4:0]m;
wire [4:0]n;

assign a=div_sign?div_sr0[31]==1?~div_sr0+1:div_sr0:div_sr0;
assign b=div_sign?div_sr1[31]==1?~div_sr1+1:div_sr1:div_sr1;

assign dividend_one_hot=a&(~a+1);
assign divisor_one_hot=b&(~b+1);

assign m=dividend_one_hot== 32'b1000_0000_0000_0000_0000_0000_0000_0000 ?32:
        dividend_one_hot== 32'b0100_0000_0000_0000_0000_0000_0000_0000 ?31:
        dividend_one_hot== 32'b0010_0000_0000_0000_0000_0000_0000_0000 ?30:
        dividend_one_hot== 32'b0001_0000_0000_0000_0000_0000_0000_0000 ?29:
        dividend_one_hot== 32'b0000_1000_0000_0000_0000_0000_0000_0000 ?28:
        dividend_one_hot== 32'b0000_0100_0000_0000_0000_0000_0000_0000 ?27:
        dividend_one_hot== 32'b0000_0010_0000_0000_0000_0000_0000_0000 ?26:
        dividend_one_hot== 32'b0000_0001_0000_0000_0000_0000_0000_0000 ?25:
        dividend_one_hot== 32'b0000_0000_1000_0000_0000_0000_0000_0000 ?24:
        dividend_one_hot== 32'b0000_0000_0100_0000_0000_0000_0000_0000 ?23:
        dividend_one_hot== 32'b0000_0000_0010_0000_0000_0000_0000_0000 ?22:
        dividend_one_hot== 32'b0000_0000_0001_0000_0000_0000_0000_0000 ?21:
        dividend_one_hot== 32'b0000_0000_0000_1000_0000_0000_0000_0000 ?20:
        dividend_one_hot== 32'b0000_0000_0000_0100_0000_0000_0000_0000 ?19:
        dividend_one_hot== 32'b0000_0000_0000_0010_0000_0000_0000_0000 ?18:
        dividend_one_hot== 32'b0000_0000_0000_0001_0000_0000_0000_0000 ?17:
        dividend_one_hot== 32'b0000_0000_0000_0000_1000_0000_0000_0000 ?16:
        dividend_one_hot== 32'b0000_0000_0000_0000_0100_0000_0000_0000 ?15:
        dividend_one_hot== 32'b0000_0000_0000_0000_0010_0000_0000_0000 ?14:
        dividend_one_hot== 32'b0000_0000_0000_0000_0001_0000_0000_0000 ?13:
        dividend_one_hot== 32'b0000_0000_0000_0000_0000_1000_0000_0000 ?12:
        dividend_one_hot== 32'b0000_0000_0000_0000_0000_0100_0000_0000 ?11:
        dividend_one_hot== 32'b0000_0000_0000_0000_0000_0010_0000_0000 ?10:
        dividend_one_hot== 32'b0000_0000_0000_0000_0000_0001_0000_0000 ?9:
        dividend_one_hot== 32'b0000_0000_0000_0000_0000_0000_1000_0000 ?8:
        dividend_one_hot== 32'b0000_0000_0000_0000_0000_0000_0100_0000 ?7:
        dividend_one_hot== 32'b0000_0000_0000_0000_0000_0000_0010_0000 ?6:
        dividend_one_hot== 32'b0000_0000_0000_0000_0000_0000_0001_0000 ?5:
        dividend_one_hot== 32'b0000_0000_0000_0000_0000_0000_0000_1000 ?4:
        dividend_one_hot== 32'b0000_0000_0000_0000_0000_0000_0000_0100 ?3:
        dividend_one_hot== 32'b0000_0000_0000_0000_0000_0000_0000_0010 ?2:
        dividend_one_hot== 32'b0000_0000_0000_0000_0000_0000_0000_0001 ?1:0;

assign n=divisor_one_hot== 32'b1000_0000_0000_0000_0000_0000_0000_0000 ?32:
        divisor_one_hot== 32'b0100_0000_0000_0000_0000_0000_0000_0000 ?31:
        divisor_one_hot== 32'b0010_0000_0000_0000_0000_0000_0000_0000 ?30:
        divisor_one_hot== 32'b0001_0000_0000_0000_0000_0000_0000_0000 ?29:
        divisor_one_hot== 32'b0000_1000_0000_0000_0000_0000_0000_0000 ?28:
        divisor_one_hot== 32'b0000_0100_0000_0000_0000_0000_0000_0000 ?27:
        divisor_one_hot== 32'b0000_0010_0000_0000_0000_0000_0000_0000 ?26:
        divisor_one_hot== 32'b0000_0001_0000_0000_0000_0000_0000_0000 ?25:
        divisor_one_hot== 32'b0000_0000_1000_0000_0000_0000_0000_0000 ?24:
        divisor_one_hot== 32'b0000_0000_0100_0000_0000_0000_0000_0000 ?23:
        divisor_one_hot== 32'b0000_0000_0010_0000_0000_0000_0000_0000 ?22:
        divisor_one_hot== 32'b0000_0000_0001_0000_0000_0000_0000_0000 ?21:
        divisor_one_hot== 32'b0000_0000_0000_1000_0000_0000_0000_0000 ?20:
        divisor_one_hot== 32'b0000_0000_0000_0100_0000_0000_0000_0000 ?19:
        divisor_one_hot== 32'b0000_0000_0000_0010_0000_0000_0000_0000 ?18:
        divisor_one_hot== 32'b0000_0000_0000_0001_0000_0000_0000_0000 ?17:
        divisor_one_hot== 32'b0000_0000_0000_0000_1000_0000_0000_0000 ?16:
        divisor_one_hot== 32'b0000_0000_0000_0000_0100_0000_0000_0000 ?15:
        divisor_one_hot== 32'b0000_0000_0000_0000_0010_0000_0000_0000 ?14:
        divisor_one_hot== 32'b0000_0000_0000_0000_0001_0000_0000_0000 ?13:
        divisor_one_hot== 32'b0000_0000_0000_0000_0000_1000_0000_0000 ?12:
        divisor_one_hot== 32'b0000_0000_0000_0000_0000_0100_0000_0000 ?11:
        divisor_one_hot== 32'b0000_0000_0000_0000_0000_0010_0000_0000 ?10:
        divisor_one_hot== 32'b0000_0000_0000_0000_0000_0001_0000_0000 ?9:
        divisor_one_hot== 32'b0000_0000_0000_0000_0000_0000_1000_0000 ?8:
        divisor_one_hot== 32'b0000_0000_0000_0000_0000_0000_0100_0000 ?7:
        divisor_one_hot== 32'b0000_0000_0000_0000_0000_0000_0010_0000 ?6:
        divisor_one_hot== 32'b0000_0000_0000_0000_0000_0000_0001_0000 ?5:
        divisor_one_hot== 32'b0000_0000_0000_0000_0000_0000_0000_1000 ?4:
        divisor_one_hot== 32'b0000_0000_0000_0000_0000_0000_0000_0100 ?3:
        divisor_one_hot== 32'b0000_0000_0000_0000_0000_0000_0000_0010 ?2:
        divisor_one_hot== 32'b0000_0000_0000_0000_0000_0000_0000_0001 ?1:0;

always @(posedge clk) begin
    if(i==0&&div_en_in)begin
        if(m<n||n==0)begin
            div_result<=div_op?0:div_sr0;
            div_addr_out<=div_addr_in;
            stall_because_div<=0;
            div_en_out<=div_en_in;
        end else begin
            op<=div_op;
            addr<=div_addr_in;
            dividend<=a;
            divisor<=b<<m-n;
            dividend_sign<=div_sign?div_sr0[31]:0;
            divisor_sign<=div_sign?div_sr1[31]:0;
            i=i+m-n+2;
            stall_because_div<=1;
            div_en_out<=0;
        end
    end else if(i==1)begin
        i<=0;
        stall_because_div<=0;
        div_result<=op?(divisor_sign==dividend_sign?qoucient:~qoucient+1):(dividend_sign?~dividend+1:dividend);
        div_addr_out<=addr;
        div_en_out<=1;
    end else begin
        i=i-1;
        if (dividend>=divisor) begin
            dividend<=dividend-divisor;
            qoucient<={qoucient[30:0],1'b1};
        end else begin
            qoucient<={qoucient[30:0],1'b0};
        end
        divisor=divisor>>1;
    end 
end
endmodule