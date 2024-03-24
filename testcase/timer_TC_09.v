//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/27/2021 07:11:40 PM
// Design Name: 
// Module Name: testcase check Timer counter underflow when counter 8'h00 down 8'hFF.
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

module timer_TC_09;
  
  reg [1:0] err_flg_TCR, err_flg_TDR, err_flg_TSR;

  timer_testbench #(`WAIT) tb ();

  initial begin
        #100;
            // Set TDR is 8'h00
            tb.CPU.NORMAL_WRITE(8'h00, 8'h00);  
            tb.CPU.READ(8'h00); 
            tb.CPU.CHECK_READ(8'h00, 8'h00, err_flg_TDR);
            // Set TCR is 8'h80 to LOAD data from TDR to TCNT
            tb.CPU.NORMAL_WRITE(8'h01, 8'hB0);  
            tb.CPU.READ(8'h01); 
            tb.CPU.CHECK_READ(8'hB0, 8'h01, err_flg_TCR);
            // Wait 1 PCLK clock
            @(posedge tb.CPU.cpu_clk);
            // Set TDR is 8'hFF
            tb.CPU.NORMAL_WRITE(8'h00, 8'hFF);  
            tb.CPU.READ(8'h00); 
            tb.CPU.CHECK_READ(8'hFF, 8'h00, err_flg_TDR);
            // Set TCR is 8'h80 to LOAD data from TDR to TCNT
            tb.CPU.NORMAL_WRITE(8'h01, 8'hB0);  
            tb.CPU.READ(8'h01); 
            tb.CPU.CHECK_READ(8'hB0, 8'h01, err_flg_TCR);
            // Check TSR[0] 
            tb.CPU.READ(8'h02); 
            tb.CPU.CHECK_READ(8'h00, 8'h02, err_flg_TSR);
            if (err_flg_TSR[1]) begin
              $display ("##################################################################");
              $display (" Timer counter underflow when counter 8'h00 down 8'hFF        ##");
              $display (" is uncorrect.                                                ##");
              $display ("##################################################################\n");
            end else begin
              $display ("##################################################################");
              $display (" Timer counter underflow when counter 8'h00 down 8'hFF        ##");
              $display (" is correct.                                                  ##");
              $display ("##################################################################\n");
            end
            // Check pass/fail
            tb.CPU.CHECK_BY_PASS(err_flg_TDR | err_flg_TCR | err_flg_TSR);
        #10 $finish;   
    end
  
  initial begin
       tb.CPU.cpu_psel    = 1'b0;
       tb.CPU.cpu_penable = 1'b0;
       tb.CPU.cpu_pwrite  = 1'b0;
  end
endmodule