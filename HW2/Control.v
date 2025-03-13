module Control (
    input [6:0] opcode,
    output reg branch,
    output reg jump,
    output reg memRead,
    output reg memtoReg,
    output reg [1:0] ALUOp,
    output reg memWrite,
    output reg ALUSrc,
    output reg regWrite
);

    // TODO: implement your Control here
    // Hint: follow the Architecture (figure in spec) to set output signal
    always @(*) begin
        case(opcode)
            7'b0110011: // R-type
                begin
                    ALUSrc = 0;
                    memtoReg = 0;
                    regWrite = 1;
                    memRead = 0;
                    memWrite = 0;
                    branch = 0;
                    jump = 0;
                    ALUOp = 2'b10;
                end
            7'b0000011: // ld
                begin
                    ALUSrc = 1;
                    memtoReg = 1;
                    regWrite = 1;
                    memRead = 1;
                    memWrite = 0;
                    branch = 0;
                    jump = 0;
                    ALUOp = 2'b00;
                end
            7'b0100011: // sd
                begin
                    ALUSrc = 1;
                    memtoReg = 0;
                    regWrite = 0;
                    memRead = 0;
                    memWrite = 1;
                    branch = 0;
                    jump = 0;
                    ALUOp = 2'b00;
                end
            7'b1100011: // B-type
                begin
                    ALUSrc = 0;
                    memtoReg = 0;
                    regWrite = 0;
                    memRead = 0;
                    memWrite = 0;
                    branch = 1;
                    jump = 0;
                    ALUOp = 2'b01;
                end
            7'b0010011: // I-type
                begin
                    ALUSrc = 1;
                    memtoReg = 0;
                    regWrite = 1;
                    memRead = 0;
                    memWrite = 0;
                    branch = 0;
                    jump = 0;
                    ALUOp = 2'b11;
                end
            7'b1101111: // jal
                begin
                    ALUSrc = 1;
                    memtoReg = 0;
                    regWrite = 1;
                    memRead = 0;
                    memWrite = 0;
                    branch = 1;
                    jump = 1;
                    ALUOp = 2'b00;
                end
            7'b1100111: // jalr
                begin
                    ALUSrc = 1;
                    memtoReg = 0;
                    regWrite = 1;
                    memRead = 0;
                    memWrite = 0;
                    branch = 0;
                    jump = 1;
                    ALUOp = 2'b00;
                end
            default: // same as R-type
                begin
                    ALUSrc = 0;
                    memtoReg = 0;
                    regWrite = 1;
                    memRead = 0;
                    memWrite = 0;
                    branch = 0;
                    jump = 0;
                    ALUOp = 2'b10;
                end
        endcase
    end

endmodule

