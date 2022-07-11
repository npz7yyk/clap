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
wire [31:0]a;
wire[31:0]b;


assign a=div_sign?div_sr0[31]==1?~div_sr0+1:div_sr0:div_sr0;
assign b=div_sign?div_sr1[31]==1?~div_sr1+1:div_sr1:div_sr1;

assign dividend_one_hot={a[0],a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9]
                        ,a[10],a[11],a[12],a[13],a[14],a[15],a[16],a[17],a[18],a[19]
                        ,a[20],a[21],a[22],a[23],a[24],a[25],a[26],a[27],a[28],a[29],a[30],a[31]}
                        &(~{a[0],a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9]
                        ,a[10],a[11],a[12],a[13],a[14],a[15],a[16],a[17],a[18],a[19]
                        ,a[20],a[21],a[22],a[23],a[24],a[25],a[26],a[27],a[28],a[29],a[30],a[31]}+1);
assign divisor_one_hot={b[0],b[1],b[2],b[3],b[4],b[5],b[6],b[7],b[8],b[9]
                        ,b[10],b[11],b[12],b[13],b[14],b[15],b[16],b[17],b[18],b[19]
                        ,b[20],b[21],b[22],b[23],b[24],b[25],b[26],b[27],b[28],b[29],b[30],b[31]}
                        &(~{b[0],b[1],b[2],b[3],b[4],b[5],b[6],b[7],b[8],b[9]
                        ,b[10],b[11],b[12],b[13],b[14],b[15],b[16],b[17],b[18],b[19]
                        ,b[20],b[21],b[22],b[23],b[24],b[25],b[26],b[27],b[28],b[29],b[30],b[31]}+1);

assign m=dividend_one_hot== 32'b1000_0000_0000_0000_0000_0000_0000_0000 ?1:
        dividend_one_hot== 32'b0100_0000_0000_0000_0000_0000_0000_0000 ?2:
        dividend_one_hot== 32'b0010_0000_0000_0000_0000_0000_0000_0000 ?3:
        dividend_one_hot== 32'b0001_0000_0000_0000_0000_0000_0000_0000 ?4:
        dividend_one_hot== 32'b0000_1000_0000_0000_0000_0000_0000_0000 ?5:
        dividend_one_hot== 32'b0000_0100_0000_0000_0000_0000_0000_0000 ?6:
        dividend_one_hot== 32'b0000_0010_0000_0000_0000_0000_0000_0000 ?7:
        dividend_one_hot== 32'b0000_0001_0000_0000_0000_0000_0000_0000 ?8:
        dividend_one_hot== 32'b0000_0000_1000_0000_0000_0000_0000_0000 ?9:
        dividend_one_hot== 32'b0000_0000_0100_0000_0000_0000_0000_0000 ?10:
        dividend_one_hot== 32'b0000_0000_0010_0000_0000_0000_0000_0000 ?11:
        dividend_one_hot== 32'b0000_0000_0001_0000_0000_0000_0000_0000 ?12:
        dividend_one_hot== 32'b0000_0000_0000_1000_0000_0000_0000_0000 ?13:
        dividend_one_hot== 32'b0000_0000_0000_0100_0000_0000_0000_0000 ?14:
        dividend_one_hot== 32'b0000_0000_0000_0010_0000_0000_0000_0000 ?15:
        dividend_one_hot== 32'b0000_0000_0000_0001_0000_0000_0000_0000 ?16:
        dividend_one_hot== 32'b0000_0000_0000_0000_1000_0000_0000_0000 ?17:
        dividend_one_hot== 32'b0000_0000_0000_0000_0100_0000_0000_0000 ?18:
        dividend_one_hot== 32'b0000_0000_0000_0000_0010_0000_0000_0000 ?19:
        dividend_one_hot== 32'b0000_0000_0000_0000_0001_0000_0000_0000 ?20:
        dividend_one_hot== 32'b0000_0000_0000_0000_0000_1000_0000_0000 ?21:
        dividend_one_hot== 32'b0000_0000_0000_0000_0000_0100_0000_0000 ?22:
        dividend_one_hot== 32'b0000_0000_0000_0000_0000_0010_0000_0000 ?23:
        dividend_one_hot== 32'b0000_0000_0000_0000_0000_0001_0000_0000 ?24:
        dividend_one_hot== 32'b0000_0000_0000_0000_0000_0000_1000_0000 ?25:
        dividend_one_hot== 32'b0000_0000_0000_0000_0000_0000_0100_0000 ?26:
        dividend_one_hot== 32'b0000_0000_0000_0000_0000_0000_0010_0000 ?27:
        dividend_one_hot== 32'b0000_0000_0000_0000_0000_0000_0001_0000 ?28:
        dividend_one_hot== 32'b0000_0000_0000_0000_0000_0000_0000_1000 ?29:
        dividend_one_hot== 32'b0000_0000_0000_0000_0000_0000_0000_0100 ?30:
        dividend_one_hot== 32'b0000_0000_0000_0000_0000_0000_0000_0010 ?31:
        dividend_one_hot== 32'b0000_0000_0000_0000_0000_0000_0000_0001 ?32:0;

