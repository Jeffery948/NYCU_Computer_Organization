module PipelineCPU (
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
wire [31:0] pc_pls_imm, alu_in, alu_out, read, write, A_out, B_out;
wire branch, memRead, memWrite, ALUSrc, regWrite, jump, memtoReg, zero;
wire PCwrite, IFflush, IFIDwrite, control_signal, IDEXflush;
wire [1:0] ALUOp, select, forwardA, forwardB;
wire [3:0] alu_control;

wire [31:0] pc_plus4_IFID, ori_pc_IFID, inst_out_IFID;
wire [8:0] mux_control;

wire [31:0] read1_IDEX, read2_IDEX, imm_IDEX, pc_plus4_IDEX, ori_pc_IDEXE;
wire jump_IDEX, memtoReg_IDEX, regWrite_IDEX, memRead_IDEX, memWrite_IDEX, ALUSrc_IDEX, branch_IDEX;
wire [1:0] ALUOp_IDEX;
wire [3:0] alu_control_IDEX;
wire [4:0] rd_IDEX;
wire [9:0] rs;

wire [31:0] pc_plus4_EXMEM, alu_out_EXMEM, B_out_EXMEM;
wire jump_EXMEM, memtoReg_EXMEM, regWrite_EXMEM, memRead_EXMEM, memWrite_EXMEM;
wire [4:0] rd_EXMEM;

wire [31:0] pc_plus4_MEMWB, alu_out_MEMWB, read_MEMWB;
wire jump_MEMWB, memtoReg_MEMWB, regWrite_MEMWB;
wire [4:0] rd_MEMWB;

// assign select = (jump == 1'b1) ? ((branch == 1'b1) ? 2'b01 : 2'b10) : ((branch == 1'b1 && read1 == read2) ? 2'b01 : 2'b00);
// assign IFflush = (jump == 1'b1 || (branch == 1'b1 && read1 == read2)) ? 1'b1 : 1'b0;

// assign select = (jump_IDEX == 1'b1) ? ((branch_IDEX == 1'b1) ? 2'b01 : 2'b10) : ((branch_IDEX == 1'b1 && zero == 1'b1) ? 2'b01 : 2'b00);
assign IFflush = (jump_IDEX == 1'b1 || (branch_IDEX == 1'b1 && zero == 1'b1)) ? 1'b1 : 1'b0;
assign IDEXflush = ((jump_IDEX == 1'b1 || (branch_IDEX == 1'b1 && zero == 1'b1)) || (memRead_IDEX && (rd_IDEX == inst_out_IFID[19:15] || rd_IDEX == inst_out_IFID[24:20]))) ? 1'b1 : 1'b0;

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
    .PCwrite(PCwrite),
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

IFID m_IFID(
    .clk(clk),
    .rst(start),
    .IFflush(IFflush),
    .IFID_write(IFIDwrite),
    .pc_plus4_i(pc_plus4),
    .ori_pc_i(pc_out),
    .inst_i(ins_out),
    .pc_plus4_o(pc_plus4_IFID),
    .ori_pc_o(ori_pc_IFID),
    .inst_o(inst_out_IFID)
);

Hazard_detection_unit m_hazard_detection(  
    .IDEXE_memread(memRead_IDEX),
    .rs1(inst_out_IFID[19:15]),
    .rs2(inst_out_IFID[24:20]),
    .rde(rd_IDEX), // IDEXE rd
    .jump(jump_IDEX),
    .branch(branch_IDEX),
    .zero(zero),
    .PCwrite(PCwrite),
    .IFIDwrite(IFIDwrite),
    .control_signal(control_signal),
    .select(select)
);

Control m_Control(
    .opcode(inst_out_IFID[6:0]), // opcode
    .branch(branch),
    .jump(jump),
    .memRead(memRead),
    .memtoReg(memtoReg),
    .ALUOp(ALUOp),
    .memWrite(memWrite),
    .ALUSrc(ALUSrc),
    .regWrite(regWrite)
);

Mux2to1 #(.size(9)) m_Mux_control(
    .sel(control_signal), 
    .s0(9'b0),
    .s1({branch, jump, memRead, memtoReg, ALUOp, memWrite, ALUSrc, regWrite}),
    .out(mux_control)
);

// For Student: 
// Do not change the Register instance name!
// Or you will fail validation.

Register m_Register( 
    .clk(clk),
    .rst(start),
    .regWrite(regWrite_MEMWB), //regWrite
    .readReg1(inst_out_IFID[19:15]),
    .readReg2(inst_out_IFID[24:20]),
    .writeReg(rd_MEMWB), // inst_out[11:7]
    .writeData(write),
    .readData1(read1),
    .readData2(read2)
);

// ======= for validation ======= 
// == Dont change this section ==
assign r = m_Register.regs;
// ======= for vaildation =======

ImmGen m_ImmGen(
    .inst(inst_out_IFID),
    .imm(imm_out)
);


Mux4to1 #(.size(32)) m_Mux_PC(
    .sel(select),
    .s0(pc_plus4), // pc_plus4
    .s1(pc_pls_imm),
    .s2(alu_out), 
    .out(pc_in)
);

IDEX m_IDEX(
    .clk(clk),
    .rst(start),
    .IDEXflush(IDEXflush),
    .rs_i(inst_out_IFID[24:15]),
    .branch_IDEX_i(mux_control[8]),
    .jump_IDEX_i(mux_control[7]),
    .memtoReg_IDEX_i(mux_control[5]),
    .regWrite_IDEX_i(mux_control[0]),
    .memRead_IDEX_i(mux_control[6]),
    .memWrite_IDEX_i(mux_control[2]),
    .ALUSrc_IDEX_i(mux_control[1]),
    .ALUOp_IDEX_i(mux_control[4:3]),
    .read1_i(read1),
    .read2_i(read2),
    .imm_i(imm_out),
    .alu_ctrl_i({inst_out_IFID[30], inst_out_IFID[14:12]}),
    .rd_i(inst_out_IFID[11:7]),
    .pc_plus4_i(pc_plus4_IFID),
    .ori_pc_i(ori_pc_IFID),
    .rs_o(rs),
    .branch_IDEX_o(branch_IDEX),
    .jump_IDEX_o(jump_IDEX),
    .memtoReg_IDEX_o(memtoReg_IDEX),
    .regWrite_IDEX_o(regWrite_IDEX),
    .memRead_IDEX_o(memRead_IDEX),
    .memWrite_IDEX_o(memWrite_IDEX),
    .ALUSrc_IDEX_o(ALUSrc_IDEX),
    .ALUOp_IDEX_o(ALUOp_IDEX),
    .read1_o(read1_IDEX),
    .read2_o(read2_IDEX),
    .imm_o(imm_IDEX),
    .alu_ctrl_o(alu_control_IDEX),
    .rd_o(rd_IDEX),
    .pc_plus4_o(pc_plus4_IDEX),
    .ori_pc_o(ori_pc_IDEXE)
);

ShiftLeftOne m_ShiftLeftOne(
    .i(imm_IDEX), // imm_out
    .o(imm_shift)
);

Adder m_Adder_2(
    .a(ori_pc_IDEXE), // pc_out
    .b(imm_shift),
    .sum(pc_pls_imm)
);

Forwarding_unit m_forward( 
    .regWrite_m(regWrite_EXMEM),
    .regWrite_w(regWrite_MEMWB),
    .rs1(rs[4:0]),
    .rs2(rs[9:5]),
    .rdm(rd_EXMEM),
    .rdw(rd_MEMWB),
    .forwardA(forwardA),
    .forwardB(forwardB)
);

Mux4to1 #(.size(32)) m_Mux_A( 
    .sel(forwardA),
    .s0(read1_IDEX), // read1
    .s1(write),
    .s2(alu_out_EXMEM), // EXE ALU result
    .out(A_out)
);

Mux4to1 #(.size(32)) m_Mux_B( 
    .sel(forwardB),
    .s0(read2_IDEX), // read2
    .s1(write),
    .s2(alu_out_EXMEM), // EXE ALU result
    .out(B_out)
);

Mux2to1 #(.size(32)) m_Mux_ALU(
    .sel(ALUSrc_IDEX), // ALUsrc
    .s0(B_out), // read2
    .s1(imm_IDEX), // imm_out
    .out(alu_in)
);

