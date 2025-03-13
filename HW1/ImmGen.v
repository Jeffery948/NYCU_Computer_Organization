module ImmGen (
    /* verilator lint_off UNUSEDSIGNAL */
    input [31:0] inst,
    output reg signed [31:0] imm
);
    // ImmGen generate imm value base opcode

    wire [6:0] opcode = inst[6:0];
    always @(*) begin
        case(opcode)
            // TODO: implement your ImmGen here
            // Hint: follow the RV32I opcode map (table in spec) to set imm value
            7'b1100011: // beq
                imm = {{21{inst[31]}}, inst[7], inst[30:25], inst[11:8]};
            7'b0000011: // lw
                imm = {{21{inst[31]}}, inst[30:20]};
            7'b0100011: // sw
                imm = {{21{inst[31]}}, inst[30:25], inst[11:7]};
            7'b0010011: // addi, andi, ori, slti
                imm = {{21{inst[31]}}, inst[30:20]};
            default:
                imm = 32'bx;
            
        endcase
    end

endmodule

