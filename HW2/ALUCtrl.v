module ALUCtrl (
    input [1:0] ALUOp,
    input funct7,
    input [2:0] funct3,
    output reg [3:0] ALUCtl
);

    // TODO: implement your ALU control here
    // For testbench verifying, Do not modify input and output pin
    // Hint: using ALUOp, funct7, funct3 to select exact operation
    always @(*) begin
        casez({ALUOp, funct7, funct3})
            6'b00_?_???: // ld, sd, jal, jalr
                ALUCtl = 4'b0010;
            6'b01_?_000: // beq
                ALUCtl = 4'b0110;
            6'b01_?_001: // bne
                ALUCtl = 4'b1000;
            6'b01_?_100: // blt
                ALUCtl = 4'b1001;
            6'b01_?_101: // bge
                ALUCtl = 4'b1010;
            6'b10_0_000: // add
                ALUCtl = 4'b0010;
            6'b10_1_000: // sub
                ALUCtl = 4'b0110;
            6'b10_0_111: // and
                ALUCtl = 4'b0000;
            6'b10_0_110: // or
                ALUCtl = 4'b0001;
            6'b10_0_010: // slt
                ALUCtl = 4'b0111;
            6'b11_?_000: // addi
                ALUCtl = 4'b0010;
            6'b11_?_111: // andi
                ALUCtl = 4'b0000;
            6'b11_?_110: // ori
                ALUCtl = 4'b0001;
            6'b11_?_010: // slti
                ALUCtl = 4'b0111;
            default:
                ALUCtl = 4'bx;
        endcase
    end

endmodule

