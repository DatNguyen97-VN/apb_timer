//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/27/2021 03:33:10 PM
// Design Name: 
// Module Name: testcase check function of TCNT when count up with mod PCLK / 2 4 8 16.
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

module timer_TC_05;
  
  reg [1:0] err_flg_clk2, err_flg_clk4, err_flg_clk8, err_flg_clk16;
  reg [1:0] err_flg_TCR2, err_flg_TCR4, err_flg_TCR8, err_flg_TCR16;
  reg [7:0] cnt2, cnt4, cnt8, cnt16;

  timer_testbench #(`WAIT) tb ();

  initial begin
        #100;
        //Check PCLK/2
            tb.CPU.NORMAL_WRITE(8'h01, 8'h10);  
            tb.CPU.READ(8'h01); 
            tb.CPU.CHECK_READ(8'h10, 8'h01, err_flg_TCR2);
            repeat (503) @(posedge tb.CPU.cpu_clk);
            // Stop count
            tb.CPU.NORMAL_WRITE(8'h01, 8'h00);
            $display("Start check PCLK/2 \n");
            CHECK_CLOCK(tb.DUT.CNT, 8'hFF, err_flg_clk2);
            // Check count with PCLK/2
            if (err_flg_clk2[1]) begin
              $display ("##################################################################\n");
              $display ("TCNT is uncorrect when count at PCLK/2.\n");
              $display ("##################################################################\n");
            end else begin
              $display ("##################################################################\n");
              $display ("TCNT is correct when count at PCLK/2.\n");
              $display ("##################################################################\n");
            end
        //Check PCLK/4
            tb.CPU.NORMAL_WRITE(8'h01, 8'h11);  
            tb.CPU.READ(8'h01); 
            tb.CPU.CHECK_READ(8'h11, 8'h01, err_flg_TCR4);
            repeat (1018) @(posedge tb.CPU.cpu_clk);
            // Stop count
            tb.CPU.NORMAL_WRITE(8'h01, 8'h00);
            $display("Start check PCLK/4 \n");
            CHECK_CLOCK(tb.DUT.CNT, 8'hFF, err_flg_clk4);
            // Check count with PCLK/2
            if (err_flg_clk4[1]) begin
              $display ("##################################################################\n");
              $display ("TCNT is uncorrect when count at PCLK/4.\n");
              $display ("##################################################################\n");
            end else begin
              $display ("##################################################################\n");
              $display ("TCNT is correct when count at PCLK/4.\n");
              $display ("##################################################################\n");
            end
        //Check PCLK/8
            tb.CPU.NORMAL_WRITE(8'h01, 8'h12);  
            tb.CPU.READ(8'h01); 
            tb.CPU.CHECK_READ(8'h12, 8'h01, err_flg_TCR8);
            repeat (2041) @(posedge tb.CPU.cpu_clk);
            // Stop count
            tb.CPU.NORMAL_WRITE(8'h01, 8'h00);
            $display("Start check PCLK/8 \n");
            CHECK_CLOCK(tb.DUT.CNT, 8'hFF, err_flg_clk8);
            // Check count with PCLK/2
            if (err_flg_clk8[1]) begin
              $display ("##################################################################\n");
              $display ("TCNT is uncorrect when count at PCLK/8.\n");
              $display ("##################################################################\n");
            end else begin
              $display ("##################################################################\n");
              $display ("TCNT is correct when count at PCLK/8.\n");
              $display ("##################################################################\n");
            end
        //Check PCLK/16
            tb.CPU.NORMAL_WRITE(8'h01, 8'h13);  
            tb.CPU.READ(8'h01); 
            tb.CPU.CHECK_READ(8'h13, 8'h01, err_flg_TCR16);
            repeat (4082) @(posedge tb.CPU.cpu_clk);
            // Stop count
            tb.CPU.NORMAL_WRITE(8'h01, 8'h00);
            $display("Start check PCLK/16 \n");
            CHECK_CLOCK(tb.DUT.CNT, 8'hFF, err_flg_clk16);
            // Check count with PCLK/2
            if (err_flg_clk16[1]) begin
              $display ("##################################################################\n");
              $display ("TCNT is uncorrect when count at PCLK/16.\n");
              $display ("##################################################################\n");
            end else begin
              $display ("##################################################################\n");
              $display ("TCNT is correct when count at PCLK/16.\n");
              $display ("##################################################################\n");
            end
        // Check pass/fail
        tb.CPU.CHECK_BY_PASS(err_flg_TCR2 | err_flg_clk2 | err_flg_TCR4 | err_flg_clk4 |
                             err_flg_TCR8 | err_flg_clk8 | err_flg_TCR16 | err_flg_clk16);
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