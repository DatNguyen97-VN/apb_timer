//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/27/2021 07:49:45 PM
// Design Name: 
// Module Name: testcase check function of TCNT when when unexpected stop count down.
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

module timer_TC_11;
  
  reg [1:0] err_flg_TCNT;
  reg [1:0] err_flg_TCR;
  reg [7:0] temp;

  timer_testbench #(`WAIT) tb ();

  initial begin
        #100;
            // Set TCNT is count down
            tb.CPU.NORMAL_WRITE(8'h01, 8'h30);
            tb.CPU.READ(8'h01); 
            tb.CPU.CHECK_READ(8'h30, 8'h01, err_flg_TCR);
            repeat (200) @(posedge tb.CPU.cpu_clk);
            // Delay TCNT on 200 PCLK clock
            tb.CPU.NORMAL_WRITE(8'h01, 8'h00);
            tb.CPU.READ(8'h01); 
            tb.CPU.CHECK_READ(8'h00, 8'h01, err_flg_TCR);
            repeat (200) @(posedge tb.CPU.cpu_clk);
            // Trigger TCNT
            tb.CPU.NORMAL_WRITE(8'h01, 8'h30);
            tb.CPU.READ(8'h01); 
            tb.CPU.CHECK_READ(8'h30, 8'h01, err_flg_TCR);
            repeat (301) @(posedge tb.CPU.cpu_clk);
            // Check value of TCNT
            $display ("Start check value of TCNT after delay.\n");
            if (8'h00 == tb.DUT.CNT) begin
               $display ("##################################################################");
               $display ("############################ DATA: %h ############################", tb.DUT.CNT);
               $display ("##################################################################");
               $display ("############################ PADSSED  ############################");
               $display ("##################################################################\n");
               err_flg_TCNT[0] = 1'b1;
            end else begin
               $display ("##################################################################");
               $display ("######################## DATA: %h, EXPECTED: %h ##################", tb.DUT.CNT, 8'h00);
               $display ("##################################################################");
               $display ("############################ FAILED ##############################");
               $display ("##################################################################\n");
               err_flg_TCNT[1] = 1'b1;
            end
            tb.CPU.CHECK_BY_PASS(err_flg_TCNT | err_flg_TCR);
        #10 $finish;   
    end
  
  initial begin
       tb.CPU.cpu_psel    = 1'b0;
       tb.CPU.cpu_penable = 1'b0;
       tb.CPU.cpu_pwrite  = 1'b0;
  end
endmodule

