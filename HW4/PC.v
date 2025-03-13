module PC (
    input clk,
    input rst,
    input PCwrite,
    input [31:0] pc_i,
    output reg [31:0] pc_o
);

    // TODO: implement your program counter here
    always @(posedge clk, negedge rst) begin
        if(!rst) begin
            pc_o <= 32'b0;
        end
        else begin
            if(PCwrite) begin
                pc_o <= pc_i;
            end
            else begin
                pc_o <= pc_o;
            end
        end
    end


endmodule

