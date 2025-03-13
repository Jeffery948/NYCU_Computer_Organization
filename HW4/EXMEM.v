module EXMEM (
    input clk,
    input rst,
    input jump_EXMEM_i,
    input memtoReg_EXMEM_i,
    input regWrite_EXMEM_i,
    input memRead_EXMEM_i,
    input memWrite_EXMEM_i,
    input [31:0] alu_out_i,
    input [31:0] B_out_i,
    input [4:0] rd_i,
    input [31:0] pc_plus4_i,
    output reg jump_EXMEM_o,
    output reg memtoReg_EXMEM_o,
    output reg regWrite_EXMEM_o,
    output reg memRead_EXMEM_o,
    output reg memWrite_EXMEM_o,
    output reg [31:0] alu_out_o,
    output reg [31:0] B_out_o,
    output reg [4:0] rd_o,
    output reg [31:0] pc_plus4_o
);

    always @(posedge clk, negedge rst) begin
        if(!rst) begin
            jump_EXMEM_o <= 0;
            memtoReg_EXMEM_o <= 0;
            regWrite_EXMEM_o <= 0;
            memRead_EXMEM_o <= 0;
            memWrite_EXMEM_o <= 0;
            alu_out_o <= 0;
            B_out_o <= 0;
            rd_o <= 0;
            pc_plus4_o <= 0;
        end 
        else begin
            jump_EXMEM_o <= jump_EXMEM_i;
            memtoReg_EXMEM_o <= memtoReg_EXMEM_i;
            regWrite_EXMEM_o <= regWrite_EXMEM_i;
            memRead_EXMEM_o <= memRead_EXMEM_i;
            memWrite_EXMEM_o <= memWrite_EXMEM_i;
            alu_out_o <= alu_out_i;
            B_out_o <= B_out_i;
            rd_o <= rd_i;
            pc_plus4_o <= pc_plus4_i;
        end
    end
endmodule
