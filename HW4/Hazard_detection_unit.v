module Hazard_detection_unit (
    input IDEXE_memread,
    input [4:0] rs1, rs2, rde,
    input jump,
    input branch,
    input zero,
    output reg PCwrite,
    output reg IFIDwrite,
    output reg control_signal,
    output reg [1:0] select
);

    always @(*) begin
        if(IDEXE_memread && (rde == rs1 || rde == rs2)) begin // stall
            PCwrite = 1'b0;
            IFIDwrite = 1'b0;
            control_signal = 1'b0;
        end
        else if(jump || (branch && zero)) begin // branch taken
            PCwrite = 1'b1;
            IFIDwrite = 1'b0;
            control_signal = 1'b0;
        end
        else begin
            PCwrite = 1'b1;
            IFIDwrite = 1'b1;
            control_signal = 1'b1;
        end
        assign select = (jump) ? ((branch) ? 2'b01 : 2'b10) : ((branch && zero) ? 2'b01 : 2'b00);
    end

endmodule
