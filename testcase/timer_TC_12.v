//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2021 03:12:35 PM
// Design Name: 
// Module Name: testcase check TCNT is normal activity after reset.
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

module timer_TC_12;
  
  reg [1:0] err_flg_clk, err_flg_TCR;

  timer_testbench #(`WAIT) tb ();

  initial begin
        #100;
        // Check PCLK/2
            tb.CPU.NORMAL_WRITE(8'h01, 8'h10);  
            tb.CPU.READ(8'h01); 
            tb.CPU.CHECK_READ(8'h10, 8'h01, err_flg_TCR);
            repeat (503) @(posedge tb.CPU.cpu_clk);
            // Stop count
            tb.CPU.NORMAL_WRITE(8'h01, 8'h00);
            $display("Start check PCLK/2 \n");
            CHECK_CLOCK(tb.DUT.CNT, 8'hFF, err_flg_clk);
            // Check count with PCLK/2
            if (err_flg_clk[1]) begin
              $display ("##################################################################\n");
              $display ("Before RESET TCNT is uncorrect when count at PCLK/2.\n");
              $display ("##################################################################\n");
            end else begin
              $display ("##################################################################\n");
              $display ("Before RESET TCNT is correct when count at PCLK/2.\n");
              $display ("##################################################################\n");
            end
            // Trigger reset 
            $display ("Trigger RESET in 100 PCLK\n");
            tb.SYSTEM.sys_reset = 1'b0;
            repeat (100) @(posedge tb.CPU.cpu_clk);
            // Turn off reset
            $display ("Turn off RESET\n");
            tb.SYSTEM.sys_reset = 1'b1;
            // Wait 503 PCLK clock
            repeat (503) @(posedge tb.CPU.cpu_clk);
            // Check count with PCLK/2
            if (err_flg_clk[1]) begin
              $display ("##################################################################\n");
              $display ("After RESET TCNT is uncorrect when count at PCLK/2.\n");
              $display ("##################################################################\n");
            end else begin
              $display ("##################################################################\n");
              $display ("After RESET TCNT is correct when count at PCLK/2.\n");
              $display ("##################################################################\n");
            end
        // Check pass/fail
            tb.CPU.CHECK_BY_PASS(err_flg_TCR | err_flg_clk);
        #10 $finish;   
    end
  
  initial begin
       tb.CPU.cpu_psel    = 1'b0;
       tb.CPU.cpu_penable = 1'b0;
       tb.CPU.cpu_pwrite  = 1'b0;
  end
    
  //Check mod clock.  
  task CHECK_CLOCK;
         input  [7:0] data , CNT;
         output [1:0] err_flg;

         begin
         if (data == CNT) begin
           $display ("Data = %h, Expected = %h\n", data, CNT);
           $display ("##################################################################");
           $display ("##################################################################");
           $display ("############################ PADSSED #############################");
           $display ("##################################################################");
           $display ("##################################################################\n");
           err_flg = 2'b01;
         end else begin
           $display ("Data = %h, Expected = %h\n", data, CNT);
           $display ("##################################################################");
           $display ("##################################################################");
           $display ("########################### FAILED ###############################");
           $display ("##################################################################");
           $display ("##################################################################\n");
           err_flg = 2'b10;
         end
        $display("Check data finished\n");
         end
    endtask
endmodule