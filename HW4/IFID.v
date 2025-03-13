module IFID (
    input clk,
    input rst,
    input IFflush,
    input IFID_write,
    input [31:0] pc_plus4_i,
    input [31:0] ori_pc_i,
    input [31:0] inst_i,
    output reg [31:0] pc_plus4_o,
    output reg [31:0] ori_pc_o,
    output reg [31:0] inst_o
);
    //localparam [31:0] NOP = 32'b0000_0000_0000_0000_0000_0000_0001_0011; // addi x0, x0, 0;


    always @(posedge clk, negedge rst) begin
        if(!rst) begin 
            ori_pc_o <= 0;
            pc_plus4_o <= 0;
            inst_o <= 0;
        end
        else begin
            if(IFflush) begin
                ori_pc_o <= 0;
                pc_plus4_o <= 0;
                inst_o <= 0;
            end
            else if(IFID_write) begin
                ori_pc_o <= ori_pc_i;
                pc_plus4_o <= pc_plus4_i; 
                inst_o <= inst_i;
            end
            else begin
                ori_pc_o <= ori_pc_o;
                pc_plus4_o <= pc_plus4_o; 
                inst_o <= inst_o;
            end
        end
    end
endmodule