assign n=divisor_one_hot== 32'b1000_0000_0000_0000_0000_0000_0000_0000 ?1:
        divisor_one_hot== 32'b0100_0000_0000_0000_0000_0000_0000_0000 ?2:
        divisor_one_hot== 32'b0010_0000_0000_0000_0000_0000_0000_0000 ?3:
        divisor_one_hot== 32'b0001_0000_0000_0000_0000_0000_0000_0000 ?4:
        divisor_one_hot== 32'b0000_1000_0000_0000_0000_0000_0000_0000 ?5:
        divisor_one_hot== 32'b0000_0100_0000_0000_0000_0000_0000_0000 ?6:
        divisor_one_hot== 32'b0000_0010_0000_0000_0000_0000_0000_0000 ?7:
        divisor_one_hot== 32'b0000_0001_0000_0000_0000_0000_0000_0000 ?8:
        divisor_one_hot== 32'b0000_0000_1000_0000_0000_0000_0000_0000 ?9:
        divisor_one_hot== 32'b0000_0000_0100_0000_0000_0000_0000_0000 ?10:
        divisor_one_hot== 32'b0000_0000_0010_0000_0000_0000_0000_0000 ?11:
        divisor_one_hot== 32'b0000_0000_0001_0000_0000_0000_0000_0000 ?12:
        divisor_one_hot== 32'b0000_0000_0000_1000_0000_0000_0000_0000 ?13:
        divisor_one_hot== 32'b0000_0000_0000_0100_0000_0000_0000_0000 ?14:
        divisor_one_hot== 32'b0000_0000_0000_0010_0000_0000_0000_0000 ?15:
        divisor_one_hot== 32'b0000_0000_0000_0001_0000_0000_0000_0000 ?16:
        divisor_one_hot== 32'b0000_0000_0000_0000_1000_0000_0000_0000 ?17:
        divisor_one_hot== 32'b0000_0000_0000_0000_0100_0000_0000_0000 ?18:
        divisor_one_hot== 32'b0000_0000_0000_0000_0010_0000_0000_0000 ?19:
        divisor_one_hot== 32'b0000_0000_0000_0000_0001_0000_0000_0000 ?20:
        divisor_one_hot== 32'b0000_0000_0000_0000_0000_1000_0000_0000 ?21:
        divisor_one_hot== 32'b0000_0000_0000_0000_0000_0100_0000_0000 ?22:
        divisor_one_hot== 32'b0000_0000_0000_0000_0000_0010_0000_0000 ?23:
        divisor_one_hot== 32'b0000_0000_0000_0000_0000_0001_0000_0000 ?24:
        divisor_one_hot== 32'b0000_0000_0000_0000_0000_0000_1000_0000 ?25:
        divisor_one_hot== 32'b0000_0000_0000_0000_0000_0000_0100_0000 ?26:
        divisor_one_hot== 32'b0000_0000_0000_0000_0000_0000_0010_0000 ?27:
        divisor_one_hot== 32'b0000_0000_0000_0000_0000_0000_0001_0000 ?28:
        divisor_one_hot== 32'b0000_0000_0000_0000_0000_0000_0000_1000 ?29:
        divisor_one_hot== 32'b0000_0000_0000_0000_0000_0000_0000_0100 ?30:
        divisor_one_hot== 32'b0000_0000_0000_0000_0000_0000_0000_0010 ?31:
        divisor_one_hot== 32'b0000_0000_0000_0000_0000_0000_0000_0001 ?32:0;

always @(posedge clk) begin
    if(!rstn)begin
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
            div_result<=0;
            qoucient<=0;
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