ALUCtrl m_ALUCtrl(
    .ALUOp(ALUOp_IDEX), // ALUop
    .funct7(alu_control_IDEX[3]), // ins_out[30]
    .funct3(alu_control_IDEX[2:0]), // ins_out[14:12]
    .ALUCtl(alu_control)
);

ALU m_ALU(
    .ALUctl(alu_control),
    .A(A_out), // read1
    .B(alu_in),
    .ALUOut(alu_out),
    .zero(zero)
);

EXMEM m_EXMEM(
    .clk(clk),
    .rst(start),
    .jump_EXMEM_i(jump_IDEX),
    .memtoReg_EXMEM_i(memtoReg_IDEX),
    .regWrite_EXMEM_i(regWrite_IDEX),
    .memRead_EXMEM_i(memRead_IDEX),
    .memWrite_EXMEM_i(memWrite_IDEX),
    .alu_out_i(alu_out),
    .B_out_i(B_out),
    .rd_i(rd_IDEX),
    .pc_plus4_i(pc_plus4_IDEX),
    .jump_EXMEM_o(jump_EXMEM),
    .memtoReg_EXMEM_o(memtoReg_EXMEM),
    .regWrite_EXMEM_o(regWrite_EXMEM),
    .memRead_EXMEM_o(memRead_EXMEM),
    .memWrite_EXMEM_o(memWrite_EXMEM),
    .alu_out_o(alu_out_EXMEM),
    .B_out_o(B_out_EXMEM),
    .rd_o(rd_EXMEM),
    .pc_plus4_o(pc_plus4_EXMEM)
);

DataMemory m_DataMemory(
    .rst(start),
    .clk(clk),
    .memWrite(memWrite_EXMEM), // memWrite
    .memRead(memRead_EXMEM), // memRead
    .address(alu_out_EXMEM), // alu_out
    .writeData(B_out_EXMEM), // read2
    .readData(read)
);

MEMWB m_MEMWB(
    .clk(clk),
    .rst(start),
    .jump_MEMWB_i(jump_EXMEM),
    .memtoReg_MEMWB_i(memtoReg_EXMEM),
    .regWrite_MEMWB_i(regWrite_EXMEM),
    .read_i(read),
    .alu_out_i(alu_out_EXMEM),
    .rd_i(rd_EXMEM),
    .pc_plus4_i(pc_plus4_EXMEM),
    .jump_MEMWB_o(jump_MEMWB),
    .memtoReg_MEMWB_o(memtoReg_MEMWB),
    .regWrite_MEMWB_o(regWrite_MEMWB),
    .read_o(read_MEMWB),
    .alu_out_o(alu_out_MEMWB),
    .rd_o(rd_MEMWB),
    .pc_plus4_o(pc_plus4_MEMWB)
);

Mux4to1 #(.size(32)) m_Mux_WriteData(
    .sel({jump_MEMWB, memtoReg_MEMWB}), // jump and memtoReg
    .s0(alu_out_MEMWB), //alu_out
    .s1(read_MEMWB), //read
    .s2(pc_plus4_MEMWB),
    .out(write)
);

endmodule
