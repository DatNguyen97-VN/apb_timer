//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/05/2021 02:59:26 PM
// Design Name: 
// Module Name: generate system signal
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: check function protocol: write, read and two cycle for write data.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module SYSTEM_signal(
    output reg sys_clk, sys_reset
);
    initial begin
       sys_clk = 1'b0;
       #10;
       forever begin
         #10 sys_clk = ~sys_clk;
       end
    end

    initial begin
       sys_reset = 1'b0;
       #100 sys_reset = 1'b1;
    end
endmodule
