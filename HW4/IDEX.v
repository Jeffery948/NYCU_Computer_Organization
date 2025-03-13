module IDEX (
    input clk,
    input rst,
    input IDEXflush,
    input [9:0] rs_i,
    input branch_IDEX_i,
    input jump_IDEX_i,
    input memtoReg_IDEX_i,
    input regWrite_IDEX_i,
    input memRead_IDEX_i,
    input memWrite_IDEX_i,
    input ALUSrc_IDEX_i,
    input [1:0] ALUOp_IDEX_i,
    input [31:0] read1_i,
    input [31:0] read2_i,
    input [31:0] imm_i,
    input [3:0] alu_ctrl_i,
    input [4:0] rd_i,
    input [31:0] pc_plus4_i,
    input [31:0] ori_pc_i,
    output reg [9:0] rs_o,
    output reg branch_IDEX_o,
    output reg jump_IDEX_o,
    output reg memtoReg_IDEX_o,
    output reg regWrite_IDEX_o,
    output reg memRead_IDEX_o,
    output reg memWrite_IDEX_o,
    output reg ALUSrc_IDEX_o,
    output reg [1:0] ALUOp_IDEX_o,
    output reg [31:0] read1_o,
    output reg [31:0] read2_o,
    output reg [31:0] imm_o,
    output reg [3:0] alu_ctrl_o,
    output reg [4:0] rd_o,
    output reg [31:0] pc_plus4_o,
    output reg [31:0] ori_pc_o
);

    always @(posedge clk, negedge rst) begin
        if(!rst) begin
            rs_o <= 0;
            branch_IDEX_o <= 0;
            jump_IDEX_o <= 0;
            memtoReg_IDEX_o <= 0;
            regWrite_IDEX_o <= 0;
            memRead_IDEX_o <= 0;
            memWrite_IDEX_o <= 0;
            ALUSrc_IDEX_o <= 0;
            ALUOp_IDEX_o <= 0;
            read1_o <= 0;
            read2_o <= 0;
            imm_o <= 0;
            alu_ctrl_o <= 0;
            rd_o <= 0;
            pc_plus4_o <= 0;
            ori_pc_o <= 0;
        end 
        else if(IDEXflush) begin
            rs_o <= 0;
            branch_IDEX_o <= 0;
            jump_IDEX_o <= 0;
            memtoReg_IDEX_o <= 0;
            regWrite_IDEX_o <= 0;
            memRead_IDEX_o <= 0;
            memWrite_IDEX_o <= 0;
            ALUSrc_IDEX_o <= 0;
            ALUOp_IDEX_o <= 0;
            read1_o <= 0;
            read2_o <= 0;
            imm_o <= 0;
            alu_ctrl_o <= 0;
            rd_o <= 0;
            pc_plus4_o <= 0;
            ori_pc_o <= 0;
        end
        else begin
            rs_o <= rs_i;
            branch_IDEX_o <= branch_IDEX_i;
            jump_IDEX_o <= jump_IDEX_i;
            memtoReg_IDEX_o <= memtoReg_IDEX_i;
            regWrite_IDEX_o <= regWrite_IDEX_i;
            memRead_IDEX_o <= memRead_IDEX_i;
            memWrite_IDEX_o <= memWrite_IDEX_i;
            ALUSrc_IDEX_o <= ALUSrc_IDEX_i;
            ALUOp_IDEX_o <= ALUOp_IDEX_i;
            read1_o <= read1_i;
            read2_o <= read2_i;
            imm_o <= imm_i;
            alu_ctrl_o <= alu_ctrl_i;
            rd_o <= rd_i;
            pc_plus4_o <= pc_plus4_i;
            ori_pc_o <= ori_pc_i;
        end
    end
endmodule
