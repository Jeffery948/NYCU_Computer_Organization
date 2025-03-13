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
wire branch, memRead, memWrite, ALUSrc, regWrite, zero, jump, memtoReg;
wire [1:0] ALUOp, select;
wire [3:0] alu_control;
wire [63:0] IFID_out;
wire [145:0] IDEX_out;
wire [107:0] EXMEM_out;
wire [71:0] MEMWB_out;

assign select = (EXMEM_out[106] == 1'b1) ? ((EXMEM_out[107] == 1'b1) ? 2'b01 : 2'b10) : ((EXMEM_out[107] == 1'b1 && EXMEM_out[69] == 1'b1) ? 2'b01 : 2'b00);
// jump EXMEM_out[106]
// branch EXMEM_out[107]
// zero EXMEM[69]

/*if (jump == 1'b1)
    if (branch == 1'b1)
        assign select = 2'b01;
    else
        assign select = 2'b10;
else
    if (branch == 1'b1 && zero == 1'b1)
        assign select = 2'b01;
    else
        assign select = 2'b00;*/

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

PipelineReg #(.size(64)) IFID(
    .clk(clk),
    .rst(start),
    .data_i({pc_out, ins_out}),
    .data_o(IFID_out)
);

Control m_Control(
    .opcode(IFID_out[6:0]), // opcode
    .branch(branch),
    .jump(jump),
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
    .regWrite(MEMWB_out[69]), //regWrite
    .readReg1(IFID_out[19:15]),
    .readReg2(IFID_out[24:20]),
    .writeReg(MEMWB_out[4:0]), // inst_out[11:7]
    .writeData(write),
    .readData1(read1),
    .readData2(read2)
);

// ======= for validation ======= 
// == Dont change this section ==
assign r = m_Register.regs;
// ======= for vaildation =======

ImmGen m_ImmGen(
    .inst(IFID_out[31:0]),
    .imm(imm_out)
);

PipelineReg #(.size(146)) IDEX(
    .clk(clk),
    .rst(start),
    .data_i({branch, jump, memRead, memtoReg, ALUOp, memWrite, ALUSrc, regWrite,
            IFID_out[63:32], read1, read2, imm_out, IFID_out[30], IFID_out[14:12],
            IFID_out[11:7]}),
    .data_o(IDEX_out)
);

ShiftLeftOne m_ShiftLeftOne(
    .i(IDEX_out[40:9]), // imm_out
    .o(imm_shift)
);

Adder m_Adder_2(
    .a(IDEX_out[136:105]), // pc_out
    .b(imm_shift),
    .sum(pc_pls_imm)
);

Mux4to1 #(.size(32)) m_Mux_PC(
    .sel(select),
    .s0(pc_plus4),
    .s1(EXMEM_out[101:70]), // pc_plus_imm
    .s2(EXMEM_out[68:37]), // alu_out
    .out(pc_in)
);

Mux2to1 #(.size(32)) m_Mux_ALU(
    .sel(IDEX_out[138]), // ALUsrc
    .s0(IDEX_out[72:41]), // read2
    .s1(IDEX_out[40:9]), // imm_out
    .out(alu_in)
);

ALUCtrl m_ALUCtrl(
    .ALUOp(IDEX_out[141:140]), // ALUop
    .funct7(IDEX_out[8]), // ins_out[30]
    .funct3(IDEX_out[7:5]), // ins_out[14:12]
    .ALUCtl(alu_control)
);

ALU m_ALU(
    .ALUctl(alu_control),
    .A(IDEX_out[104:73]), // read1
    .B(alu_in),
    .ALUOut(alu_out),
    .zero(zero)
);

PipelineReg #(.size(108)) EXMEM(
    .clk(clk),
    .rst(start),
    .data_i({IDEX_out[145:142], IDEX_out[139], IDEX_out[137], pc_pls_imm, zero,
            alu_out, IDEX_out[72:41], IDEX_out[4:0]}),
    .data_o(EXMEM_out)
);

DataMemory m_DataMemory(
    .rst(start),
    .clk(clk),
    .memWrite(EXMEM_out[103]), // memWrite
    .memRead(EXMEM_out[105]), // memRead
    .address(EXMEM_out[68:37]), // alu_out
    .writeData(EXMEM_out[36:5]), // read2
    .readData(read)
);

PipelineReg #(.size(72)) MEMWB(
    .clk(clk),
    .rst(start),
    .data_i({EXMEM_out[106], EXMEM_out[104], EXMEM_out[102], read, EXMEM_out[68:37],
            EXMEM_out[4:0]}),
    .data_o(MEMWB_out)
);

Mux4to1 #(.size(32)) m_Mux_WriteData(
    .sel({MEMWB_out[71], MEMWB_out[70]}), // jump and memtoReg
    .s0(MEMWB_out[36:5]), //alu_out
    .s1(MEMWB_out[68:37]), //read
    .s2(pc_plus4),
    .out(write)
);

endmodule
