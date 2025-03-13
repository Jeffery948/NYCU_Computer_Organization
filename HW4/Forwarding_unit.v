module Forwarding_unit (
    input regWrite_m,
    input regWrite_w,
    input [4:0] rs1, rs2, rdm, rdw,
    output reg [1:0] forwardA, forwardB
);

    always @(*) begin
        if(regWrite_m && rdm != 0 && rdm == rs1) begin
            forwardA = 2'b10;
        end
        else if(regWrite_w && rdw != 0 && rdw == rs1) begin
            forwardA = 2'b01;
        end
        else begin
            forwardA = 2'b00;
        end

        if(regWrite_m && rdm != 0 && rdm == rs2) begin
            forwardB = 2'b10;
        end
        else if(regWrite_w && rdw != 0 && rdw == rs2) begin
            forwardB = 2'b01;
        end
        else begin
            forwardB = 2'b00;
        end
    end

endmodule
