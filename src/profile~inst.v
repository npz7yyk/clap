`include "clap_config.vh"

module profile_inst_statisic
#(
    FILENAME = "../profile_inst.log"
)(
    input clk,
    input cmt_valid0,
    input [31:0] cmt_inst0,
    input [6:0] cmt_excp0,
    input cmt_valid1,
    input [31:0] cmt_inst1,
    input [6:0] cmt_excp1
);
    integer fd;
    initial begin
        fd = $fopen(FILENAME,"wb");
    end

    always @(posedge clk) begin
        if(cmt_valid0) begin
            $fdisplay(fd, "%08h %02h",cmt_inst0,cmt_excp0);
        end
        if(cmt_valid1) begin
            $fdisplay(fd,"%08h %02h",cmt_inst1,cmt_excp1);
        end
        if(cmt_valid0||cmt_valid1)
            $fflush(fd);
    end
endmodule
