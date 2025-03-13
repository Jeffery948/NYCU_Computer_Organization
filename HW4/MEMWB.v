module MEMWB (
    input clk,
    input rst,
    input jump_MEMWB_i,
    input memtoReg_MEMWB_i,
    input regWrite_MEMWB_i,
    input [31:0] read_i,
    input [31:0] alu_out_i,
    input [4:0] rd_i,
    input [31:0] pc_plus4_i,
    output reg jump_MEMWB_o,
    output reg memtoReg_MEMWB_o,
    output reg regWrite_MEMWB_o,
    output reg [31:0] read_o,
    output reg [31:0] alu_out_o,
    output reg [4:0] rd_o,
    output reg [31:0] pc_plus4_o
);

    always @(posedge clk, negedge rst) begin
        if(!rst) begin
            jump_MEMWB_o <= 0;
            memtoReg_MEMWB_o <= 0;
            regWrite_MEMWB_o <= 0;
            read_o <= 0;
            alu_out_o <= 0;
            rd_o <= 0;
            pc_plus4_o <= 0;
        end 
        else begin
            jump_MEMWB_o <= jump_MEMWB_i;
            memtoReg_MEMWB_o <= memtoReg_MEMWB_i;
            regWrite_MEMWB_o <= regWrite_MEMWB_i;
            read_o <= read_i;
            alu_out_o <= alu_out_i;
            rd_o <= rd_i;
            pc_plus4_o <= pc_plus4_i;
        end
    end
endmodule
