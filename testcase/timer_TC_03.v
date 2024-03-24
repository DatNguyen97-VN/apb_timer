//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/27/2021 02:49:40 PM
// Design Name: 
// Module Name: testcase write read TSR
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

`define WAIT 0

module timer_TC_03;
  
  reg [1:0] err_flg_TSR1, err_flg_TSR2;
  reg [1:0] err_flg_TCR1, err_flg_TCR2;

  timer_testbench #(`WAIT) tb ();

  initial begin
        #100;
            //Check data of TSR[0] when overflow
            tb.CPU.NORMAL_WRITE(8'h01, 8'h10);
            tb.CPU.READ(8'h01); 
            tb.CPU.CHECK_READ(8'h10, 8'h01, err_flg_TCR1);
            repeat (511) @(posedge tb.CPU.cpu_clk);
            tb.CPU.READ(8'h02); 
            tb.CPU.CHECK_READ(8'h01, 8'h02, err_flg_TSR1); 
            //Check data of TSR[1] when underflow
            tb.CPU.NORMAL_WRITE(8'h01, 8'h30);
            tb.CPU.READ(8'h01); 
            tb.CPU.CHECK_READ(8'h30, 8'h01, err_flg_TCR2);
            repeat (511) @(posedge tb.CPU.cpu_clk); 
            repeat (511) @(posedge tb.CPU.cpu_clk);
            tb.CPU.READ(8'h02); 
            tb.CPU.CHECK_READ(8'h03, 8'h02, err_flg_TSR2);  
            tb.CPU.CHECK_BY_PASS(err_flg_TSR1 | err_flg_TSR2 | err_flg_TCR1 | err_flg_TCR2);
        #10 $finish;   
    end
  
  initial begin
       tb.CPU.cpu_psel    = 1'b0;
       tb.CPU.cpu_penable = 1'b0;
       tb.CPU.cpu_pwrite  = 1'b0;
  end
endmodule

