//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2021 08:18:30 PM
// Design Name: 
// Module Name: testcase write read TDR
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define WAIT 7

module timer_TC_01;
  
  reg [1:0] err_flg_CNT, err_flg_TDR;

  timer_testbench #(`WAIT) tb ();

  initial begin
        #100;
            tb.CPU.NORMAL_WRITE(8'h00, 8'h13); 
            tb.CPU.NORMAL_WRITE(8'h01, 8'h80);  
            tb.CPU.READ(8'h00); 
            tb.CPU.CHECK_READ(8'h13, 8'h00, err_flg_TDR);
            tb.CPU.CHECK_CNT(8'h13, tb.DUT.CNT, err_flg_CNT);
            //Clear TCR
            tb.CPU.NORMAL_WRITE(8'h01, 8'h00); 
            //Write invalid address
            tb.CPU.NORMAL_WRITE(8'h03, 8'h00); 
            //Read invalid address
            tb.CPU.READ(8'h03); 
            // Coveravage
            tb.CPU.NORMAL_WRITE(8'h01, 8'h90); 
            tb.CPU.CHECK_BY_PASS(err_flg_TDR | err_flg_CNT);
        #10 $finish;   
    end
  
  initial begin
       tb.CPU.cpu_psel    = 1'b0;
       tb.CPU.cpu_penable = 1'b0;
       tb.CPU.cpu_pwrite  = 1'b0;
  end
endmodule

