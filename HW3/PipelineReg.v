module PipelineReg #(
    parameter size = 32
) 
(
    input clk,
    input rst,
    input [size-1:0] data_i,
    output reg [size-1:0] data_o
);

    always @(posedge clk, negedge rst) begin
        if(!rst) begin
            data_o <= 0;
        end
        else begin
            data_o <= data_i;
        end
    end

endmodule
