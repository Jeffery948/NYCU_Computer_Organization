module Mux4to1 #(
    parameter size = 32
) 
(
    input [1:0] sel,
    input signed [size-1:0] s0,
    input signed [size-1:0] s1,
    input signed [size-1:0] s2,
    output signed [size-1:0] out
);
    
    assign out = (sel == 2'b00) ? s0 : ((sel == 2'b01) ? s1 : s2);
    
    /*if (sel == 2'b00)
        assign out = s0;
    else if (sel == 2'b01)
        assign out = s1;
    else
        assign out = s2;*/
    
endmodule

