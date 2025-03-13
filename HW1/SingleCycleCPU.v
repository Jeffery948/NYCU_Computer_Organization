module SingleCycleCPU (
    input clk,
    input start,
    output signed [31:0] r [0:31]
);

// When input start is zero, cpu should reset
// When input start is high, cpu start running

// TODO: connect wire to realize SingleCycleCPU
// The following provides simple template,
// you can modify it as you wish except I/O pin and register module
wire [31:0] pc_in, pc_out, pc_plus4, ins_out, read1, read2, imm_out, imm_shift;
wire [31:0] pc_pls_imm, alu_in, alu_out, read, write;
wire branch, memRead, memtoReg, memWrite, ALUSrc, regWrite, zero, select;
wire [1:0] ALUOp;
wire [3:0] alu_control;

and a1(select, branch, zero);

PC m_PC(
    .clk(clk),
    .rst(start),
    .pc_i(pc_in),
    .pc_o(pc_out)
);

Adder m_Adder_1(
    .a(pc_out),
    .b(32'h00000004),
    .sum(pc_plus4)
);

InstructionMemory m_InstMem(
    .readAddr(pc_out),
    .inst(ins_out)
);

Control m_Control(
    .opcode(ins_out[6:0]),
    .branch(branch),
    .memRead(memRead),
    .memtoReg(memtoReg),
    .ALUOp(ALUOp),
    .memWrite(memWrite),
    .ALUSrc(ALUSrc),
    .regWrite(regWrite)
);

// For Student: 
// Do not change the Register instance name!
// Or you will fail validation.

Register m_Register(
    .clk(clk),
    .rst(start),
    .regWrite(regWrite),
    .readReg1(ins_out[19:15]),
    .readReg2(ins_out[24:20]),
    .writeReg(ins_out[11:7]),
    .writeData(write),
    .readData1(read1),
    .readData2(read2)
);

// ======= for validation ======= 
// == Dont change this section ==
assign r = m_Register.regs;
// ======= for vaildation =======

ImmGen m_ImmGen(
    .inst(ins_out),
    .imm(imm_out)
);

ShiftLeftOne m_ShiftLeftOne(
    .i(imm_out),
    .o(imm_shift)
);

Adder m_Adder_2(
    .a(pc_out),
    .b(imm_shift),
    .sum(pc_pls_imm)
);

Mux2to1 #(.size(32)) m_Mux_PC(
    .sel(select),
    .s0(pc_plus4),
    .s1(pc_pls_imm),
    .out(pc_in)
);

Mux2to1 #(.size(32)) m_Mux_ALU(
    .sel(ALUSrc),
    .s0(read2),
    .s1(imm_out),
    .out(alu_in)
);

ALUCtrl m_ALUCtrl(
    .ALUOp(ALUOp),
    .funct7(ins_out[30]),
    .funct3(ins_out[14:12]),
    .ALUCtl(alu_control)
);

ALU m_ALU(
    .ALUctl(alu_control),
    .A(read1),
    .B(alu_in),
    .ALUOut(alu_out),
    .zero(zero)
);

DataMemory m_DataMemory(
    .rst(start),
    .clk(clk),
    .memWrite(memWrite),
    .memRead(memRead),
    .address(alu_out),
    .writeData(read2),
    .readData(read)
);

Mux2to1 #(.size(32)) m_Mux_WriteData(
    .sel(memtoReg),
    .s0(alu_out),
    .s1(read),
    .out(write)
);

endmodule
