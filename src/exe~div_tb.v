module tb_div;

// div Parameters
parameter PERIOD  = 10;


// div Inputs
reg   clk                                  = 0 ;
reg   rstn                                 = 0 ;
reg   div_en_in                            = 0 ;
reg   div_op                               = 0 ;
reg   div_sign                             = 0 ;
reg   [ 31:0 ]  div_sr0                    = 0 ;
reg   [ 31:0 ]  div_sr1                    = 0 ;
reg   [ 4:0 ]  div_addr_in                 = 0 ;

// div Outputs
wire  div_en_out                           ;
wire  stall_because_div                    ;
wire  [ 31:0 ]  div_result                 ;
wire  [ 4:0 ]div_addr_out               ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rstn  =  1;
end

div  u_div (
    .clk                     ( clk                              ),
    .rstn                    ( rstn                             ),
    .div_en_in               ( div_en_in                        ),
    .div_op                  ( div_op                           ),
    .div_sign                ( div_sign                         ),
    .div_sr0                 ( div_sr0                 [ 31:0 ] ),
    .div_sr1                 ( div_sr1                 [ 31:0 ] ),
    .div_addr_in             ( div_addr_in             [ 4:0 ]  ),

    .div_en_out              ( div_en_out                       ),
    .stall_because_div       ( stall_because_div                ),
    .div_result              ( div_result              [ 31:0 ] ),
    .div_addr_out            ( div_addr_out           )
);

initial
begin
    div_sign=1;
    div_op=1;
    div_sr0=-1;
    div_sr1=-1;
    div_en_in=1;
    //$finish;
end

endmodule
